﻿using System;
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
        CouldNotGetRoomsFromDatabase
    }
}