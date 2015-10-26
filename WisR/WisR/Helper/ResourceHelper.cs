using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Mime;
using System.Reflection;
using System.Resources;
using System.Threading;
using System.Web;
using System.Web.Helpers;
using MongoDB.Bson;

namespace WisR.Helper
{
    public class ResourceHelper
    {
        public static Dictionary<object,string> AllResources;

        public ResourceHelper()
        {
            AllResources = GetResource();
        }
        public static Dictionary<object,string> GetResource()
        {
            ResourceSet rsrc = App_Resources.Resource.ResourceManager.GetResourceSet(Thread.CurrentThread.CurrentCulture, true, true);
            var dictionaryToReturn=new Dictionary<object,string>();
            foreach (DictionaryEntry entry in rsrc)
            {
                dictionaryToReturn.Add(entry.Key,entry.Value.ToString());
            }
           

            if (System.Diagnostics.Debugger.IsAttached)
            {
                var forJavaScript = Json.Encode(dictionaryToReturn);
                forJavaScript = "window.Resources = JSON.parse('" + forJavaScript + "');";
                var path = System.Web.Hosting.HostingEnvironment.MapPath("~");
                System.IO.StreamWriter file = new System.IO.StreamWriter(path.Substring(0, path.Length - 1) + ".Tests\\Scripts\\ResoursesForTest\\" + Thread.CurrentThread.CurrentCulture + ".js");
                file.WriteLine(forJavaScript);

                file.Close();
            }
         

            return dictionaryToReturn;
        }
    }
   
}