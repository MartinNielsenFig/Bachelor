//
//  HTTPHandler.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class HttpHandler {
    
    static let mainUrl = "http://192.168.198.128:1337"
    //static let mainUrl = "http://wisrrestapi.aceipse.dk/"
    
    //http://stackoverflow.com/questions/25341858/perform-post-request-in-ios-swift
    
    //If room is is nil, get's all questions
    static func getQuestions(completionHandler: (inout questions: [Question]) -> Void, roomId: String?) {
        let session = NSURLSession.sharedSession()
        var url = NSURL(string: mainUrl)!
        url = roomId != nil ?
            url.URLByAppendingPathComponent("Question/GetQuestionsForRoom&\(roomId)") :
            url.URLByAppendingPathComponent("Question/GetAll")
            
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            NSLog("data \(data)")
            NSLog("reponse \(response)")
            NSLog("error \(error)")
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                NSLog("dataString \(dataString)")
                
                //init rooms here
                var questionArray = [Question]()
                let	questionJson = JSONSerializer.toArray(dataString)
                
                for question in questionJson! {
                    questionArray.append(Question(jsonDictionary: question as! NSDictionary))
                }
                
                completionHandler(questions: &questionArray)
            }
        }
        task.resume()
    }
    
    static func getRooms(completionHandler: (inout rooms: [Room]) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Room/GetAll")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            NSLog("data \(data)")
            NSLog("reponse \(response)")
            NSLog("error \(error)")
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                NSLog("dataString \(dataString)")
                
                //init rooms here
                var rooms = [Room]()
                let	roomsJson = JSONSerializer.toArray(dataString)
                
                for room in roomsJson! {
                    rooms.append(Room(jsonDictionary: room as! NSDictionary))
                }
                
                completionHandler(rooms: &rooms)
            }
        }
        task.resume()
    }
    
    static func createRoom(room: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Room/CreateRoom")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "room=\(room)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            NSLog("data \(data)")
            NSLog("reponse \(response)")
            NSLog("error \(error)")
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                NSLog("dataString \(dataString)")
            }
            
        }
        task.resume()
    }
    
    static func createQuestion(room: String, question: String, type: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Question/CreateQuestion")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "roomId=\(room)&question=\(question)&type=\(type)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            NSLog("data \(data)")
            NSLog("reponse \(response)")
            NSLog("error \(error)")
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                NSLog("dataString \(dataString)")
            }
        
        }
        task.resume()
    }
}