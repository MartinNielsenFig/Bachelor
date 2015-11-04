using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http.Cors;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using WisR.DomainModel;
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

        public RoomController(IRoomRepository rr, IChatRepository cr, IQuestionRepository qr, IRabbitPublisher irabbitPublisher)
        {
            _rr = rr;
            _cr = cr;
            _qr = qr;
            _irabbitPublisher = irabbitPublisher;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            Task<List<Room>> Rooms;
            try
            {
                Rooms = _rr.GetAllRooms();
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetRoomsFromDatabase);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
          
            return new Notification(Rooms.Result.ToJson(), ErrorTypes.Ok, errors).ToJson(); ;
        }
        [System.Web.Mvc.HttpPost]
        public string CreateRoom(string Room)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Room room;
            try
            {
                room = BsonSerializer.Deserialize<Room>(Room);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.StringIsNotJsonFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            //assign ID to room
            room.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

            //Check that the secret doesn't already exist
            var returnValue = BsonSerializer.Deserialize<Notification>(GetByUniqueSecret(room.Secret));
            if (returnValue.ErrorType == ErrorTypes.Ok)
            {
                errors.Add(ErrorCodes.RoomSecretAlreadyInUse);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            string roomId;
            try
            {
                roomId = _rr.AddRoom(room);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.CouldNotAddRoomToDatabase);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();

            }
            //Publish to rabbitMQ after, because we need the id
            string error = String.Empty;
            try
            {
                _irabbitPublisher.publishString("CreateRoom", room.ToJson());
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RabbitMqError);
                errorType = ErrorTypes.Complicated;
            }

            return new Notification(roomId, errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string GetById(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            var item = new Room();
            try
            {
                item = _rr.GetRoom(id).Result;
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RoomSecretAlreadyInUse);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            if (item == null)
            {
                //var err = new Error("Not found", 100);
                return "";// err.ToJson();
            }

            return item.ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string GetByUniqueSecret(string secret)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            Room item;
            try
            {
                item = _rr.GetRoomBySecret(secret).Result;
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.NoRoomWithThatSecret);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            if (item == null)
            {
                errors.Add(ErrorCodes.NoRoomWithThatSecret);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(item.ToJson(), ErrorTypes.Ok, errors).ToJson();
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
                _irabbitPublisher.publishString("DeleteRoom", id);
                return "Room was deleted";
            }
            //var err = new Error("Couldn't find the room to delete", 100);
            return "";//err.ToJson();
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
                //var err = new Error("Couldn't get room by that id", 100, e.StackTrace);
                return "";// err.ToJson();
            }

            Coordinate tempCoord = null;
            try
            {
                tempCoord = BsonSerializer.Deserialize<Coordinate>(location);
            }
            catch (Exception e)
            {
                //var err = new Error("Could not deserialize", 100, e.StackTrace);
                return "";// err.ToJson();
            }


            item.Location = tempCoord;

            try
            {
                _rr.UpdateRoom(id, item);
            }
            catch (Exception e)
            {
                //var err = new Error("Could not update", 100, e.StackTrace);
                return "";// err.ToJson();
            }
            //Publish to rabbitMQ after, because we need the id
            try
            {
                _irabbitPublisher.publishString("UpdateRoom", item.ToJson());
            }
            catch (Exception e)
            {
                //var err = new Error("Could not publish to RabbitMq", 100, e.StackTrace);
                return "";// err.ToJson();
            }
            return "";
        }

        /// <summary>
        /// Determine whether a room is present in a given moment. Used to check that you are not inside a room that has been deleted.  
        /// </summary>
        /// <param name="roomId">The id of the room to check if exists.</param>
        /// <returns>Whether or not the room exists.</returns>
        [HttpPost]
        public bool RoomExists(string roomId)
        {
            return _rr.DoesRoomExist(roomId);
        }
    }
}