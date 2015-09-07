using System;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using WisRRestAPI.DomainModel;

namespace WisR.DomainModels
{
    public class Room
    {
        public Room()
        {
            Location = new Coordinate();
            ChatLog = new List<ChatMessage>();
        }
        [BsonId]
        public string Id { get; set; }
        public string Name { get; set; }
        public string CreatedById { get; set; }
        public Coordinate Location { get; set; }
        public int Radius { get; set; }
        public string Tag { get; set; }
        public bool HasPassword { get; set; }
        public string EncryptedPassword { get; set; }
        public bool HasChat { get; set; }
        public bool UsersCanAsk { get; set; }
        public bool AllowAnonymous { get; set; }
        public List<ChatMessage> ChatLog { get; set; }
        public bool UseLocation { get; set; }
    }
}