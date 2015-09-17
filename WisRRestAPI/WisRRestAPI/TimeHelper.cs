using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WisRRestAPI {
    public class TimeHelper {
        public static string timeSinceEpoch(UInt64 offsetMs = 0) {
            TimeSpan t = DateTime.UtcNow - new DateTime(1970, 1, 1);
            string ms = Convert.ToUInt64(t.TotalMilliseconds + offsetMs).ToString();
            return ms;
        }
    }
}