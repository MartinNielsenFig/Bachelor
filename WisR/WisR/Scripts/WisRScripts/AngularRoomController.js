/**
 * @ngdoc controller
 * @name WisR.controller:RoomController
 * @description
 * Controller for the Room View of the application
 */
app.controller("RoomController", ['$scope', '$http', 'configs', '$window', '$interval', function ($scope, $http, configs, $window, $interval) {
    //#region SignalR 
    ///Connect to SignalR hub and wait for chat messages
    $(function () {
        /// Declare a proxy to reference the hub. 
        var hub = $.connection.chatHub;
        /// Create a function that the hub can call to broadcast messages.
        hub.client.broadcastChatMessage = function (chatMessageToAdd) {
            //Only add the chatmessage if it is for the currentRoom
            if (JSON.parse(chatMessageToAdd).RoomId === $scope.CurrentRoom._id) {
                $scope.ChatMessages.push(JSON.parse(chatMessageToAdd));
                $scope.$apply();
            }
            
        };
        $.connection.hub.start();
    });

    ///Connect to SignalR hub and wait for room update
    $(function () {
        /// Declare a proxy to reference the hub. 
        var hub = $.connection.roomHub;
        //// Create a function that the hub can call to broadcast messages.
        hub.client.broadcastUpdateRoom = function (roomToUpdate) {
            $scope.CurrentRoom = JSON.parse(roomToUpdate);

            ////trick to update the map
            $scope.toggleRoomLocation();
            $scope.toggleRoomLocation();
            $scope.$apply();
        };
        $.connection.hub.start();
    });

    ////Connect to SignalR hub and wait newly added questions
    $(function () {
        //// Declare a proxy to reference the hub. 
        var hub = $.connection.questionHub;
        //// Create a function that the hub can call to broadcast messages.
        hub.client.broadcastQuestion = function (questionToAdd) {
            $scope.Questions.push(JSON.parse(questionToAdd));
            $scope.$apply();
        };
        ////SignalR function call that the question should be updated
        hub.client.broadcastUpdateQuestion = function (questionToUpdate) {
            var updateTemp = JSON.parse(questionToUpdate);
            var index = findWithAttr($scope.Questions, "_id", updateTemp._id);
            $scope.Questions[index] = updateTemp;
            ////If this is the specific question that changed update it with new values
            if ($scope.SpecificQuestion != undefined) {
                var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                ////Redraw the result chart
                $scope.createPieChart();
            }

            $scope.$apply();
        };
        ////SignalR function call that the question should be deleted
        hub.client.broadcastDeleteQuestion = function (questionToDelete) {
            var index = findWithAttr($scope.Questions, "_id", questionToDelete);
            if (index > -1) {
                $scope.Questions.splice(index, 1);
                $scope.$apply();
            }
        };
        ////SignalR function call that the question should be updated with new responses
        hub.client.broadcastUpdateResult = function (questionToUpdate) {
            var updateTemp = JSON.parse(questionToUpdate);
            var index = findWithAttr($scope.Questions, "_id", updateTemp._id);
            $scope.Questions[index].Result = updateTemp.Result;
            ////If this is the specific question that changed update it with new values
            if ($scope.SpecificQuestion != undefined) {
                var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                $scope.specificAnswer = getSpecificAnswer($scope.SpecificQuestion);

                ////Redraw the result chart
                $scope.createPieChart();
            }

            $scope.$apply();
        };
        ////SignalR function call that the question should be updated with new votes
        hub.client.broadcastUpdateVotes = function (questionToUpdate) {
            var updateTemp = JSON.parse(questionToUpdate);
            var index = findWithAttr($scope.Questions, "_id", updateTemp._id);

            ///AngularJS hack to retrigger filter(it doesn't recognize updated values)
            var temperino = $scope.Questions[index];
            temperino.Votes = updateTemp.Votes;
            $scope.Questions[index] = "";
            $scope.$apply();
            $scope.Questions[index] = temperino;


            ///$scope.Questions[index].Votes = updateTemp.Votes;
            ///If this is the specific question that changed update it with new values
            if ($scope.SpecificQuestion != undefined) {
                var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
            }

            $scope.$apply();
        };
        $.connection.hub.start();
    });
    ///#endregion

    //#region Defaultvalues
    ///default charttype as pie
    $scope.chartType = "Pie";
    $scope.userIsHost = false;
    $scope.SpecificQuestionShown = false;
    $scope.QuestionTypes = [{ name: 'Multiple Choice Question', val: 'MultipleChoiceQuestion' }, { name: 'Textual Question', val: 'TextualQuestion' }];
    $scope.ResponseOptions = [{ id: 0, val: undefined }, { id: 1, val: undefined }];
    $scope.ActiveUsers = [];
    ///#endregion

    //#region Watches
    ///watch the window.userId variable
    $scope.$watch(function () {
        return $window.userId;
    }, function (n, o) {
        $scope.userId = n;
        if (n == "NoUser") {
            $scope.anonymousUser = true;
            $scope.getRoom(false);
        }
        else if (n != undefined) {
            $http.post(configs.restHostName + '/User/GetById', { id: n }).then(function (response) {
                $scope.anonymousUser = false;
                $scope.currentUser = response.data;
                $scope.getRoom(true);
            });
        }
    });
    ///watch the questionImage.filesize variable
    $scope.$watch(
            function () {
                return $scope.questionImage;
            }, function (n, o) {
                if (n != undefined) {
                    if (n.filesize > 1049000) {
                        $scope.imageTooBig = true;
                        $scope.ImageMessage = Resources.FileTooBigResizing;
                        var img = new Image();
                        img.src = 'data:image/png;base64,' + n.base64;
                        img.onload=function ()
                        {
                            var resized = resizeImg(img, 800, 800, 0);
                            $scope.questionImage.base64 = resized.split('ata:image/png;base64,')[1];
                            $scope.ImageMessage = Resources.ImageResized;
                            $scope.imageTooBig =false;
                            $scope.$apply();                            
                            //$scope.questionImage.base64 = "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";
                        }           
                    } else {                   
                        $scope.imageTooBig = false;
                        $scope.ImageMessage = null;
                    }
                }
            });
    ///#endregion

    //#region ImageFunctions
    ///Image toggle functions
    $scope.toggleImageSize = function () {
        if ($scope.NoPicture) {
            return;
        }
        if ($scope.imageSize == undefined || $scope.imageSize == "100px") {
            $scope.imageSize = "500px";
        } else {
            $scope.imageSize = "100px";
        }

        $("#specificQuestionImage").css("width", $scope.imageSize);
        $("#specificQuestionImage").css("height", $scope.imageSize);
    };
    //image message function that can be called from outside the controller
    $scope.setImageMessage = function () {
        //start by assuming the picture is too big
        $scope.imageTooBig = true;
        $scope.ImageMessage = Resources.LoadingImage+"...";
        $scope.$apply();
    }
    ///#endregion

    //#region QuestionFunctions
    ///Get all questions
    var getQuestions = function () {
        $http.get(configs.restHostName + '/Question/GetQuestionsForRoomWithoutImages?roomId=' + MyRoomIdFromViewBag).then(function (response) {
            $scope.Questions = response.data;
            $scope.questionsLoaded = true;
        });
    };
    
    ///Function for creating a question
    $scope.postQuestion = function () {
        $("#myModalCreate").modal("hide");

        var newResponses = "";
        for (var i = 0; i < $scope.ResponseOptions.length; i++) {
            if (i != $scope.ResponseOptions.length - 1) {
                newResponses = newResponses + $scope.ResponseOptions[i].Value + ',';
            } else {
                newResponses = newResponses + $scope.ResponseOptions[i].Value;
            }

        }
        var image;

        if ($scope.UpdateQuestionBool) {
            //if this is an update question, the image will be in $scope.questionImage instead of $scope.questionImage.base64, but only if the picture hasn't changed
            if ($scope.questionImage.base64 == undefined) {
                image = $scope.questionImage;
            } else {
                image = $scope.questionImage.base64;
            }

        } else {
            if ($scope.questionImage == undefined) {
                image = null;
            } else {
                image = $scope.questionImage.base64;
            }
        }
        ///Make get request for json object conversion
        $http.post('/Room/toJsonQuestion', { CreatedBy: $window.userId, RoomId: MyRoomIdFromViewBag, Image: image, QuestionText: $scope.QuestionText, ResponseOptions: newResponses, ExpireTimestamp: $scope.ExpirationTime, QuetionsType: $scope.QuestionType }).
            then(function (response) {
                ///Use response to send to REST API
                $http.post(configs.restHostName + '/Question/CreateQuestion', { question: JSON.stringify(response.data), type: $scope.QuestionType });
                //Check if this function call is an update or a create
                if ($scope.UpdateQuestionBool) {
                    //Delete the old question
                    $scope.deleteQuestion($scope.SpecificQuestion);
                }
            });
    }

    ///Get answer that current user made.
    var getSpecificAnswer = function (question) {
        if ($scope.currentUser == undefined)
            return null;
        for (i = 0; i < question.Result.length; i++) {
            if (question.Result[i].UserId == $scope.currentUser._id)
                return question.Result[i].Value;
        }
        return null;
    }

    ///adds answer to specificQuestion
    $scope.AddAnswer = function () {
        ///Use response to send to REST API string response
        var Obj = { Value: $scope.answerChoosen.Value, UserId: $window.userId }
        $http.post(configs.restHostName + '/Question/AddQuestionResponse', { response: JSON.stringify(Obj), questionId: $scope.SpecificQuestion._id });
    }

    $scope.AddResponseOption = function () {
        $scope.ResponseOptions.push({ id: $scope.ResponseOptions.length, val: undefined });
    }

    $scope.RemoveResponseOption = function (item) {
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

    ///function for showing a specific question
    $scope.ShowSpecificQuestion = function (question) {
        $scope.ToggleShowQuestionTables();
        $scope.specificImageLoaded = false;
        $scope.SpecificQuestion = question;
        $scope.specificAnswer = getSpecificAnswer(question);
        ///Get percentage once and start timer to fire once every second
        $scope.getPercentage();
        $scope.progressCancel = $interval($scope.getPercentage, 1000);
        ///Start getting the image for the specific question
        $http.get(configs.restHostName + '/Question/GetImageByQuestionId?questionId=' + question._id).then(function (response) {
            if (response.data === "") {
                $scope.SpecificQuestion.Img = configs.noImgBase64;
                $("#specificQuestionImage").prop('title', Resources.NoPictureText);
                $scope.NoPicture = true;
            } else {
                $scope.SpecificQuestion.Img = response.data;
                $("#specificQuestionImage").prop('title', Resources.ClickToChangeImageSize);
                $scope.NoPicture = false;
            }
            $scope.specificImageLoaded = true;
        });
        $scope.createPieChart();
    }

    ///Get percentage for loading bar
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
            if ((hours + ":" + min + ":" + sec).indexOf("-") > -1) {
                $scope.timeLeft = Resources.TimeHasRunOut;
                $("#progressDiv").removeClass("active progress-striped").children().addClass("progress-bar-danger");
                ///Stop timer
                if (angular.isDefined($scope.progressCancel)) {
                    $interval.cancel($scope.progressCancel);
                    $scope.progressCancel = undefined;
                    $scope.showProgressBar = false;
                }
            } else {
                $scope.timeLeft = hours + ":" + min + ":" + sec;
                $("#progressDiv").addClass("active progress-striped").children().removeClass("progress-bar-danger");
            }
            if ($scope.percentage > 100) {
                $scope.timerOverflow = true;
            }
            $scope.showProgressBar = true;
        }
    }

    $scope.ToggleShowQuestionTables = function () {
        $scope.SpecificQuestionShown = !$scope.SpecificQuestionShown;
        ///Stop the timer for the progress bar if it is running
        if (angular.isDefined($scope.progressCancel)) {
            $interval.cancel($scope.progressCancel);
            $scope.progressCancel = undefined;
            $scope.showProgressBar = false;
        }
    }
    $scope.deleteQuestion=function(questionToDelete) {
        $http.delete(configs.restHostName + '/Question/DeleteQuestion', { params: {id: questionToDelete._id} }).then(function (response) {
            ///Check for errors on request
            if (response.data.ErrorMessage != undefined) {
                $scope.questionDeleteMessage = response.data.ErrorMessage;
                return;
            } else {
                $("#deleteQuestionModal").modal("hide");
            }
        });
    }
    ///#endregion

    //#region LocationFunction
    //this check is to make the tests excecuteable
        if (navigator.geolocation != undefined) {
            ///Calls and get the currentlocation
            navigator.geolocation.getCurrentPosition(function(position) {
                $scope.currentLocation = position;
            });
        }

        //Code for rooms maps
    $scope.toggleRoomLocation = function () {
        $("#googlemapsRoom").toggle();
        $("#updateBtn").toggle();
        var bounds = new google.maps.LatLngBounds();
        var mapOptions = {
            disableDefaultUI: true,
            center: {
                lat: $scope.CurrentRoom.Location.Latitude,
                lng: $scope.CurrentRoom.Location.Longitude
            },
            zoom: 22
        }
        map = new google.maps.Map(document.getElementById("mapRoom"), mapOptions);
        $scope.map = map;
        $scope.markers = [];
        var marker = new google.maps.Marker({
            map: map,
            position: {
                lat: $scope.CurrentRoom.Location.Latitude,
                lng: $scope.CurrentRoom.Location.Longitude
            },
            title: 'Rooms position',
            icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|7569fe'
        });
        $scope.markers.push(marker);
        bounds.extend(marker.getPosition());
        var pos;
        navigator.geolocation.getCurrentPosition(function (position) {
            pos = {
                lat: position.coords.latitude,
                lng: position.coords.longitude
            }
            var marker2 = new google.maps.Marker({
                map: map,
                position: pos,
                title: Resources.PositionOfTheRoom,
                icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|fe7569',
                animation: google.maps.Animation.BOUNCE
            });

            $scope.markers.push(marker2);
            bounds.extend(marker2.getPosition());
            map.fitBounds(bounds);
        });
    }

    ///Updates the room's current location
    $scope.updateLocation = function () {
        var pos;
        var tempLocation = $scope.CurrentRoom.Location;
        navigator.geolocation.getCurrentPosition(function (position) {
            pos = {
                lat: position.coords.latitude,
                lng: position.coords.longitude
            }
            tempLocation.Latitude = position.coords.latitude;
            tempLocation.Longitude = position.coords.longitude;

            $http.post(configs.restHostName + '/Room/UpdateLocation', { id: $scope.CurrentRoom._id, location: JSON.stringify(tempLocation) });
        });
    }
    //#endregion

    //#region RoomFunctions
    ///Get the specific room
    $scope.getRoom = function (user) {
        $http.post(configs.restHostName + '/Room/GetById', { id: MyRoomIdFromViewBag }).then(function (response) {
            //Tried moving these since it makes better sense(also easiere to test)
            getQuestions();
            getChatMessages();
            getAllUsers();
            $scope.specificRoomLoaded = true;
            ///Check for errors on request
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
                    $window.location.href = url;
                }
                else if ($scope.CurrentRoom.HasPassword) {
                    $('#myModalPassword').modal('show');
                } else {
                    $scope.rightPassword = true;
                }
            }

        });
    };
    //#endregion

    //#region VoteFunctions
    ///Function that checks if user has up/downvoted
    $scope.hasVoted = function (questionvotes, checkForUpvote) {
        ///if we are anonymous user never look for votes
        if ($scope.currentUser == undefined || questionvotes == "" || questionvotes == undefined) {
            return false;
        }
        var testbool = false;
        jQuery.each(questionvotes, function (index, vote) {
            ///check if vote is made by current user
            if (vote.CreatedById == $scope.currentUser._id) {
                ///Check if vote is upvote or downvote
                if (checkForUpvote && vote.Value == 1 || !checkForUpvote && vote.Value == -1) {
                    testbool = true;
                    return testbool;
                }
                return testbool;
            }
        });
        return testbool;
    }
    ///Used to vote, parameter, is direction
    $scope.Vote = function (direction) {
        if (direction == "Up") {
            ///Use response to send to REST API
            var Obj = { Value: 1, CreatedById: $window.userId }
            $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id });
        }
        if (direction == "Down") {
            ///Use response to send to REST API
            var Obj = { Value: -1, CreatedById: $window.userId }
            $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id });
        }
    }
    //#endregion

    //#region ChartFunctions
    ///If there is allready a chart, destroy it
    $scope.$on('create', function (event, chart) {
        if ($scope.chart != undefined) {
            $scope.chart.destroy();
        }
        $scope.chart = chart;
    });

    ///Function for creating result chart with d3js
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
            ///TODO: $scope.colors = ['#FD1F5E', '#1EF9A1'];
        } else {
            $scope.showResults = false;
        }
    }
    //#endregion

    //#region Password
    $scope.validatePassword = function () {
        //Check if the inputted password with hash is the same as the rooms password
        if (CryptoJS.SHA512($scope.inputPassword).toString() == $scope.CurrentRoom.EncryptedPassword) {
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
                    ///Use response to send to REST API
                    $http.post(configs.restHostName + '/User/UpdateUser', { User: JSON.stringify(response.data), Id: $scope.currentUser._id }).
                        then(function (response) {

                        });
                });
            }
        } else {
            $scope.passwordMessage = Resources.IncorrectPassword;
        }
    }
    //#endregion

    //#region ChatFunctions
    var getChatMessages = function () {
        $http.post(configs.restHostName + '/Chat/GetAllByRoomId', { roomId: MyRoomIdFromViewBag }).then(function (response) {
            $scope.ChatMessages = response.data;
            $scope.chatLoaded = true;
        });
    };
    
    ///Function for retrieving userName by an id, used by the chat
    var getAllUsers = function () {
        $http.get(configs.restHostName + '/User/GetAll').then(function (result) {
            $scope.ActiveUsers = result.data;
        });
    }
    

    //Get username, for the chat
    $scope.GetUsernameById = function (userId) {
        var result = $.grep($scope.ActiveUsers, function (e) { return e._id == userId; });
        if (userId == undefined || result.length == 0)
            return "Anonymous";
        return result[0].DisplayName;
    }

    ///Function for creating a chatMessage
    $scope.postChatMessage = function (message) {
        ///Clear text area, so that it is ready for a new message
        $scope.textAreaModel = "";

        ///Make get request for json object conversion
        $http.post('/Room/toJsonChatMessage', { userId: window.userId, roomId: MyRoomIdFromViewBag, text: message }).
            then(function (response) {
                ///Use response to send to REST API
                $http.post(configs.restHostName + '/Chat/CreateChatMessage', { ChatMessage: JSON.stringify(response.data) });
            });
    }
    //#endregion

    //#region HelperFunction
    ///Helper function to find index of object in array
    function findWithAttr(array, attr, value) {
        for (var i = 0; i < array.length; i += 1) {
            if (array[i][attr] === value) {
                return i;
            }
        }
        return -1;
    }
    var setQuestionInputs = function (question) {
        $scope.QuestionText = question.QuestionText;
        $scope.QuestionType = question._t;
        $(function () {
            $("#questionTypeId option[value='"+question._t+"']").prop('selected', true);
            //$("#questionTypeId").val(question._t);
        });
        
        $scope.ResponseOptions = question.ResponseOptions;
        $scope.questionImage = question.Img;
        $scope.ExpirationTime = 0;
    }
    $scope.toggleModalWithQuestion=function(modal, question) {
        $(modal).modal('toggle');
        $scope.SpecificQuestion = question;
        if (modal === '#myModalCreate') {
            $scope.UpdateQuestionBool = true;// if called from here it is an update
            setQuestionInputs(question);
        }
        
    }
    
    $scope.toggleCreateModal = function (modal, question) {
        $(modal).modal('toggle');
        $scope.UpdateQuestionBool = false; //if called from here, it is a create
    }
    $scope.toggleDropdown=function(questionId) {
        $("#dropdown" + questionId).dropdown("toggle");
    }

    function resizeImg(img, maxWidth, maxHeight, degrees) {
        
        var imgWidth = img.width,
          imgHeight = img.height;

        var ratio = 1,
          ratio1 = 1,
          ratio2 = 1;
        ratio1 = maxWidth / imgWidth;
        ratio2 = maxHeight / imgHeight;

        // Use the smallest ratio that the image best fit into the maxWidth x maxHeight box.
        if (ratio1 < ratio2) {
            ratio = ratio1;
        } else {
            ratio = ratio2;
        }
        var canvas = document.createElement("canvas");
        var canvasContext = canvas.getContext("2d");
        var canvasCopy = document.createElement("canvas");
        var copyContext = canvasCopy.getContext("2d");
        var canvasCopy2 = document.createElement("canvas");
        var copyContext2 = canvasCopy2.getContext("2d");
        canvasCopy.width = imgWidth;
        canvasCopy.height = imgHeight;
        copyContext.drawImage(img, 0, 0);

        // init
        canvasCopy2.width = imgWidth;
        canvasCopy2.height = imgHeight;
        copyContext2.drawImage(canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvasCopy2.width, canvasCopy2.height);


        var rounds = 1;
        var roundRatio = ratio * rounds;
        for (var i = 1; i <= rounds; i++) {


            // tmp
            canvasCopy.width = imgWidth * roundRatio / i;
            canvasCopy.height = imgHeight * roundRatio / i;

            copyContext.drawImage(canvasCopy2, 0, 0, canvasCopy2.width, canvasCopy2.height, 0, 0, canvasCopy.width, canvasCopy.height);

            // copy back
            canvasCopy2.width = imgWidth * roundRatio / i;
            canvasCopy2.height = imgHeight * roundRatio / i;
            copyContext2.drawImage(canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvasCopy2.width, canvasCopy2.height);

        } // end for

        canvas.width = imgWidth * roundRatio / rounds;
        canvas.height = imgHeight * roundRatio / rounds;
        canvasContext.drawImage(canvasCopy2, 0, 0, canvasCopy2.width, canvasCopy2.height, 0, 0, canvas.width, canvas.height);


        if (degrees == 90 || degrees == 270) {
            canvas.width = canvasCopy2.height;
            canvas.height = canvasCopy2.width;
        } else {
            canvas.width = canvasCopy2.width;
            canvas.height = canvasCopy2.height;
        }

        canvasContext.clearRect(0, 0, canvas.width, canvas.height);
        if (degrees == 90 || degrees == 270) {
            canvasContext.translate(canvasCopy2.height / 2, canvasCopy2.width / 2);
        } else {
            canvasContext.translate(canvasCopy2.width / 2, canvasCopy2.height / 2);
        }
        canvasContext.rotate(degrees * Math.PI / 180);
        canvasContext.drawImage(canvasCopy2, -canvasCopy2.width / 2, -canvasCopy2.height / 2);


        var dataURL = canvas.toDataURL();
        return dataURL;
    }
    //#endregion
}
]);

