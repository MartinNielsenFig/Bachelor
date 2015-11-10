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


            return (new Notification(Rooms.Result.ToJson(), errorType, errors)).ToJson(); ;
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
                errors.Add(ErrorCodes.RoomDoesNotExist);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            if (item == null)
            {
                errors.Add(ErrorCodes.RoomDoesNotExist);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(item.ToJson(), errorType, errors).ToJson();
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

            return new Notification(item.ToJson(), errorType, errors).ToJson();
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteRoom(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            try
            {
                var chatDeleteResult = _cr.DeleteAllChatMessageForRoomWithRoomId(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotDeleteAllChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            try
            {
                var questionDeleteResult = _qr.DeleteAllQuestionsForRoomWithRoomId(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotDeleteAllQuestions);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }


            var result = _rr.DeleteRoom(id).Result;

            if (result.DeletedCount == 1)
            {
                try
                {
                    _irabbitPublisher.publishString("DeleteRoom", id);
                }
                catch (Exception)
                {
                    errors.Add(ErrorCodes.RabbitMqError);
                    errorType = ErrorTypes.Complicated;
                }

                return new Notification("Room was deleted", errorType, errors).ToJson(); ;
            }
            errors.Add(ErrorCodes.CouldNotDeleteRoom);
            return new Notification(null, ErrorTypes.Error, errors).ToJson();
        }

        public string UpdateLocation(string id, string location)
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
                errors.Add(ErrorCodes.CouldNotGetRoomsFromDatabase);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            Coordinate tempCoord = null;
            try
            {
                tempCoord = BsonSerializer.Deserialize<Coordinate>(location);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }


            item.Location = tempCoord;

            try
            {
                _rr.UpdateRoom(id, item);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.CouldNotUpdateRoom);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            //Publish to rabbitMQ after, because we need the id
            try
            {
                _irabbitPublisher.publishString("UpdateRoom", item.ToJson());
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RabbitMqError);
                errorType = ErrorTypes.Complicated;
            }
            return new Notification(null, errorType, errors).ToJson();
        }

        /// <summary>
        /// Determine whether a room is present in a given moment. Used to check that you are not inside a room that has been deleted.  
        /// </summary>
        /// <param name="roomId">The id of the room to check if exists.</param>
        /// <returns>Whether or not the room exists.</returns>
        [HttpPost]
        public string RoomExists(string roomId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            var returnValue =false;
            try
            {
                returnValue = _rr.DoesRoomExist(roomId);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotUpdateRoom);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            return new Notification(returnValue.ToString(), ErrorTypes.Ok, errors).ToJson();
        }
    }
}