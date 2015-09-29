//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// Handles the Http-Calls from the client to the RestAPI
class HttpHandler {
    
    //static let mainUrl = "http://192.168.198.140:1337/"
    static let mainUrl = "http://wisrrestapi.aceipse.dk/"
    //static let mainUrl = "http://10.192.15.42/"
    
    static func log(data data: NSData?, response: NSURLResponse?, error: NSError?) {
        //NSLog("data \(data)")
        //NSLog("response \(response)")
        //NSLog("error \(error)")
    }
    
    //
    
    /**
    Sends a HTTP request to the RestAPI with the specified action and body.
    - parameter action:						Is the HTTP call to invoke on the RestAPI
    - parameter type:							Type of call: POST or GET
    - parameter body:							A body of the POST, empty if GET
    - parameter completionHandler:	A closure function to be run when the HTTP request is complete and the client has received an answer from the RestAPI. See Apple dataTaskWithRequest documentation
    - parameter data:					Data returned from the RestAPI
    - parameter response:					Metadata associated with the response. See Apple NSURLResponse documentation.
    - parameter error:							Error returned from the server. This is not same as the WisR.Error class.
    */
    static func requestWithResponse(action action: String, type: String, body: String, completionHandler: (data: String?, response: String?, error: String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl + action)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = type
        // "+" becomes " " http://stackoverflow.com/questions/2491351/nsmutableurlrequest-eats-plus-signs that's half a day lost
        request.HTTPBody = body.stringByReplacingOccurrencesOfString("+", withString: "%2b").dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 10
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            print("time for \(__FUNCTION__) action: \(action) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
            //Todo add customError class to completionHandler
            log(data: data, response: response, error: error)
            if let d = data {
                completionHandler(data: (NSString(data: d, encoding: NSUTF8StringEncoding) as! String), response: String(response), error: String(error))
            }
            else {
                completionHandler(data: "", response: String(response), error: String(error))
            }
        }
        task.resume()
    }
}