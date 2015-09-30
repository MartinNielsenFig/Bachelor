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
    
    /**
    Given a duration in seconds, calculates the components of that time duration from a given set of wished components. E.g. 86400 seconds in a day could be represented as 1 days 0 minutes 0 seconds, or 0 days, 1440 minutes, 0 seconds etc.
    - parameter durationSec:	Duration in seconds.
    - parameter flags:				Describes which kind of components you wish you distribute the seconds into.
    - returns: NSDateComponent representation of the duration with the specified components available
    */
    static func getComponents(durationSec: NSTimeInterval, flags: NSCalendarUnit) -> NSDateComponents {
        let cal = NSCalendar.currentCalendar()
        
        let date1 = NSDate()
        let date2 = NSDate(timeIntervalSinceNow: durationSec)

        let components = cal.components(flags, fromDate: date1, toDate: date2, options: .MatchFirst)
        return components
    }
    
        

}