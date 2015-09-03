﻿app.controller("RoomController", ['$scope', '$http', 'configs', function ($scope, $http, configs) {

    var getQuestions = function () {
        $http.get(configs.restHostName + '/Question/GetAll').then(function (response) {
            $scope.Questions = response.data;
        });
    };
    getQuestions();
    $scope.SpecificQuestionShown = false;
    $scope.QuestionText = "Enter question";
    $scope.QuestionType = "TextualQuestion";
    $scope.ResponseOptions = "Add response options";
    $scope.Picture = "Add a picture";

    //function for showing a specific question
    $scope.ShowSpecificQuestion = function(question) {
        $scope.ToggleShowQuestionTables();
        $scope.SpecificQuestion = question;
    }
    $scope.ToggleShowQuestionTables = function () {
        $scope.SpecificQuestionShown = !$scope.SpecificQuestionShown;
    }


    //Function for creating a question
    $scope.postQuestion = function () {
        //Make get request for json object conversion
        $http.post('/Room/toJsonQuestion', { CreatedBy: null, Downvotes: 0, Image: $scope.Picture, Upvotes: 0, QuestionText: $scope.QuestionText }).
  then(function (response) {

      //Use response to send to REST API
      $http.post(configs.restHostName + '/Question/CreateQuestion', { roomId: MyRoomIdFromViewBag, question: JSON.stringify(response.data), type: $scope.QuestionType }).
  then(function (response) {

  }, function (response) {

  });

  }, function (response) {

  });
    }



}])