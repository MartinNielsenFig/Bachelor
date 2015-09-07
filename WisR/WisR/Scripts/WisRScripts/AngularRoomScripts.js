app.controller("RoomController", [
    '$scope', '$http', 'configs', function($scope, $http, configs) {

        //Get all questions
        var getQuestions = function() {
            $http.get(configs.restHostName + '/Question/GetAll').then(function(response) {
                $scope.Questions = response.data;
            });
        };
        getQuestions();

        //Get information about this specific room
        //Get all questions
        var getRoom = function () {
            $http.post(configs.restHostName + '/Room/GetById',{id:MyRoomIdFromViewBag}).then(function (response) {
                $scope.CurrentRoom = response.data;
            });
        };
        getRoom();

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
        $scope.ToggleShowQuestionTables = function() {
            $scope.SpecificQuestionShown = !$scope.SpecificQuestionShown;
        }


        //Function for creating a question
        $scope.postQuestion = function() {
            //Make get request for json object conversion
            $http.post('/Room/toJsonQuestion', { CreatedBy: window.userId, RoomId: MyRoomIdFromViewBag, Downvotes: 0, Image: $scope.Picture, Upvotes: 0, QuestionText: $scope.QuestionText }).
                then(function(response) {
                    //Use response to send to REST API
                    $http.post(configs.restHostName + '/Question/CreateQuestion', { question: JSON.stringify(response.data), type: $scope.QuestionType });
                });
        }

        //Function for creating a chatMessage
        $scope.postChatMessage = function (message) {
            //Clear text area, so that it is ready for a new message
            $scope.textAreaModel = "";

            //Make get request for json object conversion
            $http.post('/Room/toJsonChatMessage', { userId:window.userId,roomId:MyRoomIdFromViewBag,text: message}).
                then(function (response) {
                    //Use response to send to REST API
                    $http.post(configs.restHostName + '/Chat/CreateChatMessage', { ChatMessage: JSON.stringify(response.data)});
                });
        }
    }
]);