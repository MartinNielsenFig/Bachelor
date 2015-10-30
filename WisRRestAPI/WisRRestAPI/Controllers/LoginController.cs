using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WisRRestAPI.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        public ActionResult Index()
        {
            return View();
        }
        [System.Web.Mvc.HttpPost]
        public string LoginWithLDAP(string email, string password)
        {
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
                return "a" + cex.ToString();
                //Console.WriteLine(cex);
            }
            catch (Exception ex)
            {
                return "b" + ex.Message;
                //Console.WriteLine(ex);
            }
            return authenticated.ToString();
        }
    }
}