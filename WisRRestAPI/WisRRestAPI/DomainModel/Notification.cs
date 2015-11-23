using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WisRRestAPI;

namespace WisR.DomainModel
{
    /// <summary>
    /// Notification have the Data, which is where data that has to be transfered are placed, ErrorType is is the return is an error or Ok and Errors is a list of errors that have been a thrown
    /// </summary>
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