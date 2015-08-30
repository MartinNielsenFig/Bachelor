//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    let mainUrl = "http://192.168.225.132:1337"
    //let mainUrl = "http://wisrrestapi.azurewebsites.net/"
    
    //http://stackoverflow.com/questions/25341858/perform-post-request-in-ios-swift

    func readData(controller: String, command: String, type: String) -> String {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("\(controller)/\(command)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = type
        
        var responseString = String()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)            
            print("error " + String(error) ?? "none")
            //print("data " + String(data) ?? "none")
            if data != nil {
                responseString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                print("data: \(responseString)")
            }
            print("response " + String(response) ?? "none")
        }
        task.resume()
        
        return responseString
    }
    
    
    //TEST
    func testCreateRoom(room: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Room/CreateRoom")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        let bodyDataTest = "Room=heh11111"
        request.HTTPBody = bodyDataTest.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            print(response)
        }
        task.resume()
    }
    
    func testStackoverflow() -> String {
        let url = NSURL(string: "http://www.stackoverflow.com")
        
        var result = String()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            result = String(data!)
        }
        task.resume()
        return result
    }
}