using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using Microsoft.Ajax.Utilities;
using MongoDB.Bson;
using MongoDB.Bson.IO;
using MongoDB.Bson.Serialization;
using Newtonsoft.Json.Linq;
using WisR.DomainModels;
using WisR.Providers;
using WisRRestAPI.DomainModel;

namespace WisR.Controllers
{
    public class RoomController : Controller
    {
        private IRabbitSubscriber _rabbitSubscriber;

        public RoomController(IRabbitSubscriber rabbitSubscriber)
        {
            _rabbitSubscriber = rabbitSubscriber;
            _rabbitSubscriber.subscribe("CreateChatMessage");
            _rabbitSubscriber.subscribe("CreateQuestion");
        }
        // GET: Room
        public ActionResult Index(string roomId)
        {
            ViewBag.roomId = roomId;
            return View();
        }
        public string toJsonQuestion(string CreatedBy, string RoomId, string Image, string QuestionText, string ResponseOptions, string QuestionResult, string CreationTimestamp, string ExpireTimestamp, string QuetionsType, string Votes)
        {

            var question = new MultipleChoiceQuestion();

            var tempList = new List<ResponseOption>();

            if (!ResponseOptions.IsNullOrWhiteSpace())
            {

                foreach (var response in ResponseOptions.Split(','))
                {
                    tempList.Add(new ResponseOption() { Value = response });
                }

            }
            var tempListResult = new List<Answer>();
            if (!QuestionResult.IsNullOrWhiteSpace())
            {
                foreach (var result in QuestionResult.Split(','))
                {
                    var tempResult = result.Split('-');
                    tempListResult.Add(new Answer() { Value = tempResult[0], UserId = tempResult[1] });
                }
            }

            var tempListVotes = new List<Vote>();
            if (!Votes.IsNullOrWhiteSpace())
            {
                foreach (var vote in Votes.Split(','))
                {
                    var tempVote = vote.Split(':');
                    tempListVotes.Add(new Vote() { CreatedById = tempVote[1], Value = Convert.ToInt16(tempVote[0])});
                }
            }

            question.CreatedById = CreatedBy;
            question.RoomId = RoomId;
            question.Votes = tempListVotes;
            question.Img = Image;
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
            chatMessage.Timestamp = (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds.ToString().Replace(",", ".");
            return chatMessage.ToJson();
        }
    }

}