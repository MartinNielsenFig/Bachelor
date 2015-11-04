using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WisRRestAPI {
    public class TimeHelper {

        /// <summary>
        /// Returns miliseconds as string since 1-1-1970
        /// </summary>
        /// <param name="offsetMs">Added to the return value</param>
        public static string timeSinceEpoch(UInt64 offsetMs = 0) {
            TimeSpan t = DateTime.UtcNow - new DateTime(1970, 1, 1);
            string ms = Convert.ToUInt64(t.TotalMilliseconds + offsetMs).ToString();
            return ms;
        }
    }
}