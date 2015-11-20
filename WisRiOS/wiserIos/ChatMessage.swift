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
    var _id: String?
    var ByUserId: String?
    var RoomId: String?
    var Value: String?
    var Timestamp: String?
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