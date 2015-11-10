﻿/**
 * @ngdoc controller
 * @name WisR.controller:HomeController
 * @description
 * Controller for the Home View of the application
 */
app.controller("HomeController", [
    '$scope', '$http', '$location', '$window', 'configs', function ($scope, $http, $location, $window, configs) {
        //#region Declaration of scope values

        ///Declare default values
        /**
         * @ngdoc property
         * @name .#RoomName 
         * @returns {String} RoomName 
         * @propertyOf WisR.controller:HomeController 
         * @description Property that is set when creating a new room in the modal window 
         * Default is empty string
         */
        $scope.RoomName = "";
        /**
        * @ngdoc property
        * @name .#Radius
        * @returns {Integer} Radius
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Default is 50
        */
        $scope.Radius = 50;
        /**
        * @ngdoc property
        * @name .#UniqueSecret
        * @returns {String} UniqueSecret
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Default is Empty string
        */
        $scope.UniqueSecret = "";
        /**
        * @ngdoc property
        * @name .#Password
        * @returns {String} Password
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Default is Empty string
        */
        $scope.Password = "";
        /**
       * @ngdoc property
       * @name .#HashedPassword
       * @returns {String} HashedPassword
       * @propertyOf WisR.controller:HomeController
       * @description Property the SHA512 hashed version of the password
       * Default is Empty string
       */
        $scope.HashedPassword = "";
        /**
        * @ngdoc property
        * @name .#HasChat
        * @returns {Boolean} HasChat
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Default is Empty string
        */
        $scope.HasChat = true;
        /**
        * @ngdoc property
        * @name .#UsersCanAsk
        * @returns {Boolean} UsersCanAsk
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Describes whether users can ask questions in the room.
        * Default is true
        */
        $scope.UserCanAsk = true;
        /**
        * @ngdoc property
        * @name .#AllowAnonymous
        * @returns {Boolean} AllowAnonymous
        * @propertyOf WisR.controller:HomeController
        * @description Property that is set when creating a new room in the modal window
        * Describes whether anonymous users are allowed in the room.
        * Default is Empty string
        */
        $scope.AllowAnonymous = true;
        /**
         * @ngdoc property
         * @name .#UseLocation
         * @returns {Boolean} UseLocation
         * @propertyOf WisR.controller:HomeController
         * @description Property that is set when creating a new room in the modal window
         * Describes whether is should be possible to find the room by being near it(location wise)
         * Default is Empty string
         */
        $scope.UseLocation = false;
        /**
        * @ngdoc property 
        * @name .#Rooms 
        * @returns {Array<Room>} Rooms 
        *  @propertyOf WisR.controller:HomeController 
        * @description Collection that contains all rooms, this container gets filtered by location and shown in the table 
        */
        $scope.Rooms = null;
        /**
        * @ngdoc property
        * @name .#userId
        * @returns {String} userId
        * @propertyOf WisR.controller:HomeController
        * @description Property that contains id of the current user. This id is generated by the database.
        */
        $scope.userId = null;
        /**
         * @ngdoc property
         * @name .#locationLatitude
         * @returns {Float} locationLatitude
         * @propertyOf WisR.controller:HomeController
         * @description Property that contains the latitude information about the current users location
         */
        $scope.locationLatitude = null;
        /**
         * @ngdoc property
         * @name .#locationLongitude
         * @returns {Float} locationLongitude
         * @propertyOf WisR.controller:HomeController
         * @description Property that contains the longitude information about the current users location
         */
        $scope.locationLongitude = null;
        /**
         * @ngdoc property
         * @name .#currentAddress
         * @returns {String} currentAddress
         * @propertyOf WisR.controller:HomeController
         * @description Property that contains the formatted address for the current location
         */
        $scope.currentAddress = null;
        /**
         * @ngdoc property
         * @name .#roomsLoaded
         * @returns {Boolean} roomsLoaded
         * @propertyOf WisR.controller:HomeController
         * @description Property that states whether the rooms have been loaded from the database(Used to remove loading animation from view)
         */
        $scope.roomsLoaded = null;
        /**
         * @ngdoc property
         * @name .#uniqueRoomSecret
         * @returns {String} uniqueRoomSecret
         * @propertyOf WisR.controller:HomeController
         * @description Property that contains string written in the "UniqueSecret" field when trying to connect to a room by unique secret.
         */
        $scope.uniqueRoomSecret = null;
        /**
         * @ngdoc property
         * @name .#Message
         * @returns {String} Message
         * @propertyOf WisR.controller:HomeController
         * @description Property that contains string written in the message div. Used for error messages when connecting to a room
         */
        $scope.Message = null;
        /**
                 * @ngdoc property
                 * @name .#RoomsMessage
                 * @returns {String} RoomsMessage
                 * @propertyOf WisR.controller:HomeController
                 * @description Property that contains string written in the rooms
                 */
        $scope.RoomsMessage = Resources.NoRoomsNearby;
        //#endregion

        //#region Notification functions
        /**
           * @ngdoc method
           * @name HomeController#spawnNotification
           * @methodOf WisR.controller:HomeController
           * @description
           * Function that creates a browser notification if the user has allowed it, further documentation: https://developer.mozilla.org/en-US/docs/Web/API/Notification
           * @param {String} theBody The body string of the notification as specified in the options parameter of the constructor.
           * @param {String} theIcon The URL of the image used as an icon of the notification as specified in the options parameter of the constructor.
           * @param {String} theTitle The title of the notification as specified in the options parameter of the constructor.
           * @param {String} link redirect link for the onclick event
           */
        Notification.requestPermission();
        $scope.spawnNotification = function (theBody, theIcon, theTitle, link) {
            var options = {
                body: theBody,
                icon: theIcon
            }
            var n = new Notification(theTitle, options);
            n.onclick = function () {
                $window.location.href = link;
                $window.focus();
            }
            setTimeout(n.close.bind(n), 4000);
        }
        //#endregion

        //#region SignalR functions
        ///Connect to SignalR hub and wait for new room

        $(function () {
            /// Declare a proxy to reference the hub.
            var hub = $.connection.roomHub;
            /// Create a function that the hub can call to broadcast messages.
            /**
            * @ngdoc method
            * @name HomeController#broadcastRoom
            * @methodOf WisR.controller:HomeController
            * @description
            * Function that is called when a new room has been created. This gets called by the function "Send" in the RoomHub.
            * The function adds the new room to the Rooms collection.
            * @param {Room} roomToAdd The room to add to the rooms collection
            */

            hub.client.broadcastRoom = function (roomToAdd) {
                var parsedRoomToAdd = JSON.parse(roomToAdd);
                $scope.Rooms.push(parsedRoomToAdd);
                $scope.$apply();
                //Spawn a notification if this is near the user and the user self didn't create it
                if (($scope.currentUser == undefined || parsedRoomToAdd.CreatedById != $scope.currentUser._id) && shouldBeAdded(parsedRoomToAdd, $scope)) {
                    $scope.spawnNotification(parsedRoomToAdd.Name, null, "WisR", "/Room?RoomId=" + parsedRoomToAdd._id);
                }
            };
            /// Create a function that the hub can call to broadcast messages.
            /**
            * @ngdoc method
            * @name HomeController#broadcastDeleteRoom
            * @methodOf WisR.controller:HomeController
            * @description
            * Function that is called when a room should be deleted
            * @param {Room} roomToAdd The room to delete
            */

            hub.client.broadcastDeleteRoom = function (roomToDelete) {
                var index = findWithAttr($scope.Rooms, "_id", roomToDelete);
                if (index > -1) {
                    $scope.Rooms.splice(index, 1);
                    $scope.$apply();
                }
            };
            /**
            * @ngdoc method
            * @name HomeController#broadcastUpdateRoom
            * @methodOf WisR.controller:HomeController
            *
            * @description
            * Function that is called when a room has been changed. This gets called by the function "Update" in the RoomHub.
            * The function adds the updates to the room in the Rooms collection.
            * This function is used when the location of a room is updated.
            * @param {Room} roomToUpdate The room to update in the rooms collection
            */
            hub.client.broadcastUpdateRoom = function (roomToUpdate) {
                var tempRoom = JSON.parse(roomToUpdate);
                for (var i = 0; i < $scope.Rooms.length; i++) {
                    if ($scope.Rooms[i]._id == tempRoom._id) {
                        $scope.Rooms[i] = tempRoom;
                        $scope.$apply();
                    }
                }
            };
            $.connection.hub.start();
        });

        //#endregion

        //#region Room specific functions

        ///Function to get all rooms when loading page
        /**
        * @ngdoc method
        * @name HomeController#getRooms
        * @methodOf WisR.controller:HomeController
        *
        * @description
        * Function to get all rooms when loading page, this function also maps the userId from the window to the property "userId", and the location of the current user to the properties "locationLatitude" and "locationLongitude"
        */
        $scope.getRooms = function () {
            $http.get(configs.restHostName + '/Room/GetAll').then(function (response) {
                if (response.data.ErrorType != 0) {
                    $scope.RoomsMessage = $scope.GetErrorOutput(response.data.Errors);
                    return;
                }

                $scope.Rooms = JSON.parse(response.data.Data);
                $scope.userId = window.userId;
                $scope.locationLatitude = $scope.currentLocation.coords.latitude;
                $scope.locationLongitude = $scope.currentLocation.coords.longitude;
                $scope.roomsLoaded = true;
            }, $scope.onErrorAlert);
        };
        /**
        * @ngdoc method
        * @name HomeController#postRoom
        * @methodOf WisR.controller:HomeController
        *
        * @description
        * Function to create a new room on the database with the entered information from the modal window.
        * If no error is returned, this function calls "changeViewToRoom" and adds room to connected rooms(so that user doesn't have to enter password)
        */
        ///Creates a new room, and connects to it
        $scope.postRoom = function () {
            if ($scope.Password.length !== 0) {
                $scope.HashedPassword = CryptoJS.SHA512($scope.Password).toString();
            }

            ///Make get request for json object conversion
            $http.post(configs.baseHostName + '/Home/toJsonRoom',
                {
                    RoomName: $scope.RoomName,
                    CreatedBy: window.userId,
                    locationTimestamp: $scope.currentLocation.timestamp,
                    locationLatitude: $scope.currentLocation.coords.latitude,
                    locationLongitude: $scope.currentLocation.coords.longitude,
                    locationAccuracyMeters: $scope.currentLocation.coords.accuracy,
                    locationFormattedAddress: $scope.currentAddress,
                    radius: $scope.Radius,
                    secret: $scope.UniqueSecret,
                    password: $scope.HashedPassword,
                    hasChat: $scope.HasChat,
                    userCanAsk: $scope.UserCanAsk,
                    allowAnonymous: $scope.AllowAnonymous,
                    useLocation: $scope.UseLocation
                }).
                then(function (response) {
                    if (response.data.ErrorType != 0) {
                        $scope.RoomCreationError = $scope.GetErrorOutput(response.data.Errors);
                        return;
                    }
                    ///Use response to send to REST API
                    $http.post(configs.restHostName + '/Room/CreateRoom', { Room: response.data.Data }).
                        then(function (response) {
                            ///Check for error messages
                            if (response.data.ErrorType !== 0) {
                                $scope.RoomCreationError = $scope.GetErrorOutput(response.data.Errors);
                                return;
                            }

                            //Add roomId to connected rooms for the user
                            var room = {_id:response.data.Data} 
                            $scope.currentUser.ConnectedRoomIds.push(room._id);

                            var newIds = "";
                            for (var i = 0; i < $scope.currentUser.ConnectedRoomIds.length; i++) {
                                if (i != $scope.currentUser.ConnectedRoomIds.length - 1) {
                                    newIds = newIds + $scope.currentUser.ConnectedRoomIds[i] + ',';
                                } else {
                                    newIds = newIds + $scope.currentUser.ConnectedRoomIds[i];
                                }
                            }

                            $http.post(configs.baseHostName + '/Home/toJsonUser', {
                                facebookId: $scope.currentUser.FacebookId,
                                lDAPUserName: $scope.currentUser.LDAPUserName,
                                displayName: $scope.currentUser.DisplayName,
                                email: $scope.currentUser.Email,
                                encryptedPassword: $scope.currentUser.EncryptedPassword,
                                connectedRoomIds: newIds
                            }).then(function (response) {
                                if (response.data.ErrorType != 0) {
                                    alert($scope.GetErrorOutput(response.data.Errors));
                                    return;
                                }
                                ///Use response to send to REST API
                                $http.post(configs.restHostName + '/User/UpdateUser', { User: response.data.Data, Id: $scope.currentUser._id }).
                                    then(function (response) {
                                        if (response.data.ErrorType != 0) {
                                            alert($scope.GetErrorOutput(response.data.Errors));
                                            return;
                                        }
                                    });
                            }, $scope.onErrorAlert);

                            $scope.changeViewToRoom(room);
                        }, $scope.onErrorAlert);
                }, $scope.onErrorAlert);
        }
        /**
       * @ngdoc watch
       * @name HomeController#userIdWatch
       * @methodOf WisR.controller:HomeController
       *
       * @description
       * Function that watches the userId variable and fetches user from restAPI when it changes
       * @param {Room} room The room that the view changes to
       */
        $scope.$watch(function () {
            return $window.userId;
        }, function (n, o) {
            $scope.userId = n;
            if (n == "NoUser") {
                $scope.anonymousUser = true;
            }
            else if (n != undefined) {
                $http.post(configs.restHostName + '/User/GetById', { id: n }).then(function (response) {
                    if (response.data.ErrorType != 0) {
                        alert($scope.GetErrorOutput(response.data.Errors));
                    } else {
                        $scope.currentUser = JSON.parse(response.data.Data);
                    }
                }, $scope.onErrorAlert);
            }
        });
        /**
       * @ngdoc method
       * @name HomeController#changeViewToRoom
       * @methodOf WisR.controller:HomeController
       *
       * @description
       * Function to change view to a specific room. Contains validation if room has allowAnonymous set to false
       * @param {Room} room The room that the view changes to
       */

        ///Changes to view to a new room
        $scope.changeViewToRoom = function (room) {
            if (!room.AllowAnonymous && $scope.userId == 'NoUser') {
                $scope.Message = window.Resources.RoomSecretRequiresLogin;
            } else {
                $scope.RoomId = room._id;
                var url = $("#RedirectTo").val() + "?RoomId=" + $scope.RoomId;
                $window.location.href = url;
            }
        }
        /**
      * @ngdoc method
      * @name HomeController#connectWithUniqueSecret
      * @methodOf WisR.controller:HomeController
      *
      * @description
      * Function that changes view to a specific room, with the secret in the "uniqueRoomSecret" property
      */

        ///Connects to a new room based on it's secret
        $scope.connectWithUniqueSecret = function () {
            $http.post(configs.restHostName + '/Room/GetByUniqueSecret', { secret: $scope.uniqueRoomSecret }).then(function (response) {
                if (response.data.ErrorType != 0) {
                    $scope.Message = $scope.GetErrorOutput(response.data.Errors);
                }else if (JSON.parse(response.data.Data)._id != undefined) {
                    $scope.changeViewToRoom(JSON.parse(response.data.Data));
                }
            }, $scope.onErrorAlert);
        }
        /**
      * @ngdoc method
      * @name HomeController#getCurrentPosition
      * @methodOf WisR.controller:HomeController
      *
      * @description
      * Geolocation function that gets called at load of the home index page to get the location of the user. When the location is fetched the property currentLocation is set with the value and the getRooms function is called.
      * At this point the function calls geocode to get the formatted address
      */
        //this check is to make the tests excecuteable
        if (navigator.geolocation != undefined) {
            ///Calls and get the currentlocation, and after that gets the rooms
            navigator.geolocation.getCurrentPosition(function (position) {
                $scope.currentLocation = position;
                $("#loadingLabel").text(window.Resources.LoadingRooms + "...");
                $scope.getRooms();
                var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                geocoder.geocode({ 'location': latLng }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        if (results[1]) {
                            $scope.currentAddress = results[1].formatted_address;
                        } else {
                            window.alert(window.Resources.NoResponseFound);
                        }
                    } else {
                        window.alert(window.Resources.GeoCoderFailedDueTo + status);
                    }
                });
            });

        }
        /**
      * @ngdoc method
      * @name HomeController#deleteRoom
      * @methodOf WisR.controller:HomeController
      *
      * @description
      * Function for deleting room
      * @param {Room} roomToDelete The room to delete
      */
        $scope.deleteRoom = function (roomToDelete) {
            $http.delete(configs.restHostName + '/Room/DeleteRoom', { params: { id: roomToDelete._id } }).then(function (response) {
                ///Check for errors on request
                if (response.data.ErrorMessage != undefined) {
                    $scope.roomDeleteMessage = response.data.ErrorMessage;
                    return;
                } else {
                    $scope.modalChanger("deleteRoomModal","hide");
                }
            }, $scope.onErrorAlert);
        }

        //#endregion

        //#region Helper Functions
        /**
       * @ngdoc method
       * @name RoomController#GetErrorOutput
       * @methodOf WisR.controller:HomeController
       * @description
       * Helper function toget the error outputs
       * @param {Array<ErrorCode>} errors array of errors
       */
        $scope.GetErrorOutput = function(errors) {
            var output = Resources.Error + ": ";
            for (var i = 0; i < errors.length; i++) {
                var error = "";
                switch(errors[i]) {
                    case 0:
                        error = Resources.RoomSecretAlreadyInUse +" "+ Resources.Error + ":" +errors[i];
                        break;
                    case 1:
                        error = Resources.NoRoomWithThatSecret + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 2:
                        error = Resources.RabbitMqError + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 3:
                        error = Resources.StringIsNotJsonFormat + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 4:
                        error = Resources.CouldNotParseJsonToClass + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 5:
                        error = Resources.CouldNotAddRoomToDatabase + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 6:
                        error = Resources.CouldNotGetRoomsFromDatabase + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 7:
                        error = Resources.CouldNotDeleteAllChatMessages + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 8:
                        error = Resources.CouldNotDeleteAllQuestions + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 9:
                        error = Resources.CouldNotDeleteRoom + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 10:
                        error = Resources.CouldNotUpdateRoom + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 11:
                        error = Resources.CouldNotGetUsers + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 12:
                        error = Resources.CouldNotAddUser + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 13:
                        error = Resources.CouldNotUpdateUser + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 14:
                        error = Resources.UserNotFound + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 15:
                        error = Resources.CouldNotDeleteUser + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 16:
                        error = Resources.CouldNotGetQuestions + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 17:
                        error = Resources.CouldNotGetQuestionType + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 18:
                        error = Resources.NewQuestionIdShouldBeNull + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 19:
                        error = Resources.RoomDoesNotExist + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 20:
                        error = Resources.CouldNotAddQuestion + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 21:
                        error = Resources.CouldNotUpdateQuestion + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 22:
                        error = Resources.QuestionExpired + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 23:
                        error = Resources.ActiveDirctoryError + " " + Resources.Error + ":" + errors[i];
                        break;
                    case 24:
                        error = Resources.CouldNotGetChatMessages + " " + Resources.Error + ":" + errors[i];
                        break;
                    default:
                        error = "ERROR NOT HANDLED YET";
                }
                output = output + error;
            }
            return output;
        }
        /**
                * @ngdoc method
                * @name RoomController#monErrorAlert
                * @methodOf WisR.controller:HomeController
                * @description
                * Helper function to alert that error has occured when communicating with restapi
                * @param {Error} error the error that has occured
                */
        $scope.onErrorAlert = function (error) {
            alert(Resources.NoConnectionToServer);
        }
        /**
        * @ngdoc method
        * @name RoomController#modalChanger
        * @methodOf WisR.controller:HomeController
        * @description
        * Helper function to change the state of a modal window
        * @param {String} id the id of the modal to change
        * @param {String} state the state we wish to change to
        */
        ///Modal state changer
        $scope.modalChanger = function (id, state) {
            $("#" + id).modal(state);
        }
        /**
       * @ngdoc method
       * @name HomeController#toggleDropdown
       * @methodOf WisR.controller:HomeController
       *
       * @description
       * Function that toggles the visibility of the dropdown
       * @param {String} roomId id used to uniquely identify the dropdown
       */
        $scope.toggleDropdown = function (roomId) {
            $("#dropdown" + roomId).dropdown("toggle");
        }
        /**
       * @ngdoc method
       * @name HomeController#toggleModalWithRoom
       * @methodOf WisR.controller:HomeController
       *
       * @description
       * Function that toggles the visibility of the modal window and adds the room to a scope variable so that we can show specific information on the modal window
       * @param {String} modal id used to uniquely identify the modal
       * @param {Room} room room that is being sent to the modal window
       */
        $scope.toggleModalWithRoom = function (modal, room) {
            $scope.SpecificRoom = room;
            $(modal).modal('toggle');
        }

        /**
       * @ngdoc method
       * @name HomeController#findWithAttr
       * @methodOf WisR.controller:HomeController
       *
       * @description
       * Function that finds the index of a property with a specific value in an array. Returns -1 if the value is not found
       * @param {Array} array the array to traverse
       * @param {Attribute} attr the attribute to check for the given value
       * @param {Attribute} value the value to check the attribute for
       */
        function findWithAttr(array, attr, value) {
            for (var i = 0; i < array.length; i += 1) {
                if (array[i][attr] === value) {
                    return i;
                }
            }
            return -1;
        }
        //#endregion
    }
]);