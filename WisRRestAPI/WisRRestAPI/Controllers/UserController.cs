using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;
using WisR.DomainModel;
using WisR.DomainModels;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Controllers
{
    /// <summary>
    /// The user controller is used to handle the user CRUD's
    /// </summary>
    public class UserController : Controller
    {
        private readonly IUserRepository _ur;
        /// <summary>
        /// Initializes a new instance of the <see cref="UserController"/> class.
        /// </summary>
        /// <param name="ur">The user repository.</param>
        public UserController(IUserRepository ur)
        {
            _ur = ur;
        }

        /// <summary>
        /// Gets all.
        /// </summary>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpGet]
        public string GetAll()
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            Task<List<User>> Users;
            try
            {
                Users = _ur.GetAllUsers();
        }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotGetUsers);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            errors.Add(ErrorCodes.CouldNotUpdateRoom);
            return new Notification(Users.Result.ToJson(), errorType, errors).ToJson();
        }


        /// <summary>
        /// Creates an user on MongoDB from User with facebook ID.
        /// If user already exists, returns MongoDB ID.
        /// </summary>
        /// <param name="User">The user.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string CreateUser(string User)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            User userToAdd;
            try
            {
                userToAdd = BsonSerializer.Deserialize<User>(User);
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.StringIsNotJsonFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }


            //Add more for other systems than facebook
            IEnumerable<User> user = null;
            if (userToAdd.FacebookId != null)
            {
                try
                {
                    user = _ur.GetAllUsers().Result.Where(x => x.FacebookId == userToAdd.FacebookId);               
                }
                catch (Exception)
            {
                    errors.Add(ErrorCodes.CouldNotGetUsers);
                    return new Notification(null, ErrorTypes.Error, errors).ToJson();
                }
            }
            else if (userToAdd.LDAPUserName != null)
            {
                try
                {
                user = _ur.GetAllUsers().Result.Where(x => x.LDAPUserName == userToAdd.LDAPUserName);
            }
                catch (Exception)
                {
                    errors.Add(ErrorCodes.CouldNotGetUsers);
                    return new Notification(null, ErrorTypes.Error, errors).ToJson();
                }
            }
           
            if (user == null || !user.Any())
            {
                userToAdd.Id = ObjectId.GenerateNewId(DateTime.Now).ToString();

                var userId = "";
                try
                {
                    userId = _ur.AddUser(userToAdd);
            }
                catch (Exception)
                {
                    errors.Add(ErrorCodes.CouldNotAddUser);
                    return new Notification(null, ErrorTypes.Error, errors).ToJson();
                }
                return new Notification(userId, errorType, errors).ToJson();
            }
            else
            {
                return new Notification(user.First().Id, errorType, errors).ToJson();
            }
            
        }

        /// <summary>
        /// Updates the user.
        /// </summary>
        /// <param name="User">The user with updates.</param>
        /// <param name="Id">The identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string UpdateUser(string User, string Id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            User user;
            try
            {
                user = BsonSerializer.Deserialize<User>(User);
            }
            catch (Exception)
        {
                errors.Add(ErrorCodes.CouldNotParseJsonToClass);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            user.Id = Id;
            try
            {
            _ur.UpdateUser(user.Id, user);
        }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotUpdateUser);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            return new Notification(null, errorType, errors).ToJson();
        }

        /// <summary>
        /// Gets by the identifier.
        /// </summary>
        /// <param name="id">The identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string GetById(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            if (id == null)
            {
                errors.Add(ErrorCodes.UserNotFound);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            User item;
            try
            {
                item = _ur.GetUser(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.UserNotFound);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            if (item == null)
            {
                errors.Add(ErrorCodes.UserNotFound);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }

            return new Notification(item.ToJson(), errorType, errors).ToJson();
        }
        /// <summary>
        /// Deletes the user.
        /// </summary>
        /// <param name="id">The identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpDelete]
        public string DeleteUser(string id)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;
            DeleteResult result;
            try
            {
                result = _ur.RemoveUser(id).Result;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.CouldNotDeleteUser);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            if (result.DeletedCount == 1)
            {
                return new Notification("User was deleted", errorType, errors).ToJson();
            }

            errors.Add(ErrorCodes.CouldNotGetUsers);
            return new Notification(null, ErrorTypes.Error, errors).ToJson();
        }

        /// <summary>
        /// Gets the wisr identifier from facebook identifier.
        /// </summary>
        /// <param name="facebookId">The facebook identifier.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string GetWisrIdFromFacebookId(string facebookId)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            string id;
            try
            {
                id = _ur.GetWisrIdFromFacebookId(facebookId);
            }
            catch (Exception)
            {

                errors.Add(ErrorCodes.CouldNotGetUsers);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            return new Notification(id, errorType, errors).ToJson();
        }
    }
}