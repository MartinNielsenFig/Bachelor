using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.IO;
using MongoDB.Bson.Serialization;
using Newtonsoft.Json.Linq;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisR.Controllers
{
    public class RoomController : Controller
    {
        private IrabbitHandler _rabbitHandler;

        public RoomController(IrabbitHandler rabbitHandler)
        {
            _rabbitHandler = rabbitHandler;
            _rabbitHandler.subscribe("CreateChatMessage");
            _rabbitHandler.subscribe("CreateQuestion");
        }
        // GET: Room
        public ActionResult Index(string roomId)
        {
            ViewBag.roomId = roomId;
            return View();
        }
        public string toJsonQuestion(string CreatedBy, string RoomId, int Downvotes, string Image, int Upvotes, string QuestionText, string ResponseOptions, string QuestionResult, string CreationTimestamp, string ExpireTimestamp, string QuetionsType)
        {

            var question = new BooleanQuestion();

            var tempList = new List<ResponseOption>();

            foreach (var response in ResponseOptions.Split(','))
            {
                tempList.Add(new ResponseOption() { Value = response });
            }
            var tempListResult = new List<Answer>();
            if (QuestionResult != null)
            {
                foreach (var result in QuestionResult.Split(','))
                {
                    var tempResult = result.Split('-');
                    tempListResult.Add(new Answer(){ Value = tempResult[0],UserId = tempResult[1]});
                }
            }


            question.CreatedById = CreatedBy;
            question.RoomId = RoomId;
            question.Downvotes = Downvotes;
            question.Img = Image;
            question.Upvotes = Upvotes;
            question.QuestionText = QuestionText;
            question.ResponseOptions = tempList;
            question.CreationTimestamp = CreationTimestamp;
            question.Result = tempListResult;
            question.ExpireTimestamp = ExpireTimestamp;

            return question.ToJson(); ;
        }
        public string toJsonChatMessage(string userId, string roomId, string text)
        {
            var chatMessage = new ChatMessage();
            chatMessage.ByUserId = userId;
            chatMessage.RoomId = roomId;
            chatMessage.Value = text;
            chatMessage.Timestamp = (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds.ToString();
            return chatMessage.ToJson();
        }
    }

}