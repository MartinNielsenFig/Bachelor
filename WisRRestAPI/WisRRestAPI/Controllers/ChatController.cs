using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;
using WisR.DomainModel;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    /// <summary>
    /// The chat controller is used to handle the chat CRUD's
    /// </summary>
    public class ChatController : Controller
    {
        private readonly IRoomRepository _rr;
        private readonly IChatRepository _cr;
        private IRabbitPublisher _irabbitPublisher;

        /// <summary>
        /// Initializes a new instance of the <see cref="ChatController"/> class.
        /// </summary>
        /// <param name="cr">The chat repository.</param>
        /// <param name="irabbitPublisher">The rabbitMQ publisher.</param>
        /// <param name="rr">The room repository.</param>
        public ChatController(IChatRepository cr, IRabbitPublisher irabbitPublisher, IRoomRepository rr)
        {
            _rr = rr;
            _cr = cr;
            _irabbitPublisher = irabbitPublisher;
        }

        /// <summary>
        /// Gets all.
        /// </summary>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<List<ChatMessage>> chatMessages;
            try
            {
               chatMessages = _cr.GetAllChatMessages();
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            return new Notification(chatMessages.Result.ToJson(), errorType, errors).ToJson();
        }
        /// <summary>
        /// Gets all by room identifier.
        /// </summary>
        /// <param name="roomId">The room identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string GetAllByRoomId(string roomId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<List<ChatMessage>> chatMessages;
            try
            {
                chatMessages = _cr.GetAllChatMessagesByRoomId(roomId);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(chatMessages.Result.ToJson(), errorType, errors).ToJson();
        }
        /// <summary>
        /// Fetches messages for the room specified in the msg parameter that is newer than that message.
        /// </summary>
        /// <param name="msg">A JSON representation of the ChatMessage with room id and timestamp</param>
        /// <returns>A JSON Array with messages newer than parameter message</returns>
        [System.Web.Mvc.HttpPost]
        public string GetNewerMessages(string msg) {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            ChatMessage chatMsg;
            string errorMsg = String.Empty;
            try {
                chatMsg = BsonSerializer.Deserialize<ChatMessage>(msg);
            } catch (Exception e) {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            if (!_rr.DoesRoomExist(chatMsg.RoomId)) {
                errors.Add(ErrorCodes.RoomDoesNotExist);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            List<ChatMessage> newerMessages;
            try
            {
                newerMessages = _cr.GetNewerMessages(chatMsg);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(newerMessages.ToJson(), errorType, errors).ToJson();
        }

        /// <summary>
        /// Creates the chat message.
        /// </summary>
        /// <param name="ChatMessage">The chat message.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string CreateChatMessage(string ChatMessage)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            ChatMessage chatMsg;
            string errorMsg = String.Empty;
            try
            {
                chatMsg = BsonSerializer.Deserialize<ChatMessage>(ChatMessage);
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            if (!_rr.DoesRoomExist(chatMsg.RoomId)) {
                errors.Add(ErrorCodes.RoomDoesNotExist);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            //Assign date to ChatMessage
            chatMsg.Timestamp = TimeHelper.timeSinceEpoch();

            try
            {
                _cr.AddChatMessage(chatMsg);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            

            //assign ID to room
            chatMsg.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
            try
            {
                _irabbitPublisher.publishString("CreateChatMessage", chatMsg.ToJson());
            }
            catch (Exception e)
            {
                errors.Add(ErrorCodes.RoomDoesNotExist);
               errorType = ErrorTypes.Complicated;
            }

            return new Notification(null, errorType, errors).ToJson(); 
        }

        /// <summary>
        /// Gets by identifier.
        /// </summary>
        /// <param name="id">The identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            Task<ChatMessage> item;
            try
            {
 item = _cr.GetChatMessage(id);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            if (item == null)
            {
                errors.Add(ErrorCodes.CouldNotGetChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(item.ToJson(), errorType, errors).ToJson();
        }
        /// <summary>
        /// Deletes the chat message by identifier.
        /// </summary>
        /// <param name="id">The identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpDelete]
        public string DeleteChatMessage(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            DeleteResult result;
            try
            {
                result = _cr.DeleteChatMessage(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotDeleteAllChatMessages);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            
            if (result.DeletedCount == 1)
            {
                return new Notification(null, errorType, errors).ToJson();
            }
            errors.Add(ErrorCodes.CouldNotDeleteAllChatMessages);
            return new Notification(null, ErrorTypes.Error, errors).ToJson();
        }
    }
}