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

namespace WisRRestAPI.Controllers
{
    public class UserController : Controller
    {
        private readonly IUserRepository _ur;
        public UserController(IUserRepository ur)
        {
            _ur = ur;
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var Users = _ur.GetAllUsers();
            return Users.Result.ToJson();
        }

        [System.Web.Mvc.HttpPost]
        public string CreateUser(string User)
        {
            var userToAdd = BsonSerializer.Deserialize<User>(User);
            //Add more for other systems than facebook
            var  user = _ur.GetAllUsers().Result.Where(x => x.FacebookId == userToAdd.FacebookId);
            if (user.Count() == 0)
            {
                userToAdd.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
                return _ur.AddUser(userToAdd);
            }
            else
            {
                return user.First().Id;
            }
            
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _ur.GetUser(id);
            if (item == null)
            {
                return "Not found";
            }

            return item.ToJson();
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteUser(string id)
        {
            var result = _ur.RemoveUser(id).Result;
            if (result.DeletedCount == 1)
            {
                return "User was deleted";
            }
            return "Couldn't find User to delete";
        }
    }
}