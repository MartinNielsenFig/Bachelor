//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    //static let mainUrl = "http://192.168.198.140:1337/"
    static let mainUrl = "http://wisrrestapi.aceipse.dk/"
    //static let mainUrl = "http://10.192.15.42/"
    
    static func log(data data: NSData?, response: NSURLResponse?, error: NSError?) {
        //NSLog("data \(data)")
        NSLog("response \(response)")
        NSLog("error \(error)")
    }
    
    //http://stackoverflow.com/questions/25341858/perform-post-request-in-ios-swift
    static func requestWithResponse(action action: String, type: String, body: String, completionHandler: (data: String?, response: String?, error: String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl + action)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = type
        // "+" becomes " " http://stackoverflow.com/questions/2491351/nsmutableurlrequest-eats-plus-signs that's half a day lost
        request.HTTPBody = body.stringByReplacingOccurrencesOfString("+", withString: "%2b").dataUsingEncoding(NSUTF8StringEncoding)
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) action: \(action) and body: \(body) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
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