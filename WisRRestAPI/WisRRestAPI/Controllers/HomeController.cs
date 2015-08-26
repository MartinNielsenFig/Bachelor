using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using MongoDB.Bson.Serialization.Serializers;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.Title = "Home Page";
            ViewBag.q = new JavaScriptSerializer().Serialize(new Question());
            return View();
        }

        public async void MakeQuestion()
        {
            var client = new MongoClient(@"/WisR:1234@ds055842.mongolab.com:55842/bachelor");
            var db = client.GetDatabase("bachelor");
            var collection = db.GetCollection<Question>("Questions");

            //Insert one
            var q1 = new Question{ QuestionType = QuestionType.BrainStorming, QuestionText = "Does it Work"};

            await collection.InsertOneAsync(q1);
            Console.WriteLine("Finished saving");
        }
    }
}
