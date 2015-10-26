//
//  ErrorCodes.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 07/10/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

enum ErrorCodes: Int {
    case NothingReceived = -100
    case RoomSecretAlreadyInUse = 0
    case RabbitMqError
    case StringIsNotJsonFormat
    case CouldNotParseJsonToClass
}