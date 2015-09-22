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
    static func sendChatMessage(chatMessageJson: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Chat/CreateChatMessage")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "ChatMessage=\(chatMessageJson)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                //NSLog("dataString \(dataString)")
            }
        }
        task.resume()
    }
    
    static func getChatMessages(roomId: String, completionHandler: (inout messages: [ChatMessage]) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Chat/GetAllByRoomId")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "roomId=\(roomId)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                //NSLog("dataString \(dataString)")
                
                var messageArray = [ChatMessage]()
                for msgJson in JSONSerializer.toArray(dataString)! {
                    messageArray += [ChatMessage(jsonDictionary: msgJson as! NSDictionary)]
                }
                
                completionHandler(messages: &messageArray)
            }
        }
        task.resume()
    }
    
    //Creates an user on MongoDB from User with facebook ID, then returns MongoDB ID.
    //If user already exists, returns MongoDB ID.
    static func createUser(userJson: String, completionHandler: (inout mongoDbId: String) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("User/CreateUser")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "User=\(userJson)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                //NSLog("dataString \(dataString)")
                
                var mongoId = dataString
                completionHandler(mongoDbId: &mongoId)
            }
        }
        task.resume()
    }
    
    //If room is is nil, get's all questions
    static func getQuestions(roomId: String?, completionHandler: (inout questions: [Question]) -> Void) {
        let session = NSURLSession.sharedSession()
        
        var url: NSURL
        if roomId != nil {
            url = NSURL(string: mainUrl + "Question/GetQuestionsForRoom?roomId=\(roomId!)")!
        } else {
            url = NSURL(string: mainUrl + "Question/GetAll")!
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) http call \(NSDate().timeIntervalSinceDate(started)) seconds")
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                //NSLog("dataString \(dataString)")
                
                var questionArray = [Question]()
                for question in JSONSerializer.toArray(dataString)! {
                    questionArray += [Question(jsonDictionary: question as! NSDictionary)]
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
        
        let started = NSDate()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            NSLog("time for \(__FUNCTION__) http call \(NSDate().timeIntervalSinceDate(started)) seconds")

            log(data: data, response: response, error: error)
            
            if data != nil {
                let nsDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let dataString = nsDataString as! String
                //NSLog("dataString \(dataString)")
                
                var rooms = [Room]()
                for room in JSONSerializer.toArray(dataString)! {
                    rooms.append(Room(jsonDictionary: room as! NSDictionary))
                }
                
                completionHandler(rooms: &rooms)
            }
        }
        task.resume()
    }
    
    static func createRoom(room: String, completionHandler: (roomId: String) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Room/CreateRoom")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "room=\(room)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                completionHandler(roomId: dataString)
                //NSLog("dataString \(dataString)")
            }
            
        }
        task.resume()
    }
    
    static func createQuestion(roomId: String, question: String, type: String) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: mainUrl)!.URLByAppendingPathComponent("Question/CreateQuestion")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let body = "roomId=\(roomId)&question=\(question)&type=\(type)"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            log(data: data, response: response, error: error)
            
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                //NSLog("dataString \(dataString)")
            }
        
        }
        task.resume()
    }
}