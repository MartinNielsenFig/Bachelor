using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Bson;
using WisR.DomainModels;

namespace WisR.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public string toJsonRoom(string RoomName,string CreatedBy,object[] location, int radius, string tag,string password,bool hasChat,bool userCanAsk,bool allowAnonymous)
        {
            var room = new Room();
            room.Name = RoomName;
            room.CreatedById = CreatedBy;
            //room.Location = location;
            room.Radius = radius;
            room.Tag = tag;
            if (password != null)
            {
                room.EncryptedPassword = password;
                room.HasPassword = true;
            }
            room.HasChat = hasChat;
            room.UsersCanAsk = userCanAsk;
            room.AllowAnonymous = allowAnonymous;
            return new JavaScriptSerializer().Serialize(room);
        }
    }
}