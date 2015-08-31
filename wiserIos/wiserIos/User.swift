//
//  User.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class User {
    
    var id: String?
    var facebookId: Int?
    var connectedRoomIds: [Int]?
    var ldapUserName: String?
    var displayName: String
    var email: String?
    var encryptedPassword: String?
    
    init(displayName: String) {
        self.displayName = displayName
    }
}