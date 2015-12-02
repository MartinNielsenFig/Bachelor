//
//  CurrentUser.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 08/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// A singleton class that contains the current user information
class CurrentUser: User {
    
 /// The location of the application user. Set in ChoseRoleViewController and used throughout the application
    var location = Coordinate()
    
 /// Getting the shared singleton
    static let sharedInstance = CurrentUser()
}