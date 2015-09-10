﻿var app = angular.module("wisrApp", []);

//Function that returns true if room should be added to table
var shouldBeAdded=function(room,scope) {
    if (room.UseLocation === true) {
        var temp = (getDistanceFromLatLonInKm(room.Location.Latitude, room.Location.Longitude, scope.currentLocation.coords.latitude, scope.currentLocation.coords.longitude) * 1000);

        if (temp <= (room.Radius + room.Location.AccuracyMeters + scope.currentLocation.coords.accuracy)) {
            return true;
        }
    }
    return false;
}

app.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);
app.controller("UserController", ['$scope', function ($scope) {
}]);

app.filter('roomsNear', function () {
    return function (rooms, scope) {
        if (rooms != undefined && scope.currentLocation != undefined) {
            var filtered = [];
            for (var i = 0; i < rooms.length; i++) {
                var room = rooms[i];
                if (shouldBeAdded(room, scope))
                    filtered.push(room);
            }
            return filtered;
        }
    };
});
app.controller("HomeController", ['$scope', '$http', '$location', '$window', 'configs', function ($scope, $http, $location, $window, configs) {
    //SignalR initiation
    $(function () {
        // Declare a proxy to reference the hub. 
        var hub = $.connection.roomCreationHub;
        // Create a function that the hub can call to broadcast messages.
        hub.client.broadcastRoom = function (roomToAdd) {
            $scope.Rooms.push(JSON.parse(roomToAdd));
            $scope.$apply();
        };
        $.connection.hub.start();
    });

    //Function to get all rooms when loading page
    var getRooms = function () {
        $http.get(configs.restHostName + '/Room/GetAll').then(function (response) {
            $scope.Rooms = response.data;
            $scope.userId = window.userId;
            $scope.locationLatitude = $scope.currentLocation.coords.latitude;
            $scope.locationLongitude = $scope.currentLocation.coords.longitude;
            $scope.roomsLoaded = true;
        });
    };
    //Declare default values
    $scope.RoomName = "";
    $scope.Radius = 50;
    $scope.UniqueTag = "";
    $scope.Password = "";
    $scope.HasChat = true;
    $scope.UserCanAsk = true;
    $scope.AllowAnonymous = true;
    $scope.UseLocation = true;

    //Calls and get the currentlocation, and after that gets the rooms
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

    $scope.changeViewToRoom = function (roomId) {
        $scope.RoomId = roomId;
        var url = $("#RedirectTo").val() + "?RoomId=" + $scope.RoomId;
        location.href = url;
    }
    $scope.connectWithUniqueTag = function () {
        $http.post(configs.restHostName + '/Room/GetByUniqueTag', { tag: $scope.uniqueRoomTag }).then(function (response) {
            //TODO verification of response
            if (response.data._id != undefined) {
                $scope.changeViewToRoom(response.data._id);
            } else {
                alert("No room with the tag: " + $scope.uniqueRoomTag);
            }



        });
    }

    $scope.postRoom = function () {
        //Make get request for json object conversion
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
            //Use response to send to REST API
            $http.post(configs.restHostName + '/Room/CreateRoom', { Room: JSON.stringify(response.data) }).
            then(function (response) {
                $scope.changeViewToRoom(response.data);
            });
        });
    }



}])

//http://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);  // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)
    ;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
}

function deg2rad(deg) {
    return deg * (Math.PI / 180)
}
function calcDistance(p1, p2) {
    return (google.maps.geometry.spherical.computeDistanceBetween(p1, p2) / 1000).toFixed(2);
}
