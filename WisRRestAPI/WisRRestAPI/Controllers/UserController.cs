using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Controllers
{
    public class UserController : Controller
    {
        private readonly IUserRepository _UR;
        private readonly JavaScriptSerializer _jsSerializer;
        public UserController()
        {
            _UR = new UserRepository("");
            _jsSerializer = new JavaScriptSerializer();
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var Users = _UR.GetAllUsers();
            return _jsSerializer.Serialize(Users.Result);
        }

        [System.Web.Mvc.HttpPost]
        public void CreateUser(string User)
        {
            _UR.AddUser(_jsSerializer.Deserialize<User>(User));
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _UR.GetUser(id);
            if (item == null)
            {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
        }
        [System.Web.Mvc.HttpDelete]
        public string DeleteUser(string id)
        {
            var result = _UR.RemoveUser(id).Result;
            if (result.DeletedCount == 1)
            {
                return "User was deleted";
            }
            return "Couldn't find User to delete";
        }
    }
}