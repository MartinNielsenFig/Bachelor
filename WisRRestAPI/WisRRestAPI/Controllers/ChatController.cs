using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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
    public class ChatController : Controller
    {
        private readonly IRoomRepository _rr;
        private readonly IChatRepository _cr;
        private readonly JavaScriptSerializer _jsSerializer;
        private IRabbitPublisher _irabbitPublisher;

        public ChatController(IChatRepository cr, IRabbitPublisher irabbitPublisher, IRoomRepository rr)
        {
            _rr = rr;
            _cr = cr;
            _jsSerializer = new JavaScriptSerializer();
            _irabbitPublisher = irabbitPublisher;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var ChatMessages = _cr.GetAllChatMessages();
            return ChatMessages.Result.ToJson();
        }
        [System.Web.Mvc.HttpPost]
        public string GetAllByRoomId(string roomId)
        {
            var ChatMessages = _cr.GetAllChatMessagesByRoomId(roomId);
            return ChatMessages.Result.ToJson();
        }


        /// <summary>
        /// Fetches messages for the room specified in the msg parameter that is newer than that message.
        /// </summary>
        /// <param name="msg">A JSON representation of the ChatMessage with room id and timestamp</param>
        /// <returns>A JSON Array with messages newer than parameter message</returns>
        [System.Web.Mvc.HttpPost]
        public string GetNewerMessages(string msg) {
            ChatMessage chatMsg;
            string errorMsg = String.Empty;
            try {
                chatMsg = BsonSerializer.Deserialize<ChatMessage>(msg);
            } catch (Exception e) {
                return e.StackTrace;
            }
            if (!_rr.DoesRoomExist(chatMsg.RoomId)) {
                return "Room doesn't exist;";
            }
            var newerMessages = _cr.GetNewerMessages(chatMsg);
            return newerMessages.ToJson();
        }

        [System.Web.Mvc.HttpPost]
        public string CreateChatMessage(string ChatMessage)
        {
            ChatMessage chatMsg;
            string errorMsg = String.Empty;
            try
            {
                chatMsg = BsonSerializer.Deserialize<ChatMessage>(ChatMessage);
            }
            catch (Exception e)
            {
                return "Could not deserialize chatMessage with json: " + ChatMessage;
            }

            if (!_rr.DoesRoomExist(chatMsg.RoomId)) {
                return "Room doesn't exist;";
            }

            //Assign date to ChatMessage
            chatMsg.Timestamp = TimeHelper.timeSinceEpoch();

            //assign ID to room
            chatMsg.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
            try
            {
                _irabbitPublisher.publishString("CreateChatMessage", chatMsg.ToJson());
            }
            catch (Exception e)
            {
                errorMsg = "Could not publish to rabbitMQ";
            }

            return _cr.AddChatMessage(chatMsg) + errorMsg;
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _cr.GetChatMessage(id);
            if (item == null)
            {
                return "Not found";
            }

            return item.ToJson();
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteChatMessage(string id)
        {
            var result = _cr.DeleteChatMessage(id).Result;
            if (result.DeletedCount == 1)
            {
                return "ChatMessage was deleted";
            }
            return "Couldn't find ChatMessage to delete";
        }
    }
}