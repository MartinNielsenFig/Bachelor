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
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    public class RoomController : Controller
    {
        private readonly IRoomRepository _rr;
        private readonly IQuestionRepository _qr;
        private readonly IChatRepository _cr;
        private IRabbitPublisher _irabbitPublisher;

        public RoomController(IRoomRepository rr,IChatRepository cr,IQuestionRepository qr, IRabbitPublisher irabbitPublisher)
        {
            _rr = rr;
            _cr = cr;
            _qr = qr;
            _irabbitPublisher = irabbitPublisher;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var Rooms = _rr.GetAllRooms();
            return Rooms.Result.ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string CreateRoom(string Room)
        {
            Room room;
            try
            {
                room = BsonSerializer.Deserialize<Room>(Room);
            }
            catch (Exception e)
            {
                var err = new Error("Could not deserialize room with json: " + Room, 100, e.StackTrace);
                return err.ToJson();
            }
            //assign ID to room
            room.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

            //Check that the secret doesn't already exist
            var returnValue = GetByUniqueSecret(room.Secret);
            try
            {
                var errorFromDb = BsonSerializer.Deserialize<Error>(returnValue);
            }
            catch (Exception e)
            {
                var err = new Error("Room with that secret already exists", (int) ErrorCodes.RoomSecretAlreadyInUse);
                return err.ToJson();
            }

            string roomId;
            try
            {
                roomId = _rr.AddRoom(room);
            }
            catch (Exception e)
            {
                var err = new Error("Could not add room", 100, e.StackTrace);
                return err.ToJson();

            }
            //Publish to rabbitMQ after, because we need the id
            string error = String.Empty;
            try
            {
                _irabbitPublisher.publishString("CreateRoom", room.ToJson());
            }
            catch (Exception e)
            {
                error = new Error("Could not publish to RabbitMq", (int) ErrorCodes.RabbitMqError, e.StackTrace).ToJson();
            }

            return roomId + ";" + error;
        }

        [System.Web.Mvc.HttpPost]
        public string GetById(string id)
        {
            var item = new Room();
            try
            {
                item = _rr.GetRoom(id).Result;
            }
            catch (Exception e)
            {
                var err = new Error("Couldn't get room by that id", 100, e.StackTrace);
                return err.ToJson();
            }

            if (item == null)
            {
                var err = new Error("Not found", 100);
                return err.ToJson();
            }

            return item.ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string GetByUniqueSecret(string secret)
        {
            Room item;
            try
            {
                item = _rr.GetRoomBySecret(secret).Result;
            }
            catch (Exception e)
            {
                if (e.InnerException.Message == "Sequence contains no elements")
                {
                    var err = new Error("No room with that secret", 100, e.StackTrace);
                    return err.ToJson();
                }
                var err2 = new Error("Something went wrong trying to find room with that id, check stacktrace", 100, e.StackTrace);
                return err2.ToJson();
            }

            if (item == null)
            {
                var err = new Error("No room with that secret", 100);
                return err.ToJson();
            }

            return item.ToJson();
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteRoom(string id)
        {
            //Todo error checking on all these
            var chatDeleteResult = _cr.DeleteAllChatMessageForRoomWithRoomId(id).Result;
            var questionDeleteResult = _qr.DeleteAllQuestionsForRoomWithRoomId(id).Result;

            var result = _rr.DeleteRoom(id).Result;
            if (result.DeletedCount == 1)
            {
                _irabbitPublisher.publishString("DeleteRoom",id);
                return "Room was deleted";
            }
            var err = new Error("Couldn't find the room to delete", 100);
            return err.ToJson();
        }

        public string UpdateLocation(string id, string location)
        {
            var item = new Room();

            try
            {
                item = _rr.GetRoom(id).Result;
            }
            catch (Exception e)
            {
                var err = new Error("Couldn't get room by that id", 100, e.StackTrace);
                return err.ToJson();
            }

            Coordinate tempCoord = null;
            try
            {
                tempCoord = BsonSerializer.Deserialize<Coordinate>(location);
            }
            catch (Exception e)
            {
                var err = new Error("Could not deserialize", 100, e.StackTrace);
                return err.ToJson();
            }
           

            item.Location = tempCoord;

            try
            {
                _rr.UpdateRoom(id, item);
            }
            catch (Exception e)
            {
                var err = new Error("Could not update", 100, e.StackTrace);
                return err.ToJson();
            }
            //Publish to rabbitMQ after, because we need the id
            try
            {
                _irabbitPublisher.publishString("UpdateRoom", item.ToJson());
            }
            catch (Exception e)
            {
                var err = new Error("Could not publish to RabbitMq", 100, e.StackTrace);
                return err.ToJson();
            }
            return "";
        }
    }
}