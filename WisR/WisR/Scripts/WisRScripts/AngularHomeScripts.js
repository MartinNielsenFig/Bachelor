/**
 * @ngdoc controller
 * @name dashboard.controller:HomeController
 * @description
 * A description of the controller, service or filter
 */

app.controller("HomeController", [
    '$scope', '$http', '$location', '$window', 'configs', function ($scope, $http, $location, $window, configs) {



        //#region SignalR functions
        ///Connect to SignalR hub and wait for new room
        $(function () {

            /// Declare a proxy to reference the hub. 
            var hub = $.connection.roomHub;
            /// Create a function that the hub can call to broadcast messages.
            hub.client.broadcastRoom = function (roomToAdd) {
                $scope.Rooms.push(JSON.parse(roomToAdd));
                $scope.$apply();
            };
            $.connection.hub.start();
        });

        ///Connect to SignalR hub and wait for room update
        $(function () {
            /// Declare a proxy to reference the hub. 
            var hub = $.connection.roomHub;
            /// Create a function that the hub can call to broadcast messages.
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
        //#region Declaration of default scope values
        ///Declare default values
        $scope.RoomName = "";
        $scope.Radius = 50;
        $scope.UniqueTag = "";
        $scope.Password = "";
        $scope.HasChat = true;
        $scope.UserCanAsk = true;
        $scope.AllowAnonymous = true;
        $scope.UseLocation = false;
        //#endregion
        //#region Room specific functions
        ///Function to get all rooms when loading page
        var getRooms = function () {
            $http.get(configs.restHostName + '/Room/GetAll').then(function (response) {
                $scope.Rooms = response.data;
                $scope.userId = window.userId;
                $scope.locationLatitude = $scope.currentLocation.coords.latitude;
                $scope.locationLongitude = $scope.currentLocation.coords.longitude;
                $scope.roomsLoaded = true;
            });
        };

        ///Creates a new room, and connects to it
        $scope.postRoom = function () {
            ///Make get request for json object conversion
            $http.post('/Home/toJsonRoom',
                {
                    RoomName: $scope.RoomName,
                    CreatedBy: window.userId,
                    locationTimestamp: $scope.currentLocation.timestamp,
                    locationLatitude: $scope.currentLocation.coords.latitude,
                    locationLongitude: $scope.currentLocation.coords.longitude,
                    locationAccuracyMeters: $scope.currentLocation.coords.accuracy,
                    locationFormattedAddress: $scope.currentAddress,
                    radius: $scope.Radius,
                    tag: $scope.UniqueTag,
                    password: $scope.Password,
                    hasChat: $scope.HasChat,
                    userCanAsk: $scope.UserCanAsk,
                    allowAnonymous: $scope.AllowAnonymous,
                    useLocation: $scope.UseLocation
                }).
                then(function (response) {
                    ///Use response to send to REST API
                    $http.post(configs.restHostName + '/Room/CreateRoom', { Room: JSON.stringify(response.data) }).
                        then(function (response) {
                            ///Check for error messages
                            if (response.data.ErrorMessage != undefined) {
                                $("#RoomCreationError").text("Error: " + response.data.ErrorMessage);
                                return;
                            }

                            var room = { _id: response.data }
                            $scope.changeViewToRoom(room);
                        });
                });
        }
        ///Changes to view to a new room
        $scope.changeViewToRoom = function (room) {
            if (!room.AllowAnonymous && $scope.userId == 'NoUser') {
                $scope.Message = "The room-tag you have entered requires you to be logged in";
            } else {
                $scope.RoomId = room._id;
                var url = $("#RedirectTo").val() + "?RoomId=" + $scope.RoomId;
                location.href = url;
            }

        }

        ///Connects to a new room based on it's tag
        $scope.connectWithUniqueTag = function () {
            $http.post(configs.restHostName + '/Room/GetByUniqueTag', { tag: $scope.uniqueRoomTag }).then(function (response) {
                ///TODO verification of response
                if (response.data._id != undefined) {
                    $scope.changeViewToRoom(response.data);
                } else {
                    $scope.Message = "No room with the tag: " + $scope.uniqueRoomTag;
                }
            });
        }

        ///Calls and get the currentlocation, and after that gets the rooms
        navigator.geolocation.getCurrentPosition(function (position) {
            $scope.currentLocation = position;
            $("#loadingLabel").text('Loading rooms...');
            getRooms();
            var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            geocoder.geocode({ 'location': latLng }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[1]) {
                        $scope.currentAddress = results[1].formatted_address;
                    } else {
                        window.alert('No results found');
                    }
                } else {
                    window.alert('Geocoder failed due to: ' + status);
                }
            });
        });
        //#endregion
    }
]);

