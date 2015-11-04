using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WisRRestAPI;

namespace WisR.DomainModel
{
    public class Notification
    {
        public Notification(string data, ErrorTypes errorType, List<ErrorCodes> errors )
        {
            Data = data;
            ErrorType = errorType;
            Errors = errors;
        }
        public string Data { get; set; }
        public ErrorTypes ErrorType { get; set; }
        public List<ErrorCodes> Errors { get; set; }
    }
}