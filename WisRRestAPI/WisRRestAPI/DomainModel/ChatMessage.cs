using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WisRRestAPI.DomainModel
{
    public class ChatMessage
    {
        public string ByUserId { get; set; }
        public string Value { get; set; }
        public string Date  { get; set; }
    }
}