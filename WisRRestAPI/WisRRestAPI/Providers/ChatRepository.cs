using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MongoDB.Bson;
using MongoDB.Driver;
using WisR.DomainModel;
using WisRRestAPI.DomainModel;
using MongoDB.Bson.Serialization;

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

        public Task<List<ChatMessage>> GetAllChatMessagesByRoomId(string roomId)
        {
            var chatMessages = _database.GetCollection<ChatMessage>("chatmessage").Find(x => x.RoomId==roomId).ToListAsync();
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

        public Task<DeleteResult> DeleteChatMessage(string id)
        {
            var task = _database.GetCollection<ChatMessage>("chatmessage").DeleteOneAsync(x => x.Id == id);
            return task;
        }

        public Task<DeleteResult> DeleteAllChatMessageForRoomWithRoomId(string roomId)
        {
            var task = _database.GetCollection<ChatMessage>("chatmessage").DeleteManyAsync(x => x.RoomId == roomId);
            return task;
        }

        public Task<ChatMessage> UpdateChatMessage(string id, ChatMessage item)
        {
            var task = _database.GetCollection<ChatMessage>("chatmessage").FindOneAndReplaceAsync(x => x.Id == id, item);
            return task;
        }

        public List<ChatMessage> GetNewerMessages(ChatMessage msg) {

            //Gt = GreaterThan
            var filter = Builders<BsonDocument>.Filter.Gt("Timestamp", msg.Timestamp);
            var bsonDocumentList = _database.GetCollection<BsonDocument>("chatmessage").Find(filter).ToListAsync();

            List<ChatMessage> chatMessagesList = new List<ChatMessage>();
            foreach (BsonDocument doc in bsonDocumentList.Result) {
                chatMessagesList.Add(BsonSerializer.Deserialize<ChatMessage>(doc));
            }

            return chatMessagesList;
        }
    }
}