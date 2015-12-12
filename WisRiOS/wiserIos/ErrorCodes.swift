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
    /**
     *	iOS specific code if the request has not been sent yet
     */
    case NothingReceived = -100
    /**
     *	Received from the web api if user tries to create a room with a secret that is already taken
     */
    case RoomSecretAlreadyInUse = 0
    /**
     *	Received from the web api if the user tries to connect to a room with a secret that does not exist
     */
    case NoRoomWithThatSecret
    /**
     *	Received from the web api if there's an error with RabbitMq. Not applicable in iOS
     */
    case RabbitMqError
    /**
     *	Received from the web api if the iOS application sent invalid Json, could happen if a property that is not supposed to be null is
     */
    case StringIsNotJsonFormat
    /**
     *	Received from the web api if the sent Json is valid but it could not parse it to a domain class (Models), could happen if the model was changed and out of sync between the iOS app and WisR web api
     */
    case CouldNotParseJsonToClass
    /**
     *	Received from the web api if there's problems with the database when creating rooms
     */
    case CouldNotAddRoomToDatabase
    /**
     *	Received from the web api if there's problems with the database when fetching rooms
     */
    case CouldNotGetRoomsFromDatabase
    /**
     *	Received from the web api if the room is being deleted and some chat messages couldn't be deleted
     */
    case CouldNotDeleteAllChatMessages
    /**
     *	Received from the web api if the room is being deleted and some questions couldn't be deleted
     */
    case CouldNotDeleteAllQuestions
    /**
     *	Received from the web api if the user tries to delete a room but it can't be deleted, could happen if the room doesn't exist upon sending the request
     */
    case CouldNotDeleteRoom
    /**
     *	Received from the web api if the user tries to update the room with errors
     */
    case CouldNotUpdateRoom
    /**
     *	Received from the web api if there's trouble fetching the users from the database
     */
    case CouldNotGetUsers
    /**
     *	Received from the web api if there's trouble creating a user on the database
     */
    case CouldNotAddUser
    /**
     *	Received from the web api if there's trouble updating the user on the database
     */
    case CouldNotUpdateUser
    /**
     *	Received from the web api if the iOS application requests a specific user with an ID but that user doesn't exist
     */
    case UserNotFound
    /**
     *	Received from the web api if trying to delete a user causes trouble, not used on iOS
     */
    case CouldNotDeleteUser
    /**
     *	Received from the web api if there's trouble fetching the questions
     */
    case CouldNotGetQuestions
    /**
     *	Received from the web api if the iOS application sends a question with a type that is not recognized by the web api. This is to support future features for different types of questions
     */
    case CouldNotGetQuestionType
    /**
     *	Received from the web api if the iOS application creates a question where the ID is not null, should be null as the web api sets this ID
     */
    case NewQuestionIdShouldBeNull
    /**
     *	Can be received from the web api on many occasions. Such as sending a chat message, creating a question or getting room by id if the room that belongs to that command doesn't exist
     */
    case RoomDoesNotExist
    /**
     *	Received from the web api if there's trouble adding the question on the database
     */
    case CouldNotAddQuestion
    /**
     *	Received from the web api if there trouble updating the question on the database
     */
    case CouldNotUpdateQuestion
    /**
     *	Received from the web api if user tries to answer a question where the timer has run out
     */
    case QuestionExpired
    /**
     *	Received from the web api if user tries to connect with LDAP and there's an error. Not used in iOS app
     */
    case ActiveDirctoryError
    /**
     *	Received from the web api if there's trouble loading the chatmessages for a room
     */
    case CouldNotGetChatMessages
}