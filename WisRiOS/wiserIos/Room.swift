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
    /// MongoID
    var _id: String?
    /// Name of the room
    var Name: String?
    /// The MongoID of the user that created the room
    var CreatedById: String?
    /// The location of the room
    var Location = Coordinate()
    /// The radius of the room in meters
    var Radius: Int?
    /// The secret string that a user can use to connect to this room, even without the user being near the room.
    var Secret: String?
    /// Whether the room has password
    var HasPassword: Bool?
    /// The password for the room encrypted
    var EncryptedPassword: String?
    /// Whether the room has a chat
    var HasChat: Bool?
    /// Whether users joining the room can ask questions
    var UsersCanAsk: Bool?
    /// Whether anonymous users can log into the room
    var AllowAnonymous: Bool?
    /// Whether this room uses location or if it only can be connected to with the secret
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
        self.Secret = jsonDictionary["Secret"] as? String
        self.HasPassword = jsonDictionary["HasPassword"] as? Bool
        self.EncryptedPassword = jsonDictionary["EncryptedPassword"] as? String
        self.HasChat = jsonDictionary["HasChat"] as? Bool
        self.UsersCanAsk = jsonDictionary["UsersCanAsk"] as? Bool
        self.AllowAnonymous = jsonDictionary["AllowAnonymous"] as? Bool
        self.UseLocation = jsonDictionary["UseLocation"] as? Bool
    }
}