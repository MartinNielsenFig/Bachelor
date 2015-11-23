using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MongoDB.Bson;
using WisR.DomainModel;

namespace WisRRestAPI.Controllers
{
    /// <summary>
    /// This controller handler login to LDAP
    /// </summary>
    public class LoginController : Controller
    {
        /// <summary>
        /// Logins with LDAP, from email and password.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="password">The password.</param>
        /// <returns>Notification</returns>
        [System.Web.Mvc.HttpPost]
        public string LoginWithLDAP(string email, string password)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            bool authenticated = false;
            try
            {
                DirectoryEntry entry = new DirectoryEntry("LDAP://ldap.iha.dk", email, password);
                entry.RefreshCache();
                object nativeObject = entry.NativeObject;
                authenticated = true;
            }
            catch (DirectoryServicesCOMException cex)
            {
                errors.Add(ErrorCodes.ActiveDirctoryError);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            catch (Exception ex)
            {
                errors.Add(ErrorCodes.ActiveDirctoryError);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
            return new Notification(authenticated.ToString(), errorType, errors).ToJson();
        }
    }
}