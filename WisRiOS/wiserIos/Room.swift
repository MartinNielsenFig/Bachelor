//
//  Room.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// The room is a digital representation of a room/place in the world. The room is the hub of Questions and Chat.
class Room {
    var _id: String?
    var Name: String?
    var CreatedById: String?
    var Location = Coordinate()
    var Radius: Int?
    var Tag: String?
    var HasPassword: Bool?
    var EncryptedPassword: String?
    var HasChat: Bool?
    var UsersCanAsk: Bool?
    var AllowAnonymous: Bool?
    var UseLocation: Bool?
    
    convenience init(jsonDictionary: NSDictionary) {
        self.init()
        
        self._id = jsonDictionary["_id"] as? String
        self.Name = jsonDictionary["Name"] as? String
        self.CreatedById = jsonDictionary["CreatedById"] as? String
        
        //Location
        if let loc = jsonDictionary["Location"] {
            self.Location.AccuracyMeters = loc["AccuracyMeters"] as? Int
            self.Location.FormattedAddress = loc["FormattedAddress"] as? String
            self.Location.Latitude = loc["Latitude"] as? Double
            self.Location.Longitude = loc["Longitude"] as? Double
            self.Location.Timestamp = loc["Timestamp"] as? String
        }
        
        self.Radius = jsonDictionary["Radius"] as? Int
        self.Tag = jsonDictionary["Tag"] as? String
        self.HasPassword = jsonDictionary["HasPassword"] as? Bool
        self.EncryptedPassword = jsonDictionary["EncryptedPassword"] as? String
        self.HasChat = jsonDictionary["HasChat"] as? Bool
        self.UsersCanAsk = jsonDictionary["UsersCanAsk"] as? Bool
        self.AllowAnonymous = jsonDictionary["AllowAnonymous"] as? Bool
        self.UseLocation = jsonDictionary["UseLocation"] as? Bool
    }
}