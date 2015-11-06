using System;
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
using WisR.DomainModel;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    //Todo handle errors with Error() class.
    public class QuestionController : Controller
    {
        private readonly IRoomRepository _rr;
        private readonly IQuestionRepository _qr;
        private readonly IRabbitPublisher _irabbitPublisher;
        public QuestionController(IQuestionRepository qr, IRabbitPublisher irabbitPublisher, IRoomRepository rr)
        {
            _rr = rr;
            _qr = qr;
            _irabbitPublisher = irabbitPublisher;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            Task<List<Question>> questions;
            try
            {

                questions = _qr.GetAllQuestions();
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            string temp;
            try
            {
temp= questions.Result.ToJson();
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.StringIsNotJsonFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            return new Notification(temp, errorType, errors).ToJson();
        }

        [System.Web.Mvc.HttpGet]
        public string GetQuestionsForRoom(string roomId) {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<List<Question>> qList;
            try
            {
                qList = _qr.GetQuestionsForRoom(roomId);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            return new Notification(qList.Result.ToJson(), errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpGet]
        public string GetQuestionsForRoomWithoutImages(string roomId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<List<Question>> qList;
            try
            {
                qList = _qr.GetQuestionsForRoomWithoutImages(roomId);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            string result;
            try
            {
                result = qList.Result.ToJson();
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.StringIsNotJsonFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            return new Notification(result, errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpGet]
        public string GetImageByQuestionId(string questionId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<Question> qList;
            try
            {
                qList = _qr.GetImageByQuestionId(questionId);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            var result = qList.Result;

            return new Notification(result.Img, errorType, errors).ToJson();
        }

        [System.Web.Mvc.HttpPost]
        public string CreateQuestion(string question, string type)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Type questionType;
            try
            {
                string typeString = "WisR.DomainModels." + type;
                questionType = Type.GetType(typeString);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestionType);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
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
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            if (q.Id != null)
            {
                return "New question should have id of null";
            }
            if (!_rr.DoesRoomExist(q.RoomId)) {
                return "Room doesn't exist;";
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
            
            //Todo use Error() class instead of string.
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
            //TODO return something to the user
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

        [System.Web.Mvc.HttpPost]
        public string AddQuestionResponse(string response, string questionId)
        {
            var q = _qr.GetQuestionWithoutImage(questionId).Result;

            if (Convert.ToDouble(q.ExpireTimestamp) >
                (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds)
            {
                q.Id = questionId;

                var answer = BsonSerializer.Deserialize<Answer>(response);
                if (q.Result.Exists(x => x.UserId == answer.UserId))
                {
                    q.Result.Find(x => x.UserId == answer.UserId).Value = answer.Value;
                }
                else
                {
                    q.Result.Add(answer);
                }

                _qr.UpdateQuestionResults(questionId, q);
                try
                {
                    _irabbitPublisher.publishString("AddQuestionResponse", q.ToJson());
                }
                catch (Exception e)
                {
                    return "error" + e.StackTrace;
                }
            }
            else
            {
                return "Cannot respond to a question where timer has run out.";
            }
            //Todo handle return with Error() class
            return "";
        }

        public string AddVote(string vote, string type, string id) {
            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);

            var q = _qr.GetQuestionWithoutImage(id).Result;

            q.Id = id;

            var v = BsonSerializer.Deserialize<Vote>(vote);

            if (q.Votes.Exists(x => x.CreatedById == v.CreatedById)) {
                q.Votes.Find(x => x.CreatedById == v.CreatedById).Value = v.Value;
            } else {
                q.Votes.Add(v);
            }
            //Todo: error handling?
            _qr.UpdateQuestionVotes(id, q);
            try {
                _irabbitPublisher.publishString("AddQuestionVote", q.ToJson());
            } catch (Exception e) {
                return "error " + e.StackTrace;
            }

            return "";
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
            var result = _qr.DeleteQuestion(id).Result;
            if (result.DeletedCount == 1)
            {
                try
                {
                    _irabbitPublisher.publishString("DeleteQuestion", id);
                }
                catch (Exception e)
                {
                    return "error " + e.StackTrace;
                }
                return "Question was deleted";
            }

            return "";//new Error("Couldn't find question to delete",100).ToJson();
        }

       
    }
   
}