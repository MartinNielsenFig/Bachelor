﻿using System;
using System.Collections.Generic;
using System.Data.Entity.Core.Objects;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Helpers;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Conventions;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    public class QuestionController : Controller
    {
        private readonly IQuestionRepository _qr;
        private readonly IRabbitPublisher _irabbitPublisher;
        public QuestionController(IQuestionRepository qr, IRabbitPublisher irabbitPublisher)
        {
            _qr = qr;
            _irabbitPublisher = irabbitPublisher;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var questions = _qr.GetAllQuestions();
            var temp= questions.Result.ToJson();
            return temp;
        }

        [System.Web.Mvc.HttpGet]
        public string GetQuestionsForRoom(string roomId) {
            var qList = _qr.GetQuestionsForRoom(roomId);
            return qList.Result.ToJson();
        }
        [System.Web.Mvc.HttpGet]
        public string GetQuestionsForRoomWithoutImages(string roomId)
        {
            var qList = _qr.GetQuestionsForRoomWithoutImages(roomId);
            return qList.Result.ToJson();
        }
        [System.Web.Mvc.HttpGet]
        public string GetImageByQuestionId(string questionId)
        {
            var qList = _qr.GetImageByQuestionId(questionId);
            var result = qList.Result;
            return result.Img;
        }

        [System.Web.Mvc.HttpPost]
        public string CreateQuestion(string question, string type)
        {
            Type questionType;
            try
            {
                string typeString = "WisR.DomainModels." + type;
                questionType = Type.GetType(typeString);
            }
            catch (Exception e)
            {
                return new Error("Could not determine type from string: " + type, 100, e.StackTrace).ToJson();
            }

            object b;
            Question q;
            try
            {
                b = BsonSerializer.Deserialize(question, questionType);
                q = (Question)b;
            }
            catch (Exception e)
            {
                return new Error("Could not deserialize the JSON string: " + question, 100, e.StackTrace).ToJson();
            }
            if (q.Id != null)
            {
                return "New question should have id of null";
            }
            
            q.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

            q.CreationTimestamp = TimeHelper.timeSinceEpoch();
            q.ExpireTimestamp = Convert.ToString(Convert.ToInt64(TimeHelper.timeSinceEpoch()) + Convert.ToInt64(q.ExpireTimestamp) * 60000);

            String error = "";
            try
            {
                _irabbitPublisher.publishString("CreateQuestion", q.ToJson());
            }
            catch (Exception e)
            {
                error += "Could not publish to rabbitMQ";
            }
            _qr.AddQuestionObject(b);
            return "Question saved with id: " + q.Id + " error: " + error;

        }
        [System.Web.Mvc.HttpPost]
        public void UpdateQuestion(string question, string type, string id)
        {
            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);
            
            object b;
            Question q;

            b = BsonSerializer.Deserialize(question, questionType);
            q = (Question)b;
            q.Id = id;
            _qr.UpdateQuestion(id, q);
            try
            {
                _irabbitPublisher.publishString("UpdateQuestion", q.ToJson());
            }
            catch (Exception e)
            {
            }
        }

        //[System.Web.Mvc.HttpPost]
        //public void UpdateQuestionResponse(string question, string type, string id)
        //{
        //    Type questionType;

        //    string typeString = "WisR.DomainModels." + type;
        //    questionType = Type.GetType(typeString);

        //    object b;
        //    Question q;

        //    b = BsonSerializer.Deserialize(question, questionType);
        //    q = (Question)b;
        //    if (Convert.ToDouble(q.ExpireTimestamp) > (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds)
        //    {
        //        q.Id = id;
        //        _qr.UpdateQuestion(id, q);
        //        try
        //        {
        //            _irabbitPublisher.publishString("UpdateQuestion", q.ToJson());
        //        }
        //        catch (Exception e)
        //        {
        //        }
        //    }

        //}
        public void AddQuestionResponse(string response, string type, string id)
        {
            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);

            var q = _qr.GetQuestion(id).Result;

            if (Convert.ToDouble(q.ExpireTimestamp) >
                (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds)
            {
                q.Id = id;

                var answer = BsonSerializer.Deserialize<Answer>(response);
                if (q.Result.Exists(x=> x.UserId == answer.UserId))
                {
                    q.Result.Find(x => x.UserId == answer.UserId).Value = answer.Value;
                }
                else
                {
                    q.Result.Add(answer);
                }
                
                _qr.UpdateQuestion(id, q);
                try
                {
                    _irabbitPublisher.publishString("UpdateQuestion", q.ToJson());
                }
                catch (Exception e)
                {
                }
            }
        }

        public void AddVote(string vote, string type, string id)
        {
            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);

            var q = _qr.GetQuestion(id).Result;

            if (Convert.ToDouble(q.ExpireTimestamp) >
                (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds)
            {
                q.Id = id;

                var v = BsonSerializer.Deserialize<Vote>(vote);

                if (q.Votes.Exists(x => x.CreatedById == v.CreatedById))
                {
                    q.Votes.Find(x => x.CreatedById == v.CreatedById).Value = v.Value;
                }
                else
                {
                    q.Votes.Add(v);
                }
                    
                _qr.UpdateQuestion(id, q);
                try
                {
                    _irabbitPublisher.publishString("UpdateQuestion", q.ToJson());
                }
                catch (Exception e)
                {
                }
            }
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _qr.GetQuestion(id);
            if (item == null)
            {
                return "Not found";
            }

            return item.ToJson();
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

       
    }
   
}