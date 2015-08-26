using System;
using MongoDB.Bson;

namespace WisR.DomainModels
{
    public class Room
    {
        public ObjectId OId { get; set; }
        public User CreatedBy { get; set; }
        public Coordinate Location { get; set; }
        public int Radius { get; set; }
        public string Tag { get; set; }
        public bool HasPassword { get; set; }
        public string EncryptedPassword { get; set; }
        public bool HasChat { get; set; }
        public bool USersCanAsk { get; set; }
        public bool AllowAnonymous { get; set; }
    }
}