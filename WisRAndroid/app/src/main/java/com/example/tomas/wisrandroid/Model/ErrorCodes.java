package com.example.tomas.wisrandroid.Model;


public enum ErrorCodes {
    RoomSecretAlreadyInUse (0),
    NoRoomWithThatSecret (1),
    RabbitMqError (2),
    StringIsNotJsonFormat (3),
    CouldNotParseJsonToClass (4),
    CouldNotAddRoomToDatabase (5),
    CouldNotGetRoomsFromDatabase (6),
    CouldNotDeleteAllChatMessages (7),
    CouldNotDeleteAllQuestions (8),
    CouldNotDeleteRoom (9),
    CouldNotUpdateRoom (10),
    CouldNotGetUsers (11),
    CouldNotAddUser (12),
    CouldNotUpdateUser (13),
    UserNotFound (14),
    CouldNotDeleteUser (15),
    CouldNotGetQuestions (16),
    CouldNotGetQuestionType (17),
    NewQuestionIdShouldBeNull (18),
    RoomDoesNotExist (19),
    CouldNotAddQuestion (20),
    CouldNotUpdateQuestion (21),
    QuestionExpired (22),
    ActiveDirctoryError (23),
    CouldNotGetChatMessages (24)
    ;

    private final int ErrorCodesKey;

    ErrorCodes(int errorCodeKey){this.ErrorCodesKey = errorCodeKey;}

    public int getErrorCodeKey() {
        return this.ErrorCodesKey;
    }

    public static ErrorCodes fromKey(int key) {
        for(ErrorCodes type : ErrorCodes.values()) {
            if(type.getErrorCodeKey() == key) {
                return type;
            }
        }
        return null;
    }
}
