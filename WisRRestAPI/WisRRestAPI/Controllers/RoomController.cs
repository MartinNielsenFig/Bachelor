using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http.Cors;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Controllers {
    public class RoomController : Controller {
        private readonly IRoomRepository _rr;
        private readonly JavaScriptSerializer _jsSerializer;
        public RoomController(IRoomRepository rr) {
            _rr = rr;
            _jsSerializer = new JavaScriptSerializer();
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll() {
            var Rooms = _rr.GetAllRooms();
            return _jsSerializer.Serialize(Rooms.Result);
        }
        [System.Web.Mvc.HttpPost]
        public string CreateRoom(string Room) {
            Room room;
            try {
                room = _jsSerializer.Deserialize<Room>(Room);
            } catch (Exception) {
                return "Could not deserialize room with json: " + Room;
            }

            string roomId;
            try {
                roomId = _rr.AddRoom(room);
            } catch (Exception) {
                return "Could not add room";
            }

            return roomId;
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id) {
            var item = _rr.GetRoom(id);
            if (item == null) {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteRoom(string id) {
            var result = _rr.RemoveRoom(id).Result;
            if (result.DeletedCount == 1) {
                return "Room was deleted";
            }
            return "Couldn't find Room to delete";
        }
    }
}