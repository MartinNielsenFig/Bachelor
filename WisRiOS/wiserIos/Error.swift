//
//  Error.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 22/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// An Error can be returned from the RestAPI describing what went wrong. If nothing went wrong (the http-call was a success), the response from the RestAPI fails to be parsed to an Error.
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
    
    /**
    Tries to determine whether a response-string from the RestAPI is an Error
    - parameter aDictionary:	Dictionary of the Error
    - returns: Returns a boolean value whether aDictionary is of type Error or not
    */
    static func isError(aDictionary: NSDictionary) -> Bool {
        if aDictionary["ErrorMessage"] != nil && aDictionary["ErrorCode"] != nil && aDictionary["StackTrace"] != nil {
            return true
        }
        else {
            return false
        }
    }
    
    /**
    Tries to determine whether a response-string from the RestAPI is an Error
    - parameter aString:	Response string from the RestAPI
    - returns: Returns a boolean value whether the aString can be converted to an instance of Error
    */
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