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

class BooleanQuestion: Question {
    var manyBool: String = "swiftenCreated"
}

class TextualQeustion: Question {
    var specificText = "swiftenCreated"
}