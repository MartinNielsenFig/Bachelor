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
using MongoDB.Driver;
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
                errors.Add(ErrorCodes.NewQuestionIdShouldBeNull);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            if (!_rr.DoesRoomExist(q.RoomId)) {
                errors.Add(ErrorCodes.RoomDoesNotExist);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            q.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

            q.CreationTimestamp = TimeHelper.timeSinceEpoch();
            q.ExpireTimestamp = Convert.ToString(Convert.ToInt64(TimeHelper.timeSinceEpoch()) + Convert.ToInt64(q.ExpireTimestamp) * 60000);

           try
            {
                _irabbitPublisher.publishString("CreateQuestion", q.ToJson());
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RabbitMqError);
                errorType = ErrorTypes.Complicated;
            }

            try
            {
                _qr.AddQuestionObject(b);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotAddQuestion);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(null, errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string UpdateQuestion(string question, string type, string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);
            
            object b;
            Question q;

            try
            {
 b = BsonSerializer.Deserialize(question, questionType);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            q = (Question)b;
            q.Id = id;
            try
            {
                _qr.UpdateQuestion(id, q);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotUpdateQuestion);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            try
            {
                _irabbitPublisher.publishString("UpdateQuestion", q.ToJson());
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RabbitMqError);
                errorType= ErrorTypes.Complicated;
            }
            return new Notification(null, errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string AddQuestionResponse(string response, string questionId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Question q;
            try
            {
 q = _qr.GetQuestionWithoutImage(questionId).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
        
           

            if (Convert.ToDouble(q.ExpireTimestamp) >
                (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds)
            {
                q.Id = questionId;

                Answer answer;
                try
                {
 answer = BsonSerializer.Deserialize<Answer>(response);
                }
                catch (Exception)
                {
                    errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                    return new Notification(null, ErrorTypes.Error, errors).ToJson();
                }
               
                if (q.Result.Exists(x => x.UserId == answer.UserId))
                {
                    q.Result.Find(x => x.UserId == answer.UserId).Value = answer.Value;
                }
                else
                {
                    q.Result.Add(answer);
                }

                try
                {
_qr.UpdateQuestionResults(questionId, q);
                }
                catch (Exception)
                {
                    errors.Add(ErrorCodes.CouldNotUpdateQuestion);
                    return new Notification(null, ErrorTypes.Error, errors).ToJson();
                }
                
                try
                {
                    _irabbitPublisher.publishString("AddQuestionResponse", q.ToJson());
                }
                catch (Exception e)
                {
                    errors.Add(ErrorCodes.RabbitMqError);
                    errorType = ErrorTypes.Complicated;
                }
            }
            else
            {
                errors.Add(ErrorCodes.QuestionExpired);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            return new Notification(null, errorType, errors).ToJson();
        }
        public string AddVote(string vote, string type, string id) {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            Type questionType;

            string typeString = "WisR.DomainModels." + type;
            questionType = Type.GetType(typeString);

            Question q;
            try
            {
q = _qr.GetQuestionWithoutImage(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            

            q.Id = id;

            Vote v;
            try
            {
                v = BsonSerializer.Deserialize<Vote>(vote);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            

            if (q.Votes.Exists(x => x.CreatedById == v.CreatedById)) {
                q.Votes.Find(x => x.CreatedById == v.CreatedById).Value = v.Value;
            } else {
                q.Votes.Add(v);
            }

            try
            {
                _qr.UpdateQuestionVotes(id, q);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotUpdateQuestion);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           

            try {
                _irabbitPublisher.publishString("AddQuestionVote", q.ToJson());
            } catch (Exception e) {
                errors.Add(ErrorCodes.RabbitMqError);
                errorType = ErrorTypes.Complicated;
            }

            return new Notification(null, errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<Question> item;
            try
            {
                item = _qr.GetQuestion(id);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            if (item == null)
            {
                errors.Add(ErrorCodes.CouldNotGetQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(item.ToJson(), errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteQuestion(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            DeleteResult result;
            try
            {
                result = _qr.DeleteQuestion(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotDeleteAllQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            if (result.DeletedCount == 1)
            {
                try
                {
                    _irabbitPublisher.publishString("DeleteQuestion", id);
                }
                catch (Exception e)
                {
                    errors.Add(ErrorCodes.RabbitMqError);
                    errorType = ErrorTypes.Complicated;
                }
                return new Notification(null, errorType, errors).ToJson();
            }

            errors.Add(ErrorCodes.CouldNotDeleteAllQuestions);
            return new Notification(null, ErrorTypes.Error, errors).ToJson();
        }
    }
}