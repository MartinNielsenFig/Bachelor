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
    var CreatedById: String
    var Upvotes: Int = 0
    var Downvotes: Int = 0
    var Img: String?
    var QuestionText: String
    var ResponseOptions: [ResponseOption]?
    var Result: [Answer]?
    
    init(questionText: String, createdById: String) {
        self.QuestionText = questionText
        self.CreatedById = createdById
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