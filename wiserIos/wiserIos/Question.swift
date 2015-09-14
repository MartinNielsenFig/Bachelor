//
//  Question.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Question {
    
    var _id: String?
    var RoomId: String?
    var CreatedById: String?
    var Upvotes: Int?
    var Downvotes: Int?
    var Img: String?
    var QuestionText: String?
    var ResponseOptions = [ResponseOption]()
    var Result = [Answer]()
    var CreationTimestamp: String?
    var ExpireTimestamp: String?
    
    convenience init(jsonDictionary: NSDictionary) {
        self.init()
        
        self._id = jsonDictionary["_id"] as? String
        self.RoomId = jsonDictionary["RoomId"] as? String
        self.CreatedById = jsonDictionary["CreatedById"] as? String
        self.Upvotes = jsonDictionary["Upvotes"] as? Int
        self.Downvotes = jsonDictionary["Downvotes"] as? Int
        self.Img = jsonDictionary["Img"] as? String
        self.QuestionText = jsonDictionary["QuestionText"] as? String
        
        //Response
        if let responseArray = jsonDictionary["ResponseOptions"] as? NSArray {
            for opt in responseArray {
                let value = opt["Value"] as? String
                let weight = opt["Weight"] as? Int
                
                let ro = ResponseOption(value: value ?? "default", weight: weight ?? 1)
                self.ResponseOptions += [ro]
            }
        }
        
        //Answer
        if let resultArray = jsonDictionary["Result"] as? NSArray {
            for ans in resultArray {
                let value = ans["Value"] as? String
                let userId = ans["UserId"] as? String
                
                let a = Answer(value: value ?? "none", userId: userId ?? "none")
                self.Result += [a]
            }
        }
        
        self.CreationTimestamp = jsonDictionary["CreationTimestamp"] as? String
        self.ExpireTimestamp = jsonDictionary["ExpireTimestamp"] as? String
    }
    
    
}

class BooleanQuestion {
    var _id: String?
    var CreatedById: String = "nooba"
    var Upvotes: Int = 0
    var Downvotes: Int = 0
    var Img: String? = "base64"
    var QuestionText: String = "dooga"
    var ResponseOptions: [ResponseOption]?
    var Result: [Answer]?
    var ManyBool: String = "swiftenCreated"
}

class TextualQuestion: Question {
    var SpecificText = "swiftenCreated"
}