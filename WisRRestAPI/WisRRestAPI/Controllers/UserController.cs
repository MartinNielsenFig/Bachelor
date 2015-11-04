﻿using System;
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

        //Creates an user on MongoDB from User with facebook ID, then returns MongoDB ID.
        //If user already exists, returns MongoDB ID.
        [System.Web.Mvc.HttpPost]
        public string CreateUser(string User)
        {
            var userToAdd = BsonSerializer.Deserialize<User>(User);

            //Add more for other systems than facebook
            IEnumerable<User> user = null;
            if (userToAdd.FacebookId != null)
            {
                    user = _ur.GetAllUsers().Result.Where(x => x.FacebookId == userToAdd.FacebookId);               
                
            }else if (userToAdd.LDAPUserName!=null)
            {
                user = _ur.GetAllUsers().Result.Where(x => x.LDAPUserName == userToAdd.LDAPUserName);
            }
           
            if (user==null||!user.Any())
            {
                userToAdd.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();
                return _ur.AddUser(userToAdd);
            }
            else
            {
                return user.First().Id;
            }
            
        }

        [System.Web.Mvc.HttpPost]
        public void UpdateUser(string User,string Id)
        {
            var user = BsonSerializer.Deserialize<User>(User);
            user.Id = Id;
            _ur.UpdateUser(user.Id, user);
        }

        [System.Web.Mvc.HttpPost]
        public string GetById(string id)
        {
            if (id == null)
            {
                return "No user with null as id";
            }

            User item;
            try {
                item = _ur.GetUser(id).Result;
            }
            catch (Exception e) {
                return e.StackTrace;
            }
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

        [System.Web.Mvc.HttpPost]
        public string GetWisrIdFromFacebookId(string facebookId)
        {
            return _ur.GetWisrIdFromFacebookId(facebookId);
        }
    }
}