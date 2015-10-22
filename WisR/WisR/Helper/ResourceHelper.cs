using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Resources;
using System.Threading;
using System.Web;
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
            return dictionaryToReturn;
        }
    }
   
}