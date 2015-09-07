using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http.Cors;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Controllers {
    public class RoomController : Controller {
        private readonly IRoomRepository _rr;
        public RoomController(IRoomRepository rr) {
            _rr = rr;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll() {
            var Rooms = _rr.GetAllRooms();
            return Rooms.Result.ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string CreateRoom(string Room) {
            Room room;
            try {
                room = BsonSerializer.Deserialize<Room>(Room);
            } catch (Exception e) {
                return "Could not deserialize room with json: " + Room;
            }
            //assign ID to room
            room.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

            string roomId;
            try {
                roomId = _rr.AddRoom(room);
            } catch (Exception e) {
                return "Could not add room";
            }

            return roomId;
        }

        [System.Web.Mvc.HttpPost]
        public string GetById(string id) {
            var item = _rr.GetRoom(id).Result;
            if (item == null) {
                return "Not found";
            }

            return item.ToJson();
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