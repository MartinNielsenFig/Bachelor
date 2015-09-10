using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.IO;
using MongoDB.Bson.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisR.Controllers
{
    public class RoomController : Controller
    {
        // GET: Room
        public ActionResult Index(string roomId)
        {
            ViewBag.roomId = roomId;
            return View();
        }
        public string toJsonQuestion(string CreatedBy,string RoomId, int Downvotes, string Image, int Upvotes, string QuestionText)
        {
            var question = new TextualQuestion();
            question.CreatedById = CreatedBy;
            question.RoomId = RoomId;
            question.Downvotes = Downvotes;
            question.Img = Image;
            question.Upvotes = Upvotes;
            question.QuestionText = QuestionText;
            question.ResponseOptions=new List<ResponseOption>();
            question.Result=new List<Answer>();

            return question.ToJson(); ;
        }
        public string toJsonChatMessage(string userId,string roomId,string text)
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