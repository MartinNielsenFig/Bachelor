using System;
using System.Collections.Generic;
using System.Data.Entity.Core.Objects;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Conventions;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers {
    public class QuestionController : Controller {
        private readonly IQuestionRepository _qr;
        private readonly JavaScriptSerializer _jsSerializer;
        private readonly IrabbitHandler _rabbitHandler;
        public QuestionController(IQuestionRepository qr, IrabbitHandler rabbitHandler) {
            _qr = qr;
            _jsSerializer = new JavaScriptSerializer();
            _rabbitHandler = rabbitHandler;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll() {
            var questions = _qr.GetAllQuestions();
            return _jsSerializer.Serialize(questions.Result);
        }


        [System.Web.Mvc.HttpPost]
        public HttpStatusCodeResult CreateQuestion(string roomId, string question, string type) {
            try {
                _rabbitHandler.publishString("CreateQuestion", question);
            } catch (Exception) {
                return new HttpStatusCodeResult(602, "Could not publish to rabbitMQ");
            }

            Type questionType;
            try {
                string typeString = "WisR.DomainModels." + type;
                questionType = Type.GetType(typeString);
            } catch (Exception) {
                return new HttpStatusCodeResult(603, "Could not determine type from string: " + type);
            }

            object b;
            Question q;
            try {
                b = BsonSerializer.Deserialize(question, questionType);
                q = (Question)b;
            } catch (Exception) {
                return new HttpStatusCodeResult(604, "Could not deserialize the JSON string: " + question);
            }
            if (q.Id != null) {
                return new HttpStatusCodeResult(605, "New question should have id of null");
            } else {
                q.Id = ObjectId.GenerateNewId();
                _qr.AddQuestionObject(b);
                return new HttpStatusCodeResult(200, "Question saved");
            }
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id) {
            var item = _qr.GetQuestion(id);
            if (item == null) {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteQuestion(string id) {
            var result = _qr.RemoveQuestion(id).Result;
            if (result.DeletedCount == 1) {
                return "IQuestion was deleted";
            }
            return "Couldn't find question to delete";
        }

        public void MakeQuestion() {
            //Insert different interface implementations
            var q0 = new BooleanQuestion();
            var q1 = new TextualQuestion();

            _qr.AddQuestion(q0);
            _qr.AddQuestion(q1);
            Console.WriteLine("Finished saving");
        }
    }
}