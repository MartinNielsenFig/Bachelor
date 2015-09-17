//
//  CurrentUser.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 08/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class CurrentUser: User {
    var location = Coordinate()
    
    static let sharedInstance = CurrentUser()
}