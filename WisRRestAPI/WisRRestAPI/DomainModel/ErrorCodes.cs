using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WisRRestAPI {

    //Use describing names.
    public enum ErrorCodes {
        RoomSecretAlreadyInUse,
        NoRoomWithThatSecret,
        RabbitMqError,
        StringIsNotJsonFormat,
        CouldNotParseJsonToClass,
        CouldNotAddRoomToDatabase,
        CouldNotGetRoomsFromDatabase,
        CouldNotDeleteAllChatMessages,
        CouldNotDeleteAllQuestions,
        CouldNotDeleteRoom,
        CouldNotUpdateRoom,
        CouldNotGetUsers,
        CouldNotAddUser,
        CouldNotUpdateUser,
        UserNotFound,
        CouldNotDeleteUser,
        CouldNotGetQuestions,
        CouldNotGetQuestionType,
        NewQuestionIdShouldBeNull,
        RoomDoesNotExist,
        CouldNotAddQuestion,
        CouldNotUpdateQuestion,
        QuestionExpired, 
        ActiveDirctoryError,
        CouldNotGetChatMessages,
        WrongQuestionFormat,
        WrongMessageFormat,
        WrongRoomFormat,
        WrongUserFormat
    }
}