//
//  User.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// Any user of the system
class User {
    var _id: String?
    var FacebookId: String?
    var ConnectedRoomIds: [Int]?
    var LDAPUserName: String?
    var DisplayName: String?
    var Email: String?
    var EncryptedPassword: String?
    
    init(){}
    
    init(jsonDictionary: NSDictionary) {
        self._id = jsonDictionary["_id"] as? String
        self.FacebookId = jsonDictionary["FacebookId"] as? String
        self.ConnectedRoomIds = jsonDictionary["ConnectedRoomIds"] as? [Int]
        self.LDAPUserName = jsonDictionary["LDAPUserName"] as? String
        self.DisplayName = jsonDictionary["DisplayName"] as? String
        self.Email = jsonDictionary["Email"] as? String
        self.EncryptedPassword = jsonDictionary["EncryptedPassword"] as? String
    }
    
}