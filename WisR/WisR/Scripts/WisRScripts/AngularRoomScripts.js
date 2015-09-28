//Directive for capturing enter key in angular
//Found at: http://stackoverflow.com/questions/28851893/angularjs-textaera-enter-key-submit-form-with-autocomplete
app.directive('ngEnter', function () {
    return function (scope, element, attrs) {
        element.bind("keydown", function (e) {
            //Check that enter key is hit and that shift key is not(shift to add row to message)
            if (e.which === 13 && !window.event.shiftKey) {
                scope.$apply(function () {
                    scope.$eval(attrs.ngEnter, { 'e': e });
                });
                e.preventDefault();
            }
        });
    };
});

app.controller("RoomController", [
    '$scope', '$http', 'configs', '$window', '$interval', function ($scope, $http, configs, $window, $interval) {
        //default charttype as pie
        $scope.chartType = "Pie";

        //Connect to SignalR hub and wait for chat messages
        $(function () {
            // Declare a proxy to reference the hub. 
            var hub = $.connection.chatHub;
            // Create a function that the hub can call to broadcast messages.
            hub.client.broadcastChatMessage = function (chatMessageToAdd) {
                $scope.ChatMessages.push(JSON.parse(chatMessageToAdd));
                $scope.$apply();
            };
            $.connection.hub.start();
        });
        //Do the same for newly added questions
        $(function () {
            // Declare a proxy to reference the hub. 
            var hub = $.connection.questionHub;
            // Create a function that the hub can call to broadcast messages.
            hub.client.broadcastQuestion = function (questionToAdd) {
                $scope.Questions.push(JSON.parse(questionToAdd));
                $scope.$apply();
            };
            //SignalR function call that the question should be updated
            hub.client.broadcastUpdateQuestion = function (questionToUpdate) {
                var updateTemp = JSON.parse(questionToUpdate);
                var index = findWithAttr($scope.Questions, "_id", updateTemp._id);
                $scope.Questions[index] = updateTemp;
                //If this is the specific question that changed update it with new values
                if ($scope.SpecificQuestion != undefined) {
                    var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                    $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                    //Redraw the result chart
                    $scope.createPieChart();
                }

                $scope.$apply();
            };
            //SignalR function call that the question should be updated with new responses
            hub.client.broadcastUpdateResult = function (questionToUpdate) {
                var updateTemp = JSON.parse(questionToUpdate);
                var index = findWithAttr($scope.Questions, "_id", updateTemp._id);
                $scope.Questions[index].Result = updateTemp.Result;
                //If this is the specific question that changed update it with new values
                if ($scope.SpecificQuestion != undefined) {
                    var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                    $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                    //Redraw the result chart
                    $scope.createPieChart();
                }

                $scope.$apply();
            };
            //SignalR function call that the question should be updated with new votes
            hub.client.broadcastUpdateVotes = function (questionToUpdate) {
                var updateTemp = JSON.parse(questionToUpdate);
                var index = findWithAttr($scope.Questions, "_id", updateTemp._id);

                //AngularJS hack to retrigger filter(it doesn't recognize updated values)
                var temperino = $scope.Questions[index];
                temperino.Votes = updateTemp.Votes;
                $scope.Questions[index] = "";
                $scope.$apply();
                $scope.Questions[index] = temperino;


                //$scope.Questions[index].Votes = updateTemp.Votes;
                //If this is the specific question that changed update it with new values
                if ($scope.SpecificQuestion != undefined) {
                    var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                    $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                }

                $scope.$apply();
            };
            $.connection.hub.start();
        });

        $scope.$on('create', function (event, chart) {
            //If there is allready a chart, destroy it
            if ($scope.chart != undefined) {
                $scope.chart.destroy();
            }
            $scope.chart = chart;
        });
        //Helper function to find index of object in array
        function findWithAttr(array, attr, value) {
            for (var i = 0; i < array.length; i += 1) {
                if (array[i][attr] === value) {
                    return i;
                }
            }
        }
        //watch the window.userId variable
        $scope.$watch(
                function () {
                    return $window.userId;
                }, function (n, o) {
                    $scope.userId = n;
                    if (n == "NoUser") {
                        $scope.anonymousUser = true;
                        getRoom(false);
                    }
                    else if (n != undefined) {
                        $http.post(configs.restHostName + '/User/GetById', { id: n }).then(function (response) {
                            $scope.anonymousUser = false;
                            $scope.currentUser = response.data;
                            getRoom(true);
                        });
                    }
                });
        //watch the questionImage.filesize variable
        $scope.$watch(
                function () {
                    return $scope.questionImage;
                }, function (n, o) {
                    if (n != undefined) {
                        if (n.filesize > 1049000) {
                            $scope.ImageMessage = "File is too big";
                            $scope.questionImage.base64 = "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
                        } else {
                            $scope.ImageMessage = null;
                        }

                    }

                });
        //Image toggle functions
        $scope.toggleImageSize = function () {
            if ($scope.imageSize == undefined || $scope.imageSize == "100px") {
                $scope.imageSize = "500px";
            } else {
                $scope.imageSize = "100px";
                }

            $("#specificQuestionImage").css("width", $scope.imageSize);
            $("#specificQuestionImage").css("height", $scope.imageSize);
        };
        //Get all questions
        var getQuestions = function () {
            $http.get(configs.restHostName + '/Question/GetQuestionsForRoomWithoutImages?roomId='+MyRoomIdFromViewBag).then(function (response) {
                $scope.Questions = response.data;
                $scope.questionsLoaded = true;
            });
        };
        getQuestions();

        //Get information about this specific room
        //Get room info
        var getRoom = function (user) {
            $http.post(configs.restHostName + '/Room/GetById', { id: MyRoomIdFromViewBag }).then(function (response) {
                //Check for errors on request
                if (response.data.ErrorMessage != undefined) {
                    $("#RoomErrorDiv").html("<h3>" + response.data.ErrorMessage + "</h3>");
                    return;
                }

                $scope.CurrentRoom = response.data;
                if (user) {
                    if ($scope.currentUser.ConnectedRoomIds != undefined) {
                        if ($scope.CurrentRoom.HasPassword && $scope.currentUser.ConnectedRoomIds.indexOf(MyRoomIdFromViewBag) == -1) {
                            $('#myModalPassword').modal('show');
                        } else {
                            $scope.rightPassword = true;
                        }
                    } else {
                        $('#myModalPassword').modal('show');
                    }
                } else {
                    if ($scope.CurrentRoom.AllowAnonymous == false) {
                        var url = $("#RedirectToHome").val();
                        location.href = url;
                    }
                    else if ($scope.CurrentRoom.HasPassword) {
                        $('#myModalPassword').modal('show');
                    } else {
                        $scope.rightPassword = true;
                    }
                }

            });
        };


        //Function that checks if user has up/downvoted
        $scope.hasVoted = function (questionvotes, checkForUpvote) {

            //if we are anonymous user never look for votes
            if ($scope.currentUser == undefined || questionvotes == "" || questionvotes == undefined) {
                return false;
            }
            var testbool = false;
            jQuery.each(questionvotes, function (index, vote) {
                //check if vote is made by current user
                if (vote.CreatedById == $scope.currentUser._id) {
                    //Check if vote is upvote or downvote
                    if (checkForUpvote && vote.Value == 1 || !checkForUpvote && vote.Value == -1) {
                        testbool = true;
                        return testbool;
                    }
                    return testbool;
                }
            });
            return testbool;
        }

        $scope.validatePassword = function () {
            if ($scope.inputPassword == $scope.CurrentRoom.EncryptedPassword) {
                $('#myModalPassword').modal('hide');
                $scope.rightPassword = true;
                if ($scope.currentUser.ConnectedRoomIds != undefined) {
                    $scope.currentUser.ConnectedRoomIds.push(MyRoomIdFromViewBag);

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
                        //Use response to send to REST API
                        $http.post(configs.restHostName + '/User/UpdateUser', { User: JSON.stringify(response.data), Id: $scope.currentUser._id }).
                            then(function (response) {

                            });
                    });
                }
            } else {
                $scope.passwordMessage = "Incorrect password";
            }
        }

        var getChatMessages = function () {
            $http.post(configs.restHostName + '/Chat/GetAllByRoomId', { roomId: MyRoomIdFromViewBag }).then(function (response) {
                $scope.ChatMessages = response.data;
                $scope.chatLoaded = true;
            });
        };
        getChatMessages();
        $scope.userIsHost = false;
        $scope.SpecificQuestionShown = false;
        $scope.QuestionTypes = [{ name: 'Multiple Choice Question', val: 'MultipleChoiceQuestion' }, { name: 'Textual Question', val: 'TextualQuestion' }];
        $scope.ActiveUsers = [];

        $scope.AddResponseOption = function() {
            $scope.ResponseOptions.push({id: $scope.ResponseOptions.length, val: undefined});
        }
        $scope.RemoveResponseOption = function(item) {
            var temp = [];
            var counter = 0;
            for (var i = 0; i < $scope.ResponseOptions.length; i++) {
                if ($scope.ResponseOptions[i] != item) {
                    temp.push({ id: counter, val: $scope.ResponseOptions[i].val });
                    counter = counter + 1;
                }
            }
            $scope.ResponseOptions = temp;
        }
        $scope.ResponseOptions = [{ id: 0, val: undefined }, { id: 1, val: undefined }];
        //Function for retrieving userName by an id
        var getAllUsers = function () {
            $http.get(configs.restHostName + '/User/GetAll').then(function (result) {
                $scope.ActiveUsers = result.data;
            });
        }
        getAllUsers();

        //Function for creating result chart with d3js
        $scope.createPieChart = function () {
            var labels = [];
            var values = [];
            for (i = 0; i < $scope.SpecificQuestion.Result.length; i++) {
                var response = $scope.SpecificQuestion.Result[i];
                if (labels.indexOf(response.Value) != -1) {
                    values[labels.indexOf(response.Value)]++;
                } else {
                    labels.push(response.Value);
                    values.push(1);
                }
            }
            if (labels.length > 0) {
                $scope.showResults = true;
                $scope.labels = labels;
                $scope.options = {
                    animateRotate: false,
                    tooltipTemplate: "<%=label%>: <%= value %> (<%= Math.round(circumference / 6.283 * 100) %>%)"
                }
                $scope.data = values;
                //TODO: $scope.colors = ['#FD1F5E', '#1EF9A1'];
            } else {
                $scope.showResults = false;
            }

           
        }

        $scope.GetUsernameById = function (userId) {
            var result = $.grep($scope.ActiveUsers, function (e) { return e._id == userId; });
            if (userId == undefined || result.length == 0)
                return "Anonymous";
            return result[0].DisplayName;
        }


        //function for showing a specific question
        $scope.ShowSpecificQuestion = function (question) {
            $scope.ToggleShowQuestionTables();
            $scope.specificImageLoaded = false;
            $scope.SpecificQuestion = question;
            //Start getting the image for the specific question
            $http.get(configs.restHostName + '/Question/GetImageByQuestionId?questionId=' + question._id).then(function (response) {
                $scope.SpecificQuestion.Img = response.data;
                $scope.specificImageLoaded = true;
            });
            $scope.createPieChart();
        }
        $scope.ToggleShowQuestionTables = function () {
            $scope.SpecificQuestionShown = !$scope.SpecificQuestionShown;
        }

        $scope.Vote = function (direction) {
          
            if (direction == "Up") {
               
                    //Use response to send to REST API
                    var Obj = { Value: 1, CreatedById: $window.userId }
                    $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id });
                
               
            }
            if (direction == "Down") {
               
                    //Use response to send to REST API
                    var Obj = { Value: -1, CreatedById: $window.userId }
                    $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id });
                
               
                }


            }

        //Get percentage for loading bar
        $scope.getPercentage = function () {
            if ($scope.SpecificQuestion != undefined) {
                $scope.timerOverflow = false;
                var nominater = Date.now() - parseInt($scope.SpecificQuestion.CreationTimestamp);
                var denominater = parseInt($scope.SpecificQuestion.ExpireTimestamp) - parseInt($scope.SpecificQuestion.CreationTimestamp);
                $scope.percentage = (nominater / denominater) * 100;
                var timeLeftInmSec = parseInt($scope.SpecificQuestion.ExpireTimestamp) - Date.now();
                var hours = (parseInt(timeLeftInmSec / 3600000) + "").length == 1 ? "0" + parseInt(timeLeftInmSec / 3600000) : parseInt(timeLeftInmSec / 3600000);
                var min = (parseInt((timeLeftInmSec % 3600000) / 60000) + "").length == 1 ? "0" + parseInt((timeLeftInmSec % 3600000) / 60000) : parseInt((timeLeftInmSec % 3600000) / 60000);
                var sec = (parseInt(((timeLeftInmSec % 3600000) % 60000) / 1000) + "").length == 1 ? "0" + parseInt(((timeLeftInmSec % 3600000) % 60000) / 1000) : parseInt(((timeLeftInmSec % 3600000) % 60000) / 1000);
                $scope.timeLeft = (hours + ":" + min + ":" + sec).indexOf("-") > -1 ? "The time has run out!" : hours + ":" + min + ":" + sec;
                if ($scope.percentage > 100) {
                    $scope.timerOverflow = true;
                }
                //$scope.$apply();
            }
        }
        $interval($scope.getPercentage, 1000);
        //setInterval($scope.getPercentage, 1000);
        //adds answer to specificQuestion
        $scope.AddAnswer = function () {
                    //Use response to send to REST API string response
                    var Obj ={ Value: $scope.answerChoosen.Value,UserId:$window.userId}
                    $http.post(configs.restHostName + '/Question/AddQuestionResponse', { response: JSON.stringify(Obj), questionId: $scope.SpecificQuestion._id });
        }
        //Function for creating a question
        $scope.postQuestion = function () {
            $("#myModalCreate").modal("hide");
            var newResponses = "";
            for (var i = 0; i < $scope.ResponseOptions.length; i++) {
                if (i != $scope.ResponseOptions.length - 1) {
                    newResponses = newResponses + $scope.ResponseOptions[i].val + ',';
                } else {
                    newResponses = newResponses + $scope.ResponseOptions[i].val;
                }

            }
            //Make get request for json object conversion
            $http.post('/Room/toJsonQuestion', { CreatedBy: $window.userId, RoomId: MyRoomIdFromViewBag, Image: $scope.questionImage != undefined ? $scope.questionImage.base64 : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: $scope.QuestionText, ResponseOptions: newResponses, ExpireTimestamp: $scope.ExpirationTime, QuetionsType: $scope.QuestionType }).
                then(function (response) {
                    //Use response to send to REST API
                    $http.post(configs.restHostName + '/Question/CreateQuestion', { question: JSON.stringify(response.data), type: $scope.QuestionType.val });
                });
        }

        //Function for creating a chatMessage
        $scope.postChatMessage = function (message) {
            //Clear text area, so that it is ready for a new message
            $scope.textAreaModel = "";

            //Make get request for json object conversion
            $http.post('/Room/toJsonChatMessage', { userId: window.userId, roomId: MyRoomIdFromViewBag, text: message }).
                then(function (response) {
                    //Use response to send to REST API
                    $http.post(configs.restHostName + '/Chat/CreateChatMessage', { ChatMessage: JSON.stringify(response.data) });
                });
        }
    }
]);

