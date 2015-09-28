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
        }
        [BsonId]
        public string Id { get; set; }
        public string Name { get; set; }
        public string CreatedById { get; set; }
        public Coordinate Location { get; set; }
        public int Radius { get; set; }
        
        //The tag uniquely identities the room. If any user has the tag he'll be able to connect to the room. The room can still be password protected.
        public string Tag { get; set; }
        public bool HasPassword { get; set; }
        public string EncryptedPassword { get; set; }
        public bool HasChat { get; set; }
        public bool UsersCanAsk { get; set; }
        public bool AllowAnonymous { get; set; }
        
        //Indicates whether room should be findable by being near the room.
        public bool UseLocation { get; set; }
    }
}