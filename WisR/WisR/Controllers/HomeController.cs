using System.Collections.Generic;
using System.Web.Mvc;
using Microsoft.Ajax.Utilities;
using MongoDB.Bson;
using WisR.DomainModels;
using WisR.Helper;
using WisR.Providers;

namespace WisR.Controllers
{
    public class HomeController : BaseController
    {
        private readonly IRabbitSubscriber _rabbitHandler;

        public HomeController(IRabbitSubscriber rabbitHandler)
        {
            _rabbitHandler = rabbitHandler;
            _rabbitHandler.subscribe("CreateRoom");
        }

        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        ///     Function that takes all room parameters and creates a room based on the parameters
        /// </summary>
        /// <param name="RoomName">Name of the room.</param>
        /// <param name="CreatedBy">The created by.</param>
        /// <param name="radius">The radius.</param>
        /// <param name="secret">The secret.</param>
        /// <param name="password">The password.</param>
        /// <param name="hasChat">if set to <c>true</c> [has chat].</param>
        /// <param name="userCanAsk">if set to <c>true</c> [user can ask].</param>
        /// <param name="allowAnonymous">if set to <c>true</c> [allow anonymous].</param>
        /// <param name="useLocation">if set to <c>true</c> [use location].</param>
        /// <param name="locationTimestamp">The location timestamp.</param>
        /// <param name="locationLatitude">The location latitude.</param>
        /// <param name="locationLongitude">The location longitude.</param>
        /// <param name="locationAccuracyMeters">The location accuracy meters.</param>
        /// <param name="locationFormattedAddress">The location formatted address.</param>
        /// <returns></returns>
        public string toJsonRoom(string RoomName, string CreatedBy, int radius, string secret, string password,
            bool hasChat, bool userCanAsk, bool allowAnonymous, bool useLocation, string locationTimestamp,
            double locationLatitude, double locationLongitude, int locationAccuracyMeters,
            string locationFormattedAddress)
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

        /// <summary>
        ///     To the json user.
        /// </summary>
        /// <param name="encryptedPassword">The encrypted password.</param>
        /// <param name="facebookId">The facebook identifier.</param>
        /// <param name="lDAPUserName">Name of the l dap user.</param>
        /// <param name="displayName">The display name.</param>
        /// <param name="email">The email.</param>
        /// <param name="connectedRoomIds">The connected room ids.</param>
        /// <returns></returns>
        public string toJsonUser(string encryptedPassword, string facebookId, string lDAPUserName, string displayName,
            string email, string connectedRoomIds)
        {
            var user = new User();

            var tempList = new List<string>();

            if (connectedRoomIds != null)
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