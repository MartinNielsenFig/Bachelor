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
            var User = _database.GetCollection<User>("User").Find(x => x.Id == id).SingleAsync();
            return User;
        }

        public string AddUser(User item)
        {
            _database.GetCollection<User>("User").InsertOneAsync(item).Wait();
            return item.Id;
        }

        public Task<DeleteResult> RemoveUser(string id)
        {
            var task = _database.GetCollection<User>("User").DeleteOneAsync(x => x.Id == id);
            return task;
        }

        public Task<User> UpdateUser(string id, User item)
        {
            var task = _database.GetCollection<User>("user").FindOneAndReplaceAsync(x => x.Id == id, item);
            return task;
        }
    }
}