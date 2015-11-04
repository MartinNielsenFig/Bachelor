//
//  Notification.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 04/11/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Notification {
    
    var Data: String?
    var ErrorType: ErrorTypes
    var Errors = [ErrorCode]()
    
    init(jsonDictionary: NSDictionary) {
        Data = jsonDictionary["Data"] as? String
        ErrorType = ErrorTypes(rawValue: jsonDictionary["ErrorType"] as! Int) ?? ErrorTypes.Error
        
        if let errorArray = jsonDictionary["Errors"] as? NSArray {
            for e in errorArray {
                self.Errors += [(ErrorCode(rawValue: e as! Int)!)]
            }
        }
    }
}