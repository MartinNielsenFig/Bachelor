//
//  Question.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// Question for a room.
class Question {
    var _id: String?
    var RoomId: String?
    var CreatedById: String?
    var Votes = [Vote]()
    var Img: String?
    var QuestionText: String?
    var ResponseOptions = [ResponseOption]()
    var Result = [Answer]()
    var CreationTimestamp: String?
    var ExpireTimestamp: String?
    var CreatedByUserDisplayName: String?
    
    init() {}
    
    init(jsonDictionary: NSDictionary) {
        
        self._id = jsonDictionary["_id"] as? String
        self.RoomId = jsonDictionary["RoomId"] as? String
        self.CreatedById = jsonDictionary["CreatedById"] as? String
        self.Img = jsonDictionary["Img"] as? String
        self.QuestionText = jsonDictionary["QuestionText"] as? String
        
        //Votes
        if let votes = jsonDictionary["Votes"] as? NSArray {
            for v in votes {
                let vote = Vote(createdById: v["CreatedById"] as? String ?? "none", value: v["Value"] as? Int ?? 1)
                self.Votes += [vote]
            }
        }
        
        //ResponseOptions
        if let responseArray = jsonDictionary["ResponseOptions"] as? NSArray {
            for opt in responseArray {
                let value = opt["Value"] as? String
                let weight = opt["Weight"] as? Int
                
                let ro = ResponseOption(value: value ?? "default", weight: weight ?? 1)
                self.ResponseOptions += [ro]
            }
        }
        
        //Result
        if let resultArray = jsonDictionary["Result"] as? NSArray {
            for ans in resultArray {
                let value = ans["Value"] as? String
                let userId = ans["UserId"] as? String
                let username = ans["UserDisplayName"] as? String
                
                let a = Answer(value: value ?? "none", userId: userId ?? "none", userDisplayName: username ?? "Anonymous")
                self.Result += [a]
            }
        }
        
        self.CreationTimestamp = jsonDictionary["CreationTimestamp"] as? String
        self.ExpireTimestamp = jsonDictionary["ExpireTimestamp"] as? String
        self.CreatedByUserDisplayName = jsonDictionary["CreatedByUserDisplayName"] as? String
    }
}

class TextualQuestion: Question {
    var SpecificText: String? = "swiftenCreated"
    
    override init(jsonDictionary: NSDictionary) {
        super.init(jsonDictionary: jsonDictionary)
        self.SpecificText = jsonDictionary["SpecificText"] as? String
    }
}