using System;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    public class Room
    {
        [BsonId]
        public string OId { get; set; }
        public User CreatedBy { get; set; }
        public Coordinate Location { get; set; }
        public int Radius { get; set; }
        public string Tag { get; set; }
        public bool HasPassword { get; set; }
        public string EncryptedPassword { get; set; }
        public bool HasChat { get; set; }
        public bool UsersCanAsk { get; set; }
        public bool AllowAnonymous { get; set; }
    }
}