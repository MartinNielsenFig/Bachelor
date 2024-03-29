﻿using System;
using System.Diagnostics;
using System.DirectoryServices;
using System.Web.Mvc;
using Facebook;

namespace WisR.Controllers
{
    /// <summary>
    /// Login controller is used to authentication of users.
    /// </summary>
    public class LoginController : BaseController
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

        /// <summary>
        /// Logins with facebook.
        /// </summary>
        public void LoginWithFacebook()
        {
            //Save culture information before deleting session
            var culture = (int) Session["CurrentCulture"];
            Session.RemoveAll();
            Session["CurrentCulture"] = culture;

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

        /// <summary>
        /// Logins with LDAP.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="password">The password.</param>
        /// <returns></returns>
        public string LoginWithLDAP(string email, string password)
        {
            var authenticated = false;
            try
            {
                var entry = new DirectoryEntry("LDAP://ldap.iha.dk", email, password);
                entry.RefreshCache();
                var nativeObject = entry.NativeObject;
                authenticated = true;
            }
            catch (DirectoryServicesCOMException cex)
            {
                return "a" + cex;
                //Console.WriteLine(cex);
            }
            catch (Exception ex)
            {
                return "b" + ex.Message;
                //Console.WriteLine(ex);
            }
            if (authenticated)
                Session["LDAPid"] = email;
            return authenticated.ToString();
        }

        /// <summary>
        /// Checks if user is logged in
        /// </summary>
        /// <returns></returns>
        public ActionResult LoginCheck()
        {
            if (Request.QueryString["code"] == null)
                return RedirectToAction("Index", "Home");

            //Get new access code
            var accessCode = Request.QueryString["code"];

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

        /// <summary>
        /// Logouts this instance.
        /// </summary>
        /// <returns></returns>
        public ActionResult Logout()
        {
            //Save culture information before deleting session
            var culture = (int) Session["CurrentCulture"];
            Session.RemoveAll();
            Session["CurrentCulture"] = culture;
            
            return RedirectToAction("Index", "Home");
        }
    }
}