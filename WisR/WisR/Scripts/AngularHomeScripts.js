var app = angular.module("wisrApp", []);
app.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);

app.controller("HomeController", ['$scope', '$http', function ($scope, $http) {
    $scope.title = 'Martin sucks';
    $scope.postRoom = function () {
        $http.post('http://localhost:1337/Room/CreateRoom', { Room: "" + $scope.RoomName}).
  then(function (response) {

  }, function (response) {

  });
    }


}])