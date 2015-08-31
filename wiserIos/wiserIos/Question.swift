//
//  Question.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

enum QuestionType {
    case Boolean
    case MultipleChoice
    case Textuel
    case BrainStorming
}

class Question {
    
    var id: String?
    var questionType: QuestionType
    var questionText: String
    var responseOptions: [ResponseOption]?
    var img: String?
    var result: [Answer]?
    var upvotes: Int = 0
    var downvotes: Int = 0
    var createdById: String
    
    init(questionType: QuestionType, questionText: String, createdById: String) {
        self.questionType = questionType
        self.questionText = questionText
        self.createdById = createdById
    }
}