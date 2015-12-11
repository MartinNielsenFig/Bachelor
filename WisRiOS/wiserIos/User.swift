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
    /// MongoID
    var _id: String?
    /// FacebookID of the user
    var FacebookId: String?
    /// An array of IDs for the rooms this user has been connected to. Not used by iOS
    var ConnectedRoomIds: [Int]?
    /// LDAP user name
    var LDAPUserName: String?
    /// Display name for this user. It's acquired by Facebook in iOS
    var DisplayName: String?
    /// The email for this user. It's acquired by Facebook in iOS
    var Email: String?
    /// A password for this user. To be used if this user was a WisR user. But currently not used by iOS
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