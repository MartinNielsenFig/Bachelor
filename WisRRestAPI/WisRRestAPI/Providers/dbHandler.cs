using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using MongoDB.Driver;

namespace WisRRestAPI.DomainModel
{
    public class dbHandler : IdbHandler
    {
        private IMongoDatabase _db;

        public dbHandler()
        {
            var connection = ConfigurationManager.AppSettings["mongoString"];
            var client = new MongoClient(connection);
            _db = client.GetDatabase("wisr");
        }

        public IMongoDatabase getDb()
        {
            return _db;
        }
    }
}