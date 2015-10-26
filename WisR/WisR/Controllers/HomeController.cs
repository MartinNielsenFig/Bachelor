using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using Microsoft.Ajax.Utilities;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Bson;
using WisR.DomainModels;
using WisR.Helper;
using WisR.Providers;

namespace WisR.Controllers
{
    public class HomeController : BaseController
    {
        private IRabbitSubscriber _rabbitHandler;

        public HomeController(IRabbitSubscriber rabbitHandler)
        {
            _rabbitHandler = rabbitHandler;
            _rabbitHandler.subscribe("CreateRoom");
        }

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

        public string toJsonRoom(string RoomName, string CreatedBy, int radius, string secret, string password, bool hasChat, bool userCanAsk, bool allowAnonymous, bool useLocation, string locationTimestamp, double locationLatitude, double locationLongitude, int locationAccuracyMeters, string locationFormattedAddress)
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
            room.Secret = secret;
            if (!password.IsNullOrWhiteSpace())
            {
                room.EncryptedPassword = password;
                room.HasPassword = true;
            }
            room.HasChat = hasChat;
            room.UsersCanAsk = userCanAsk;
            room.AllowAnonymous = allowAnonymous;
            room.UseLocation = useLocation;
            return room.ToJson();
        }
        public string toJsonUser(string encryptedPassword, string facebookId, string lDAPUserName, string displayName, string email, string connectedRoomIds)
        {
            var user = new User();

            var tempList = new List<string>();

            if (connectedRoomIds !=null)
            {
                foreach (var id in connectedRoomIds.Split(','))
                {
                    tempList.Add(id);
                }
            }
           
            user.FacebookId = facebookId;
            user.LDAPUserName = lDAPUserName;
            user.DisplayName = displayName;
            user.Email = email;
            user.EncryptedPassword = encryptedPassword;
            user.ConnectedRoomIds = tempList;
           
            return user.ToJson();
        }
        public ActionResult ChangeCurrentCulture(int id)
        {
            //  
            // Change the current culture for this user.  
            //  
            CultureHelper.CurrentCulture = id;
            //  
            // Cache the new current culture into the user HTTP session.   
            //  
            Session["CurrentCulture"] = id;
            //  
            // Redirect to the same page from where the request was made!   
            //  
            return Redirect(Request.UrlReferrer.ToString());
        }
    }
}