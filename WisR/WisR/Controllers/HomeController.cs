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

        public string toJsonRoom(string RoomName, string CreatedBy, int radius, string tag, string password, bool hasChat, bool userCanAsk, bool allowAnonymous, bool useLocation, string locationTimestamp, double locationLatitude, double locationLongitude, int locationAccuracyMeters, string locationFormattedAddress)
        {
            var room = new Room();
            room.Name = RoomName;
            room.CreatedById = CreatedBy;
            room.Location.Timestamp = locationTimestamp;
            room.Location.Latitude = locationLatitude;
            room.Location.Longitude = locationLongitude;
            room.Location.AccuracyMeters = locationAccuracyMeters;
            room.Location.FormattedAddress = locationFormattedAddress;
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
            room.UseLocation = useLocation;
            return new JavaScriptSerializer().Serialize(room);
        }
    }
}