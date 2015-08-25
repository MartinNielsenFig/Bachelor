using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace mongoDbDemo
{
    class Program
    {
        static async void RunAsync()
        {
            //Setting up connection and getting a collection
            var client = new MongoClient(@"mongodb://admin:design88@ds034198.mongolab.com:34198/peheje");
            var db = client.GetDatabase("peheje");
            var collection = db.GetCollection<Person>("people");

            //Insert one
            //var p1 = new Person { Name = "Anders", Age = 2, Profession = "IKT", Height = 2000 };
            //await collection.InsertOneAsync(p1);
            //Console.WriteLine("Finished saving");

            //Read
            var youngPeople = collection.Find(x => x.Age < 25).ToListAsync();
            await youngPeople;

            Console.WriteLine("Found young people:");
            foreach (var p in youngPeople.Result.ToList())
            {
                Console.WriteLine(p.Name);
            }

            //
            var peter = collection.Find(x => x.Id == ObjectId.Parse("5547a8dd472e113340cb8ea5")).SingleAsync();
            await peter;

            var ff = peter;

            //Updating
            await
                collection.UpdateManyAsync(x => true,
                    Builders<Person>.Update.Set(x => x.Cpr, "000000-0000"));
            Console.WriteLine("Updating default CPR where empty finished");
            
            //Print all
            var allPeople = collection.Find(x => true).ToListAsync();
            await allPeople;
            Console.WriteLine("Found all people");
            foreach (var p in allPeople.Result.ToList())
            {
                Console.WriteLine(p.ToString());
            }
        }

        static void Main(string[] args)
        {
            RunAsync();
            while (true)
            {
                Console.WriteLine("Main now waits 10 sec");
                Thread.Sleep(10000);
            }
        }
    }

    public class Person
    {
        public ObjectId Id { get; set; }
        public string Name { get; set; }
        public int Age { get; set; }
        public string Profession { get; set; }
        public double? Height { get; set; }
        public string Cpr { get; set; }

        public override string ToString()
        {
            return Name + " " + Age + " " + Profession;
        }
    }

}
