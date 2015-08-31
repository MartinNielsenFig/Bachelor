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
    public class UserRepository:IUserRepository
    {
        private readonly IMongoDatabase _database;
        public UserRepository(IdbHandler dbHandler)
        {
            _database = dbHandler.getDb();
        }
        public Task<List<User>> GetAllUsers()
        {
            var Users = _database.GetCollection<User>("User").Find(_ => true).ToListAsync();
            return Users;
        }

        public Task<User> GetUser(string id)
        {
            var User = _database.GetCollection<User>("User").Find(x => x.Id == ObjectId.Parse(id)).SingleAsync();
            return User;
        }

        public void AddUser(User item)
        {
            _database.GetCollection<User>("User").InsertOneAsync(item);
        }

        public Task<DeleteResult> RemoveUser(string id)
        {
            var task = _database.GetCollection<User>("User").DeleteOneAsync(x => x.Id == ObjectId.Parse(id));
            return task;
        }

        public Task<User> UpdateUser(string id, User item)
        {
            var task = _database.GetCollection<User>("user").FindOneAndReplaceAsync(x => x.Id == ObjectId.Parse(id), item);
            return task;
        }
    }
}