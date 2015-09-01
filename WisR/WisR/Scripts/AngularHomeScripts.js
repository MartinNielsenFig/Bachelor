var app = angular.module("wisrApp", []);
app.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);

app.controller("HomeController", ['$scope', '$http', function ($scope, $http) {
    $scope.title = 'Martin sucks';
    $scope.postRoom = function () {
        //Make get request for json object conversion
        $http.post('/Home/toJsonRoom', { RoomName: $scope.RoomName, CreatedBy: $scope.CreatedBy, location: currentLocation, radius: $scope.Radius, tag: $scope.UniqueTag, password: $scope.Password, hasChat: $scope.HasChat, userCanAsk: $scope.UserCanAsk, allowAnonymous: $scope.AllowAnonymous }).
  then(function (response) {

      //Use response to send to REST API
      $http.post('http://localhost:1337/Room/CreateRoom', { Room: JSON.stringify(response.data) }).
  then(function (response) {

  }, function (response) {

  });

  }, function (response) {

  });
    }



}])