using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

namespace WisRRestAPI.Controllers
{
    public class ChatController : Controller
    {
        private readonly IChatRepository _cr;
        private readonly JavaScriptSerializer _jsSerializer;
        public ChatController(IChatRepository cr)
        {
            _cr = cr;
            _jsSerializer = new JavaScriptSerializer();
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


        [System.Web.Mvc.HttpPost]
        public string CreateChatMessage(string ChatMessage)
        {
            ChatMessage chatMsg;
            try
            {
                chatMsg = BsonSerializer.Deserialize<ChatMessage>(ChatMessage);
            }
            catch (Exception e)
            {
                return "Could not deserialize chatMessage with json: " + ChatMessage;
            }
            //assign ID to room
            chatMsg.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
            return _cr.AddChatMessage(chatMsg);
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
            var result = _cr.RemoveChatMessage(id).Result;
            if (result.DeletedCount == 1)
            {
                return "ChatMessage was deleted";
            }
            return "Couldn't find ChatMessage to delete";
        }
    }
}