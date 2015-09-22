//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    static let mainUrl = "http://192.168.198.136:1337/"
    //static let mainUrl = "http://wisrrestapi.aceipse.dk/"
    
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
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) \(action) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
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
    
    //todo use
    static func handleResponse(data data: NSData?, response: NSURLResponse?, error: NSError?) -> Error? {
        log(data: data, response: response, error: error)
        
        if error == nil && data != nil {
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            let optDic = JSONSerializer.toDictionary(dataString)
            
            if let dictionary = optDic {
                if Error.isError(dictionary) {
                    let e = Error(jsonDictionary: dictionary)
                    NSLog("Error code \(e.ErrorCode)")
                    NSLog("Error Message \(e.ErrorMessage)")
                    NSLog("Stack trace \(e.StackTrace)")
                }
            }
        }
        return nil
    }
}