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
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    public class QuestionController : Controller
    {
        private readonly IQuestionRepository _qr;
        private readonly JavaScriptSerializer _jsSerializer;
        private readonly IrabbitHandler _rabbitHandler;
        public QuestionController(IQuestionRepository qr, IrabbitHandler rabbitHandler)
        {
            _qr = qr;
            _jsSerializer = new JavaScriptSerializer();
            _rabbitHandler = rabbitHandler;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var questions = _qr.GetAllQuestions();
            return _jsSerializer.Serialize(questions.Result);
        }

        [System.Web.Mvc.HttpPost]
        public void CreateQuestion(string question, string type)
        {
            _rabbitHandler.publishString("CreateQuestion",question);
            string typeString = "WisR.DomainModels." + type;
            Type questionType = Type.GetType(typeString);
            var q = _jsSerializer.Deserialize(question, questionType);
            _qr.AddQuestionObject(q);
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _qr.GetQuestion(id);
            if (item == null)
            {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteQuestion(string id)
        {
            var result = _qr.RemoveQuestion(id).Result;
            if (result.DeletedCount == 1)
            {
                return "IQuestion was deleted";
            }
            return "Couldn't find question to delete";
        }

        public void MakeQuestion()
        {
            //Insert different interface implementations
            var q0 = new BooleanQuestion();
            var q1 = new TextualQuestion();

            _qr.AddQuestion(q0);
            _qr.AddQuestion(q1);
            Console.WriteLine("Finished saving");
        }
    }
}