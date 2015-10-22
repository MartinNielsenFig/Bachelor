//
//  Error.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 22/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation
import JsonSerializerSwift


/// An Error can be returned from the RestAPI describing what went wrong. If nothing went wrong (the http-call was a success), the response from the RestAPI fails to be parsed to an Error.
class ReturnMessage {
    var Data = String()
    var ErrorMessage: String?
    var ErrorCode: Int
    var StackTrace: String?
    
    init() {
        self.ErrorCode = ErrorCodes.NothingReceived.rawValue
    }
    
    init(jsonDictionary: NSDictionary) {
        self.Data = jsonDictionary["Data"] as? String ?? String()
        self.ErrorMessage = jsonDictionary["ErrorMessage"] as? String
        self.ErrorCode = jsonDictionary["ErrorCode"] as! Int
        self.StackTrace = jsonDictionary["StackTrace"] as? String
    }
    
    /**
    Given any string, determines whether that string is a JSON representation of the Error class. If it is, returns that error, else throws an NSError.
    - parameter dataString:	The string to be determined wheter it's an Error.
    - throws: Rethrows either JSONSerializer.toDictionary (see documentation for that) or an NSError describing the error further.
    - returns: The given string as an Error class
    */
    static func parse(dataString: String) throws -> ReturnMessage {
        do {
            let dictionary = try JSONSerializer.toDictionary(dataString)
            let e = ReturnMessage(jsonDictionary: dictionary)
            return e
        }
        catch let jsonerror as JSONSerializer.JSONSerializerError {
            print(jsonerror)
            throw jsonerror
        }
        catch let nserror as NSError {  //todo test if this catches custom Error class
            print(nserror)
            throw nserror
        }
    }
}