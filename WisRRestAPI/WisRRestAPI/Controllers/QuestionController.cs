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

            return questions.Result.ToJson();
        }

        [System.Web.Mvc.HttpGet]
        public string GetQuestionsForRoom(string roomId) {
            var qList = _qr.GetQuestionsForRoom(roomId);
            return qList.Result.ToJson();
        }

        [System.Web.Mvc.HttpPost]
        public string CreateQuestion(string question, string type) {
            Type questionType;
            try {
                string typeString = "WisR.DomainModels." + type;
                questionType = Type.GetType(typeString);
            } catch (Exception) {
                return "Could not determine type from string: " + type;
            }

            object b;
            Question q;
            try {
                b = BsonSerializer.Deserialize(question, questionType);
                q = (Question)b;
            } catch (Exception e) {
                return "Could not deserialize the JSON string: " + question;
            }
            if (q.Id != null) {
                return "New question should have id of null";
            }
            try
            {
                _rabbitHandler.publishString("CreateQuestion", q.ToJson());
            }
            catch (Exception e)
            {
                return "Could not publish to rabbitMQ";
            }
            q.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
                _qr.AddQuestionObject(b);
                return "Question saved with id: " + q.Id;
            
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id) {
            var item = _qr.GetQuestion(id);
            if (item == null) {
                return "Not found";
            }

            return item.ToJson();
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