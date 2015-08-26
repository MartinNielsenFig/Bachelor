using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Controllers
{
    public class RoomController : Controller
    {
        private readonly IRoomRepository _RR;
        private readonly JavaScriptSerializer _jsSerializer;
        public RoomController()
        {
            _RR = new RoomRepository("");
            _jsSerializer = new JavaScriptSerializer();
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var Rooms = _RR.GetAllRooms();
            return _jsSerializer.Serialize(Rooms.Result);
        }

        [System.Web.Mvc.HttpPost]
        public void CreateRoom(string Room)
        {
            _RR.AddRoom(_jsSerializer.Deserialize<Room>(Room));
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _RR.GetRoom(id);
            if (item == null)
            {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteRoom(string id)
        {
            var result = _RR.RemoveRoom(id).Result;
            if (result.DeletedCount == 1)
            {
                return "Room was deleted";
            }
            return "Couldn't find Room to delete";
        }
    }
}