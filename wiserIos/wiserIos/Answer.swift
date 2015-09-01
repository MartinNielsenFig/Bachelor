//
//  Answer.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Answer {
    var Value: String
    var UserId: String
    
    init(value: String, userId: String) {
        self.Value = value
        self.UserId = userId
    }
}