using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using Facebook;
using System.DirectoryServices.AccountManagement;

namespace Web.Controllers
{
    public class LoginController : Controller
    {
        public string redirecturi;

        public LoginController()
        {
            if (Debugger.IsAttached)
            {
                redirecturi = "http://localhost:7331";
            }
            else
            {
                redirecturi = "http://wisr.azurewebsites.net";
            }
        }
        public void LoginWithFacebook()
        {
            Session.Clear();

            var fb = new FacebookClient();

            var loginUrl = fb.GetLoginUrl(new
            {
                client_id = "389473737909264",

                redirect_uri = redirecturi + "/Login/LoginCheck",

                response_type = "code",

                scope = "email" // Add other permissions as needed)
            });


            Response.Redirect(loginUrl.AbsoluteUri);
        }

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
                return "a"+cex.ToString();
                Console.WriteLine(cex);
            }
            catch (Exception ex)
            {
                return "b"+ex.Message;
                Console.WriteLine(ex);
            }
            if (authenticated)
                Session["LDAPid"] = email;
            return authenticated.ToString();
        }

        public ActionResult LoginCheck()
        {
            if (Request.QueryString["code"] == null)
                return RedirectToAction("Index", "Home");

            //Get new access code
            string accessCode = Request.QueryString["code"].ToString();

            var fb = new FacebookClient();

            dynamic result = fb.Post("oauth/access_token", new
            {
                client_id = "389473737909264",

                client_secret = "be14709def182d9b073a51301a722c1e",

                redirect_uri = redirecturi + "/Login/LoginCheck",

                code = accessCode
            });
            Session["AccessToken"] = result.access_token;

            var fbInfo = new FacebookClient(result.access_token);
            dynamic me = fbInfo.Get("me?fields=name,email");
            Session["FacebookId"] = me.id;

            return RedirectToAction("Index", "Home");
        }

        public ActionResult Logout()
        {
            //if (Session["AccessToken"] != null)
            //{
            //var token = Session["AccessToken"].ToString();
            //var client = new FacebookClient();

            //var logoutUrl = client.GetLogoutUrl(new { access_token = token, next = redirecturi });

            //Response.Redirect(logoutUrl.AbsoluteUri);
            Session.Clear();
            Session.RemoveAll();
            //}

            return RedirectToAction("Index", "Home");
        }
    }
}