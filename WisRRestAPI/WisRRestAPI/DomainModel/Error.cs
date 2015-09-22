using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WisRRestAPI.DomainModel
{
    public class Error
    {
        public Error(string eMsg,int eCode,string sTrace="no StackTrace")
        {
            ErrorMessage = eMsg;
            ErrorCode = eCode;
            //Only apply stacktrace if we're running in debug mode
            if (System.Diagnostics.Debugger.IsAttached)
            {
                StackTrace = sTrace;
            }
            else
            {
                StackTrace = "No stacktrace in release mode"; 
            }
           
        }
        public string ErrorMessage { get; set; }
        public int ErrorCode { get; set; }
        public string StackTrace { get; set; }
    }
}