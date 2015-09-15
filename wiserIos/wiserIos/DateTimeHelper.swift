//
//  DateTimeHelper.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 15/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation


class DateTimeHelper {
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
}