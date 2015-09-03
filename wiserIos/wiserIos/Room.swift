//
//  Room.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Room {
    
    var _id: String?
    var Name: String?
    var CreatedById: String?
    var Location = Coordinate()
    var Radius: Int?
    var Tag: String?
    var HasPassword: Bool = false
    var EncryptedPassword: String?
    var HasChat: Bool = true
    var UsersCanAsk: Bool = false
    var AllowAnonymous: Bool = true
    var Chatlog: [ChatMessage]?
    
    
    init() {

    }
}