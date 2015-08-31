//
//  Question.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Question {
    
    var id: String?
    var createdById: String
    var upvotes: Int = 0
    var downvotes: Int = 0
    var img: String?
    var questionText: String
    var responseOptions: [ResponseOption]?
    var result: [Answer]?
    
    init(questionText: String, createdById: String) {
        self.questionText = questionText
        self.createdById = createdById
    }
}

class BooleanQuestion {
    var id: String?
    var createdById: String = "nooba"
    var upvotes: Int = 0
    var downvotes: Int = 0
    var img: String?
    var questionText: String = "dooga"
    var responseOptions: [ResponseOption]?
    var result: [Answer]?
    var manyBool: String = "swiftenCreated"
}

class TextualQuestion: Question {
    var specificText = "swiftenCreated"
}