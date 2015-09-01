var app = angular.module("wisrApp", []);
app.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);

app.controller("HomeController", ['$scope', '$http', '$location', function ($scope, $http, $location) {
    var getRooms = function() {
        $http.get('http://localhost:1337/Room/GetAll').then(function(response) {
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

 
    var changeViewToRoom = function () {
        var url = 'http://localhost:7331/Room';
        $location.absUrl= url;
    }

    $scope.postRoom = function () {
        //Make get request for json object conversion
        $http.post('/Home/toJsonRoom',
        {
            RoomName: $scope.RoomName,
            CreatedBy: $scope.CreatedBy,
            location: null,
            radius: $scope.Radius,
            tag: $scope.UniqueTag,
            password: $scope.Password,
            hasChat: $scope.HasChat,
            userCanAsk: $scope.UserCanAsk,
            allowAnonymous: $scope.AllowAnonymous
        }).
        then(function (response) {
            //Use response to send to REST API
            $http.post('http://localhost:1337/Room/CreateRoom', { Room: JSON.stringify(response.data) }).
            then(function (response) {
                    //changeViewToRoom();
                });

        });
    }



}])