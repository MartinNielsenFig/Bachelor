//
//  ChatMessage.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 31/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// A Chatmessage to be represented in the Chatroom
class ChatMessage {
    /// MongoID
    var _id: String?
    /// ID of the user who created this message
    var ByUserId: String?
    /// "Foreign key" to the room which this ChatMessage belongs to
    var RoomId: String?
    /// The text the user wrote
    var Value: String?
    /// Timestamp for when the message was sent
    var Timestamp: String?
    /// Display name of the user who sent this message
    var ByUserDisplayName: String?
    
    init(){}
    
    init(jsonDictionary: NSDictionary) {
        
        _id = jsonDictionary["_id"] as? String
        ByUserId = jsonDictionary["ByUserId"] as? String
        RoomId = jsonDictionary["RoomId"] as? String
        Value = jsonDictionary["Value"] as? String
        Timestamp = jsonDictionary["Timestamp"] as? String
        ByUserDisplayName = jsonDictionary["ByUserDisplayName"] as? String
    }
}