//
//  Room.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Room {
    
    var id: String?
    var createdById: String
    var location: Coordinate?
    var radius: Int
    var tag: String
    var name: String?
    //Has default:
    var hasPassword: Bool = false
    var encryptedPassword: String?
    var hasChat: Bool = true
    var usersCanAsk: Bool = false
    var allowAnonymous: Bool = true
    
    
    init(createdById: String, radius: Int, tag: String) {
        self.createdById = createdById
        self.radius = radius
        self.tag = tag
    }
}