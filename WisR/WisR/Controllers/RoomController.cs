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
        public string toJsonQuestion(string CreatedBy, int Downvotes, string Image, int Upvotes, string QuestionText)
        {
            var question = new TextualQuestion();
            question.CreatedById = "test";
            question.Downvotes = Downvotes;
            question.Img = Image;
            question.Upvotes = Upvotes;
            question.QuestionText = QuestionText;
            question.ResponseOptions=new List<ResponseOption>();
            question.Result=new List<Answer>();



            return question.ToJson(); ;
        }
    }

}