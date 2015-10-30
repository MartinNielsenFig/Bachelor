using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using MongoDB.Bson;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public class RoomRepository:IRoomRepository
    {
        private readonly IMongoDatabase _database;
        public RoomRepository(IdbHandler dbHandler)
        {
            _database = dbHandler.getDb();
        }
        public Task<List<Room>> GetAllRooms()
        {
            var rooms = _database.GetCollection<Room>("room").Find(_ => true).ToListAsync();
            return rooms;
        }

        public Task<Room> GetRoom(string id)
        {
            var room = _database.GetCollection<Room>("room").Find(x => x.Id == id).SingleAsync();
            return room;
        }

        public Task<Room> GetRoomBySecret(string secret)
        {
            var room = _database.GetCollection<Room>("room").Find(x => x.Secret == secret).SingleAsync();
            return room;
        }

        public string AddRoom(Room item)
        {
            _database.GetCollection<Room>("room").InsertOneAsync(item).Wait();
            return item.Id;

        }

        public Task<DeleteResult> DeleteRoom(string id)
        {
            var task = _database.GetCollection<Room>("room").DeleteOneAsync(x => x.Id == id);
            return task;
        }

        public Task<Room> UpdateRoom(string id, Room item)
        {
            var task = _database.GetCollection<Room>("room").FindOneAndReplaceAsync(x => x.Id == id, item);
            return task;
        }

        public bool DoesRoomExist(string id) {
            return _database.GetCollection<Room>("room").Find(x => x.Id == id).ToListAsync().Result.Count == 1;
        }
    }
}