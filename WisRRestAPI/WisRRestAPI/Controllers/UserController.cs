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
        private readonly IUserRepository _ur;
        private readonly JavaScriptSerializer _jsSerializer;
        public UserController(IUserRepository ur)
        {
            _ur = ur;
            _jsSerializer = new JavaScriptSerializer();
        }

        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            var Users = _ur.GetAllUsers();
            return _jsSerializer.Serialize(Users.Result);
        }

        [System.Web.Mvc.HttpPost]
        public string CreateUser(string User)
        {
            return _ur.AddUser(_jsSerializer.Deserialize<User>(User));
        }

        [System.Web.Mvc.HttpGet]
        public string GetById(string id)
        {
            var item = _ur.GetUser(id);
            if (item == null)
            {
                return "Not found";
            }

            return _jsSerializer.Serialize(item);
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