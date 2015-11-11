//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation
import JsonSerializerSwift

/// Handles the Http-Calls from the client to the RestAPI
class HttpHandler {
    
    static let mainUrl = "http://192.168.198.169:1337/"
    //static let mainUrl = "http://wisrrestapi.azurewebsites.net/"
    //static let mainUrl = "http://wisrrestapi.aceipse.dk/"
    
    static func log(data data: NSData?, response: NSURLResponse?, error: NSError?) {
        NSLog("data \(data)")
        NSLog("response \(response)")
        NSLog("error \(error)")
    }
    
    /**
     Sends a HTTP request to the RestAPI with the specified action and body. Then runs a callback-function with the received data as parameters.
     - parameter action:						Is the HTTP call to invoke on the RestAPI. Follows the "/Controller/Action" pattern.
     - parameter type:							Type of call: POST or GET.
     - parameter body:							The body of the POST, empty if GET.
     - parameter completionHandler:             A closure function to be run when the HTTP request has completed and the client has received an answer from the RestAPI.
     - parameter notification:                  Data returned from the rest api is always a JSON string of Notification. This function then parses the JSON string to this Notification class.
     - parameter response:                      Metadata associated with the response. See Apple NSURLResponse documentation.
     - parameter error:							Error returned from the server. See Apple dataTaskWithRequest documentation.
     */
    static func requestWithResponse(action action: String, type: String, body: String, completionHandler:
        (notification: Notification, response: String?, error: String?) -> Void) {
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: mainUrl + action)!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = type
            // "+" becomes " " http://stackoverflow.com/questions/2491351/nsmutableurlrequest-eats-plus-signs that's half a day lost
            request.HTTPBody = body.stringByReplacingOccurrencesOfString("+", withString: "%2b").dataUsingEncoding(NSUTF8StringEncoding)
            
            let started = NSDate()
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                //print("time for \(__FUNCTION__) mainUrl: \(mainUrl) action: \(action) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
                
                //Convert data to Notification
                var n = Notification()
                if let nData = data, swiftData = NSString(data: nData, encoding: NSUTF8StringEncoding) as? String {
                    if let notificationDictionary = try? JSONSerializer.toDictionary(swiftData) {
                        n = Notification(jsonDictionary: notificationDictionary)
                    }
                }
                
                completionHandler(notification: n, response: String(response), error: String(error))
            }
            task.resume()
    }
}