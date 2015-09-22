//
//  Error.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 22/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Error {
    var ErrorMessage: String?
    var ErrorCode: Int?
    var StackTrace: String?
    
    init(jsonDictionary: NSDictionary) {
        self.ErrorMessage = jsonDictionary["ErrorMessage"] as? String
        self.ErrorCode = jsonDictionary["ErrorCode"] as? Int
        self.StackTrace = jsonDictionary["StackTrace"] as? String
    }
    
    //todo more efficient way of determing whether a string is Error
    static func isError(aDictionary: NSDictionary) -> Bool {
        if aDictionary["ErrorMessage"] != nil && aDictionary["ErrorCode"] != nil && aDictionary["StackTrace"] != nil {
            return true
        }
        else {
            return false
        }
    }
    
    static func isError(aString: String) -> Bool {
        let lowercase = aString.lowercaseString
        if lowercase.containsString("errormessage") && lowercase.containsString("errorcode") && lowercase.containsString("stacktrace") {
            return true
        }
        else {
            return false
        }
    }
}