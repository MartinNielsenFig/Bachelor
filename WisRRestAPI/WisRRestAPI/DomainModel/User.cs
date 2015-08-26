using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    public class User
    {
        [BsonId]
        public string Oid { get; set; }
        public int FacebookId { get; set; }
        public List<ObjectId> ConnectedRooms { get; set; }
        public string LDAPUserName { get; set; }
        public string DisplayName { get; set; }
        public string Email { get; set; }
        public string Encrypted { get; set; }
    }
}