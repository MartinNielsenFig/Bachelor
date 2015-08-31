﻿using System;
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
        public void CreateQuestion(string question)
        {
            _rabbitHandler.publishString("CreateQuestion",question);
            _qr.AddQuestion(_jsSerializer.Deserialize<Question>(question));
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
                return "Question was deleted";
            }
            return "Couldn't find question to delete";
        }
    }
}