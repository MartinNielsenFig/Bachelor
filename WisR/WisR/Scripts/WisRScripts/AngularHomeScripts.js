var app = angular.module("wisrApp", []);
app.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);
app.controller("UserController", ['$scope', function($scope) {
    var createUser= function() {
      
    };
    }]);
app.controller("HomeController", ['$scope', '$http', '$location', '$window', 'configs', function ($scope, $http, $location,$window, configs) {
    var getRooms = function() {
        $http.get(configs.restHostName+'/Room/GetAll').then(function(response) {
            $scope.Rooms = response.data;
        });
    };

    getRooms();
    $scope.title = 'Room name';
    $scope.RoomName = "";
    $scope.Radius = 2;
    $scope.UniqueTag = "";
    $scope.Password = "";
    $scope.HasChat = true;
    $scope.UserCanAsk = true;
    $scope.AllowAnonymous = true;
    $scope.UseLocation = true;
 
    var changeViewToRoom = function (roomId) {
        $scope.RoomId = roomId;
        var url = $("#RedirectTo").val()+"?RoomId="+$scope.RoomId;
        location.href = url;
    }

    $scope.postRoom = function () {
        //Make get request for json object conversion
        $http.post('/Home/toJsonRoom',
        {
            RoomName: $scope.RoomName,
            CreatedBy: window.userId,
            locationTimestamp:window.currentLocation.timestamp,
            locationLatitude:window.currentLocation.coords.latitude,
            locationLongitude:window.currentLocation.coords.longitude,
            locationAccuracyMeters: window.currentLocation.coords.accuracy,
            locationFormattedAddress: window.currentAddress,
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
            $http.post(configs.restHostName+'/Room/CreateRoom', { Room: JSON.stringify(response.data) }).
            then(function (response) {
                changeViewToRoom(response.data);
                });
        });
    }



}])