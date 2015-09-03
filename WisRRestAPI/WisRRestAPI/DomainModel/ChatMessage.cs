using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MongoDB.Bson;

namespace WisRRestAPI.DomainModel
{
    public class ChatMessage
    {
        public ObjectId? Id { get; set; }
        public string ByUserId { get; set; }
        public string RoomId { get; set; }
        public string Value { get; set; }
        public string Timestamp  { get; set; }
    }
}