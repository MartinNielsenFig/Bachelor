//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    let mainUrl = "http://192.168.225.140:1337"
    //let mainUrl = "http://wisrrestapi.aceipse.dk/"
    
    //http://stackoverflow.com/questions/25341858/perform-post-request-in-ios-swift
    func createQuestion(room: String, question: String, type: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Question/CreateQuestion")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        //request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        let body = "roomId=\(room)&question=\(question)&type=\(type)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            print("data \(data)")
            print("reponse \(response)")
            print("error \(error)")
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                print("dataString \(dataString)")
            }
        
        }
        task.resume()
    }
}