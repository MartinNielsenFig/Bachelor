//
//  Answer.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// A user's answer to a Question
class Answer {
    var Value: String
    var UserId: String
    var UserDisplayName: String
    
    init(value: String, userId: String, userDisplayName: String) {
        self.Value = value
        self.UserId = userId
        self.UserDisplayName = userDisplayName
    }
}