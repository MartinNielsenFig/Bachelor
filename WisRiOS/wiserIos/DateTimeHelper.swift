//
//  DateTimeHelper.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 15/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// Helps with time-keeping
class DateTimeHelper {
    
    /**
    Returns a human readable string of the time from a epoch string.
    - parameter secSince1970:	Seconds since 1970. Aka Epoch.
    - returns: A string representing the time.
    */
    static func getTimeStringFromEpochString(secSince1970: String?) -> String {
        
        var sec = Float()
        if let timestampUnknownSeperator = secSince1970 {
            let timestampDot = timestampUnknownSeperator.stringByReplacingOccurrencesOfString(",", withString: ".")
            sec = Float(timestampDot)!/1000
        }
        
        let timeInterval = NSTimeInterval(sec)
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateString = formatter.stringFromDate(date)
        
        return dateString
    }
    
    static func getComponents(durationSec: NSTimeInterval, flags: NSCalendarUnit) -> NSDateComponents {
        let cal = NSCalendar.currentCalendar()
        
        let date1 = NSDate()
        let date2 = NSDate(timeIntervalSinceNow: durationSec)

        let components = cal.components(flags, fromDate: date1, toDate: date2, options: .MatchFirst)
        return components
    }
    
        

}