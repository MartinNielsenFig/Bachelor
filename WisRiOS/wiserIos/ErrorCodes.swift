//
//  ErrorCodes.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 07/10/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/**
 *	These ErrorCodes are related to the errors received from the WisRApi. They are shared among the WisR system and clients.
 */
enum ErrorCode: Int {
    case NothingReceived = -100
    
    case RoomSecretAlreadyInUse = 0
    case NoRoomWithThatSecret
    case RabbitMqError
    case StringIsNotJsonFormat
    case CouldNotParseJsonToClass
    case CouldNotAddRoomToDatabase
    case CouldNotGetRoomsFromDatabase
    case CouldNotDeleteAllChatMessages
    case CouldNotDeleteAllQuestions
    case CouldNotDeleteRoom
    case CouldNotUpdateRoom
    case CouldNotGetUsers
    case CouldNotAddUser
    case CouldNotUpdateUser
    case UserNotFound
    case CouldNotDeleteUser
    case CouldNotGetQuestions
    case CouldNotGetQuestionType
    case NewQuestionIdShouldBeNull
    case RoomDoesNotExist
    case CouldNotAddQuestion
    case CouldNotUpdateQuestion
    case QuestionExpired
    case ActiveDirctoryError
    case CouldNotGetChatMessages
}