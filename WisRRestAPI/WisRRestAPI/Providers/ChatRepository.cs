using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MongoDB.Bson;
using MongoDB.Driver;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Providers
{
    public class ChatRepository : IChatRepository
    {
        private readonly IMongoDatabase _database;
        public ChatRepository(IdbHandler dbHandler)
        {
            _database = dbHandler.getDb();
        }
        public Task<List<ChatMessage>> GetAllChatMessages()
        {
            var chatMessages = _database.GetCollection<ChatMessage>("chatmessage").Find(_ => true).ToListAsync();
            return chatMessages;
        }

        public Task<ChatMessage> GetChatMessage(string id)
        {
            var chatMessage =
                _database.GetCollection<ChatMessage>("chatmessage").Find(x => x.Id == id).SingleAsync();
            return chatMessage;
        }

        public string AddChatMessage(ChatMessage item)
        {
            _database.GetCollection<ChatMessage>("chatmessage").InsertOneAsync(item).Wait();
            return item.Id.ToString();
        }

        public Task<DeleteResult> RemoveChatMessage(string id)
        {
            var task = _database.GetCollection<ChatMessage>("chatmessage").DeleteOneAsync(x => x.Id == id);
            return task;
        }

        public Task<ChatMessage> UpdateChatMessage(string id, ChatMessage item)
        {
            var task = _database.GetCollection<ChatMessage>("chatmessage").FindOneAndReplaceAsync(x => x.Id == id, item);
            return task;
        }
    }
}