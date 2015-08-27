//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    let url = "http://192.168.225.128:1337"
    
    
    
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