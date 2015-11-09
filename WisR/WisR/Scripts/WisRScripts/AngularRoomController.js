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
        /**
           * @ngdoc method
           * @name RoomController#broadcastChatMessage
           * @methodOf WisR.controller:RoomController
           * @description
           * SignalR function that is called when a new chat message is created
           * @param {String} chatMessageToAdd The chatmessage that is to be added to the chat
           */
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
        /**
           * @ngdoc method
           * @name RoomController#broadcastUpdateRoom
           * @methodOf WisR.controller:RoomController
           * @description
           * SignalR function that is called when the location of a room is changed
           * @param {Room} roomToUpdate The room where the updated location should happen
           */
        hub.client.broadcastUpdateRoom = function (roomToUpdate) {
            var jsonParsedRoom = JSON.parse(roomToUpdate);

            if (jsonParsedRoom._id === $scope.CurrentRoom._id) {
                $scope.CurrentRoom = jsonParsedRoom;

                ////trick to update the map
                $scope.toggleRoomLocation();
                $scope.toggleRoomLocation();
                $scope.$apply();
            }
        };

        /**
           * @ngdoc method
           * @name RoomController#broadcastDeleteRoom
           * @methodOf WisR.controller:RoomController
           * @description
           * Function that is called when a room should be deleted, if it is the current room inform the user that the room has been deleted and redirect him to the front page
           * @param {Room} roomToAdd The room to delete
           */

        hub.client.broadcastDeleteRoom = function (roomToDelete) {
            if (roomToDelete === $scope.CurrentRoom._id) {
                alert(Resources.RoomWasDeletedMsg);
                $window.location.href = "/";
            }
        };
        $.connection.hub.start();
    });

    ////Connect to SignalR hub and wait newly added questions
    $(function () {
        //// Declare a proxy to reference the hub. 
        var hub = $.connection.questionHub;
        /**
           * @ngdoc method
           * @name RoomController#broadcastQuestion
           * @methodOf WisR.controller:RoomController
           * @description
           * SignalR function that a question should be added to the array of questions($scope.Questions)
           * @param {Question} questionToAdd The question to add
           */
        hub.client.broadcastQuestion = function (questionToAdd) {
            $scope.Questions.push(JSON.parse(questionToAdd));
            $scope.$apply();
        };
        /**
          * @ngdoc method
          * @name RoomController#broadcastUpdateQuestion
          * @methodOf WisR.controller:RoomController
          * @description
          * SignalR function that a question should be updated with new information
          * @param {Question} questionToUpdate The question with the new information
          */
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
        /**
          * @ngdoc method
          * @name RoomController#broadcastDeleteQuestion
          * @methodOf WisR.controller:RoomController
          * @description
          * SignalR function call that the question should be deleted
          * @param {Question} questionToDelete The question to delete
          */
        hub.client.broadcastDeleteQuestion = function (questionToDelete) {
            var index = findWithAttr($scope.Questions, "_id", questionToDelete);
            if (index > -1) {
                $scope.Questions.splice(index, 1);
                $scope.$apply();
            }
            //if the user is currently working with this question
            if ($scope.SpecificQuestion != null) {
                if (questionToDelete === $scope.SpecificQuestion._id) {
                    if ($scope.SpecificQuestionShown) {
                        $scope.ToggleShowQuestionTables();
                    }
                    $scope.modalChanger("myModalCreate", "hide");
                    $scope.modalChanger("deleteQuestionModal", "hide");
                    alert(Resources.QuestionWasDeletedMessage);
                }
            }

        };
        /**
          * @ngdoc method
          * @name RoomController#broadcastUpdateResult
          * @methodOf WisR.controller:RoomController
          * @description
          * SignalR function call that the result of a question be updated with new responses
          * @param {Question} questionToUpdate The question with the new information
          */
        hub.client.broadcastUpdateResult = function (questionToUpdate) {
            var updateTemp = JSON.parse(questionToUpdate);
            var index = findWithAttr($scope.Questions, "_id", updateTemp._id);
            $scope.Questions[index].Result = updateTemp.Result;
            ////If this is the specific question that changed update it with new values
            if ($scope.SpecificQuestion != undefined) {
                var indexOfSpecificQuestion = findWithAttr($scope.Questions, "_id", $scope.SpecificQuestion._id);
                $scope.SpecificQuestion = $scope.Questions[indexOfSpecificQuestion];
                $scope.specificAnswer = $scope.getSpecificAnswer($scope.SpecificQuestion);

                ////Redraw the result chart
                $scope.createPieChart();
            }

            $scope.$apply();
        };
        /**
          * @ngdoc method
          * @name RoomController#broadcastUpdateVotes
          * @methodOf WisR.controller:RoomController
          * @description
          * SignalR function call that the question should be updated with new votes
          * @param {Question} questionToUpdate The question with the new information
          */
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
    /**
        * @ngdoc property
        * @name .#chartType
        * @returns {String} chartType
        * @propertyOf WisR.controller:RoomController 
        * @description Property that determines which kind of chart is created for the results of the question
        * Default is "Pie"
        */
    $scope.chartType = "Pie";
    /**
        * @ngdoc property
        * @name .#userIsHost
        * @returns {Boolean} userIsHost
        * @propertyOf WisR.controller:RoomController 
        * @description Boolean that determines whether the user is host of the room
        * Default is false
        */
    $scope.userIsHost = false;
    /**
       * @ngdoc property
       * @name .#SpecificQuestionShown
       * @returns {Boolean} SpecificQuestionShown
       * @propertyOf WisR.controller:RoomController 
       * @description Boolean that determines whether a specific question is shown or the two tables with all the questions are shown
       * Default is false
       */
    $scope.SpecificQuestionShown = false;
    /**
       * @ngdoc property
       * @name .#QuestionTypes
       * @returns {Array<QuestionType>} QuestionTypes
       * @propertyOf WisR.controller:RoomController 
       * @description Array with the different types of questions
       */
    $scope.QuestionTypes = [{ name: 'Multiple Choice Question', val: 'MultipleChoiceQuestion' }, { name: 'Textual Question', val: 'TextualQuestion' }];
    /**
     * @ngdoc property
     * @name .#ResponseOptions
     * @returns {Array<ResponseOption>} ResponseOptions
     * @propertyOf WisR.controller:RoomController 
     * @description Array that contains the response options for a specific question
     */
    $scope.ResponseOptions = [{ id: 0, val: undefined }, { id: 1, val: undefined }];
    /**
        * @ngdoc property
        * @name .#ResponseOptionTitle
        * @returns {String>} ResponseOptionTitle
        * @propertyOf WisR.controller:RoomController 
        * @description Title of remove ResponseOption button
        */
    $scope.ResponseOptionTitle = Resources.ResponseOptionTitle;
    /**
     * @ngdoc property
     * @name .#ActiveUsers
     * @returns {Array<ResponseOption>} ActiveUsers
     * @propertyOf WisR.controller:RoomController 
     * @description Array that contains all the active users, so that we can fetch their username
     */
    $scope.ActiveUsers = [];
    ///#endregion

    //#region Watches
    /**
          * @ngdoc method
          * @name RoomController#watchUserId
          * @methodOf WisR.controller:RoomController
          * @description
          * Function that watches the userId variable, this is done so we can determine whether or not the user is anonymous.
          * After retrieving the userId we fetch the userid from the database.
          * @param {String} userId The variable that we want to watch
          */
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
                if (response.data.ErrorType != 0) {
                    //TODO better error handling?
                    alert($scope.GetErrorOutput(response.data.Errors));
                } else {
                    $scope.anonymousUser = false;
                    $scope.currentUser = JSON.parse(response.data.Data);
                    $scope.getRoom(true);
                }


            }, $scope.onErrorAlert);
        }
    });
    /**
         * @ngdoc method
         * @name RoomController#watchResponseOptions.length
         * @methodOf WisR.controller:RoomController
         * @description
         * Function that watches the responseOptions.length. This is done to set the title correctly on the remove responseOption button.
         * @param {int} ResponseOptions.length The variable that we want to watch
         */
    ///watch the questionImage.filesize variable
    $scope.$watch(function () {
        return $scope.ResponseOptions.length;
    }, function (n, o) {
        if (n == 2 && ($scope.QuestionType == "MultipleChoiceQuestion" || $scope.QuestionType == undefined)) {
            $scope.ResponseOptionTitle = Resources.ResponseOptionTitle;
        } else {
            $scope.ResponseOptionTitle = null;
        }
    });
    /**
         * @ngdoc method
         * @name RoomController#watchQuestionImage
         * @methodOf WisR.controller:RoomController
         * @description
         * Function that watches the questionImage. This is done so that we can check whether the filesize exceeds our limits. If it does we resize the picture
         * After retrieving the userId we fetch the userid from the database.
         * @param {String} questionImage The variable that we want to watch
         */
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
                        img.onload = function () {
                            var resized = resizeImg(img, 800, 800, 0);
                            $scope.questionImage.base64 = resized.split('ata:image/png;base64,')[1];
                            $scope.ImageMessage = Resources.ImageResized;
                            $scope.imageTooBig = false;
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
    /**
        * @ngdoc method
        * @name RoomController#toggleImageSize
        * @methodOf WisR.controller:RoomController
        * @description
        * Function that toggles the image size between 500px and 100px
        */
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
    /**
        * @ngdoc method
        * @name RoomController#setImageMessage
        * @methodOf WisR.controller:RoomController
        * @description
        * Function that sets the image message to loading
        */
    //image message function that can be called from outside the controller
    $scope.setImageMessage = function () {
        //start by assuming the picture is too big
        $scope.imageTooBig = true;
        $scope.ImageMessage = window.Resources.LoadingImage + "...";
        $scope.$apply();
    }
    ///#endregion

    //#region QuestionFunctions
    /**
        * @ngdoc method
        * @name RoomController#getQuestions
        * @methodOf WisR.controller:RoomController
        * @description
        * Function that fetches all the questions from the database and sets questionsLoaded to true, so that we can change the view accordingly
        */
    $scope.getQuestions = function () {
        $http.get(configs.restHostName + '/Question/GetQuestionsForRoomWithoutImages?roomId=' + MyRoomIdFromViewBag).then(function (response) {
            if (response.data.ErrorType != 0) {
                //TODO better error handling?
                alert($scope.GetErrorOutput(response.data.Errors));
            } else {
                $scope.Questions = JSON.parse(response.data.Data);
                $scope.questionsLoaded = true;
            }
            
        }, $scope.onErrorAlert);
    };
    /**
       * @ngdoc method
       * @name RoomController#postQuestion
       * @methodOf WisR.controller:RoomController
       * @description
       * Function for creating a question, this is also used when updating already existing questions. This function takes parameters from scope variables to create the question and sends it all to the roomcontroller where it gets validated and turned into a json object.
       * That json object is then sent to the rest-api
       */
    $scope.postQuestion = function () {
        $scope.modalChanger("myModalCreate", "hide");

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
            if ($scope.questionImage == undefined || $scope.questionImage.base64 == undefined) {
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
        $http.post('/Room/toJsonQuestion', { CreatedBy: $window.userId, CreatedByUserName: $scope.anonymousUser ? null : $scope.currentUser.DisplayName, RoomId: MyRoomIdFromViewBag, Image: image, QuestionText: $scope.QuestionText, ResponseOptions: newResponses, ExpireTimestamp: $scope.ExpirationTime, QuetionsType: $scope.QuestionType }).
            then(function (response) {
                ///Use response to send to REST API
                $http.post(configs.restHostName + '/Question/CreateQuestion', { question: JSON.stringify(response.data), type: $scope.QuestionType }).then(null, $scope.onErrorAlert);
                //Check if this function call is an update or a create
                if ($scope.UpdateQuestionBool) {
                    //Delete the old question
                    $scope.deleteQuestion($scope.SpecificQuestion);
                }
            });
    }

    /**
       * @ngdoc method
       * @name RoomController#getSpecificAnswer
       * @methodOf WisR.controller:RoomController
       * @description
       * Function for figuring out what a specifc user answered on a specific question
       * @param {Question} question The question from which we find the given answer by the user.
       */
    ///Get answer that current user made.
    $scope.getSpecificAnswer = function (question) {
        if ($scope.currentUser == undefined)
            return null;
        for (i = 0; i < question.Result.length; i++) {
            if (question.Result[i].UserId == $scope.currentUser._id)
                return question.Result[i].Value;
        }
        return null;
    }
    /**
      * @ngdoc method
      * @name RoomController#AddAnswer
      * @methodOf WisR.controller:RoomController
      * @description
      * Function for answering a question. Takes the answerchosen and the userId and sends it to the rest-api for validation and persisting
      */
    $scope.AddAnswer = function () {
        if ($window.userId == "NoUser")
            return;
        ///Use response to send to REST API string response
        var Obj = { Value: $scope.answerChoosen.Value, UserId: $window.userId, UserDisplayName: $scope.anonymousUser ? null : $scope.currentUser.DisplayName }
        $http.post(configs.restHostName + '/Question/AddQuestionResponse', { response: JSON.stringify(Obj), questionId: $scope.SpecificQuestion._id }).then(function (succes) {

        }, $scope.onErrorAlert);
    }
    /**
     * @ngdoc method
     * @name RoomController#AddResponseOption
     * @methodOf WisR.controller:RoomController
     * @description
     * Function for adding a response option to a question that the user is creating
     */
    $scope.AddResponseOption = function () {
        $scope.ResponseOptions.push({ id: $scope.ResponseOptions.length, val: undefined });
    }
    /**
     * @ngdoc method
     * @name RoomController#RemoveResponseOption
     * @methodOf WisR.controller:RoomController
     * @description
     * Function for removing a response option to a question that the user is creating
     */
    $scope.RemoveResponseOption = function (item) {
        if ($scope.ResponseOptions.length > 2 || $scope.QuestionType !== "MultipleChoiceQuestion") {
            var temp = [];
            var counter = 0;
            for (var i = 0; i < $scope.ResponseOptions.length; i++) {
                if ($scope.ResponseOptions[i] !== item) {
                    temp.push({ id: counter, val: $scope.ResponseOptions[i].val });
                    counter = counter + 1;
                }
            }
            $scope.ResponseOptions = temp;

        }
    }
    /**
    * @ngdoc method
    * @name RoomController#ShowSpecificQuestion
    * @methodOf WisR.controller:RoomController
    * @description
    * Function for changing view to a specific question. This function loads the image for the question and starts a timer for the progress bar.
    * The function also creates the piechart
    * @param {Question} question The question to change view to.
    */
    ///function for showing a specific question
    $scope.ShowSpecificQuestion = function (question) {
        $scope.ToggleShowQuestionTables();
        $scope.specificImageLoaded = false;
        $scope.SpecificQuestion = question;
        $scope.specificAnswer = $scope.getSpecificAnswer(question);
        $("#answerTextarea").val($scope.specificAnswer);
        ///Get percentage once and start timer to fire once every second
        $scope.getPercentage();
        $scope.progressCancel = $interval($scope.getPercentage, 1000);
        ///Start getting the image for the specific question
        $http.get(configs.restHostName + '/Question/GetImageByQuestionId?questionId=' + question._id).then(function (response) {
            if (response.data.ErrorType != 0) {
                //TODO better error handling?
                alert($scope.GetErrorOutput(response.data.Errors));
            } else {
                if (response.data.Data === null) {
                    //set image to noImage
                    //$scope.questionImage = configs.noImgBase64;
                    $scope.SpecificQuestion.Img = configs.noImgBase64;
                    $("#specificQuestionImage").prop('title', Resources.NoPictureText);
                    $scope.NoPicture = true;
                } else {
                    $scope.SpecificQuestion.Img = response.data.Data;
                    $("#specificQuestionImage").prop('title', Resources.ClickToChangeImageSize);
                    $scope.NoPicture = false;
                }
                $scope.specificImageLoaded = true;
            }
            
        }, $scope.onErrorAlert);
        $scope.createPieChart();
    }
    /**
    * @ngdoc method
    * @name RoomController#getPercentage
    * @methodOf WisR.controller:RoomController
    * @description
    * Function that calculates the percentage time spent since the question was created and until it finishes.
    */
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
    /**
    * @ngdoc method
    * @name RoomController#ToggleShowQuestionTables
    * @methodOf WisR.controller:RoomController
    * @description
    * Function that toggles the view between two tables of questions and a specific question. If going from specific question it stops the progress timer
    */
    $scope.ToggleShowQuestionTables = function () {
        if ($scope.SpecificQuestionShown) {
            $scope.SpecificQuestion = null;
        }
        $scope.SpecificQuestionShown = !$scope.SpecificQuestionShown;
        ///Stop the timer for the progress bar if it is running
        if (angular.isDefined($scope.progressCancel)) {
            $interval.cancel($scope.progressCancel);
            $scope.progressCancel = undefined;
            $scope.showProgressBar = false;
        }
    }
    /**
    * @ngdoc method
    * @name RoomController#deleteQuestion
    * @methodOf WisR.controller:RoomController
    * @description
    * Function for deleting a specific question
    * @param {Question} questionToDelete The question that the user wishes to delete, this can only be done by the user who made the question
    */
    $scope.deleteQuestion = function (questionToDelete) {
        $scope.SpecificQuestion = null;
        $http.delete(configs.restHostName + '/Question/DeleteQuestion', { params: { id: questionToDelete._id } }).then(function (response) {
            ///Check for errors on request
            if (response.data.ErrorType != 0) {
                //TODO better error handling?
                $scope.questionDeleteMessage=$scope.GetErrorOutput(response.data.Errors);
                return;
            } else {
                $scope.modalChanger("deleteQuestionModal", "hide");
            }
        }, $scope.onErrorAlert);
    }
    ///#endregion

    //#region LocationFunction
    //this check is to make the tests excecuteable
    if (navigator.geolocation != undefined) {
        ///Calls and get the currentlocation
        navigator.geolocation.getCurrentPosition(function (position) {
            $scope.currentLocation = position;
        });
    }

    /**
   * @ngdoc method
   * @name RoomController#toggleRoomLocation
   * @methodOf WisR.controller:RoomController
   * @description
   * Function that toggles the view of the google map
   */
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
    /**
  * @ngdoc method
  * @name RoomController#toggleRoomLocation
  * @methodOf WisR.controller:RoomController
  * @description
  * Function for updating the location of the room this can only be done by the roomowner
  */
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

            $http.post(configs.restHostName + '/Room/UpdateLocation', { id: $scope.CurrentRoom._id, location: JSON.stringify(tempLocation) }).then(function (succes) {

            }, $scope.onErrorAlert);
        });
    }
    //#endregion

    //#region RoomFunctions
    /**
  * @ngdoc method
  * @name RoomController#getRoom
  * @methodOf WisR.controller:RoomController
  * @description
  * Function for fetching the room that the user has joined, after we get the response we start fetching the questions, chatmessages and all the users
  * @param {Boolean} userIsNotAnonymous Boolean value that states whether or not the user is anonymous
  */
    ///Get the specific room
    $scope.getRoom = function (userIsNotAnonymous) {
        $http.post(configs.restHostName + '/Room/GetById', { id: MyRoomIdFromViewBag }).then(function (response) {
            //Tried moving these since it makes better sense(also easiere to test)
            $scope.getQuestions();
            $scope.getChatMessages();
            $scope.getAllUsers();
            $scope.specificRoomLoaded = true;
            ///Check for errors on request
            if (response.data.ErrorType !=0) {
                $scope.RoomErrorDiv = $scope.GetErrorOutput(response.data.Errors);
                return;
            }

            $scope.CurrentRoom = JSON.parse(response.data.Data);
            if (userIsNotAnonymous) {
                if ($scope.currentUser.ConnectedRoomIds != undefined) {
                    if ($scope.CurrentRoom.HasPassword && $scope.currentUser.ConnectedRoomIds.indexOf(MyRoomIdFromViewBag) == -1) {
                        $scope.modalChanger("myModalPassword", "show");
                    } else {
                        $scope.rightPassword = true;
                    }
                } else if ($scope.CurrentRoom.HasPassword) {
                    $scope.modalChanger("myModalPassword", "show");
                } else {
                    $scope.rightPassword = true;
                }
            } else {
                if ($scope.CurrentRoom.AllowAnonymous == false) {
                    $window.location.href = "/";
                }
                else if ($scope.CurrentRoom.HasPassword) {
                    $scope.modalChanger("myModalPassword", "show");
                } else {
                    $scope.rightPassword = true;
                }
            }

        }, $scope.onErrorAlert);
    };
    //#endregion

    //#region VoteFunctions
    /**
  * @ngdoc method
  * @name RoomController#hasVotes
  * @methodOf WisR.controller:RoomController
  * @description
  * Function that checks if user has up/downvoted
  * @param {Array<Votes>} questionvotes Array with all the up and downvotes for the question
  * @param {Boolean} checkForUpvote Boolean value that states whether the function should check for up or downvotes
  */
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
    /**
  * @ngdoc method
  * @name RoomController#Vote
  * @methodOf WisR.controller:RoomController
  * @description
  * Function for up/downvoting
  * @param {String} direction Has two possible values "up" and "down", states whether it is an up- or downvote
  */
    $scope.Vote = function (direction) {
        if (direction == "Up") {
            ///Use response to send to REST API
            var Obj = { Value: 1, CreatedById: $window.userId }
            $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id }).then(function (success) {

            }, $scope.onErrorAlert);
        }
        if (direction == "Down") {
            ///Use response to send to REST API
            var Obj = { Value: -1, CreatedById: $window.userId }
            $http.post(configs.restHostName + '/Question/AddVote', { vote: JSON.stringify(Obj), type: $scope.SpecificQuestion._t, id: $scope.SpecificQuestion._id }).then(function (success) {

            }, $scope.onErrorAlert);
        }
    }
    //#endregion

    //#region ChartFunctions
    /**
 * @ngdoc method
 * @name RoomController#onChartCreate
 * @methodOf WisR.controller:RoomController
 * @description
 * Function that checks if we already have a chart, if we do, destroys it. This is done to get rid of overlapping charts
 */
    $scope.$on('create', function (event, chart) {
        if ($scope.chart != undefined) {
            $scope.chart.destroy();
        }
        $scope.chart = chart;
    });
    /**
 * @ngdoc method
 * @name RoomController#createPieChart
 * @methodOf WisR.controller:RoomController
 * @description
 * Function for creating result chart with chartjs and angularjs
 */
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
    /**
 * @ngdoc method
 * @name RoomController#validatePassword
 * @methodOf WisR.controller:RoomController
 * @description
 * Function for validating the password. Hashes the users input with SHA512 and checks if it collides with the saved password for the room
 */
    $scope.validatePassword = function () {
        //Check if the inputted password with hash is the same as the rooms password
        if (CryptoJS.SHA512($scope.inputPassword).toString() == $scope.CurrentRoom.EncryptedPassword) {
            $scope.modalChanger("myModalPassword", "hide");

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
                }, $scope.onErrorAlert);
            }
        } else {
            $scope.passwordMessage = window.Resources.IncorrectPassword;
        }
    }
    //#endregion

    //#region ChatFunctions
    /**
 * @ngdoc method
 * @name RoomController#getChatMessages
 * @methodOf WisR.controller:RoomController
 * @description
 * Function that fetches all the chatmessages for the room and sets chatLoaded to true so we can update the view accordingly
 */
    $scope.getChatMessages = function () {
        $http.post(configs.restHostName + '/Chat/GetAllByRoomId', { roomId: MyRoomIdFromViewBag }).then(function (response) {
            if (response.data.ErrorType != 0) {
                //TODO better error handling?
                alert($scope.GetErrorOutput(response.data.Errors));
                return;
            } else {
                $scope.ChatMessages = JSON.parse(response.data.Data);
                $scope.chatLoaded = true;
            }
            
        });
    };
    /**
 * @ngdoc method
 * @name RoomController#getAllUsers
 * @methodOf WisR.controller:RoomController
 * @description
 * Function that fetches all users
 */
    $scope.getAllUsers = function () {
        $http.get(configs.restHostName + '/User/GetAll').then(function (result) {
            $scope.ActiveUsers = result.data;
        });
    }

    /**
 * @ngdoc method
 * @name RoomController#GetChatMessageUserName
 * @methodOf WisR.controller:RoomController
 * @description
 * Function that gets the display name of the chatmessage
 * @param {ChatMessage} chatMessage The chatMessage to check for displayname
 */
    $scope.getChatMessageUserName = function (chatMessage) {
        if (chatMessage == null)
            return;
        return chatMessage.ByUserDisplayName == null ? Resources.Anonymous : chatMessage.ByUserDisplayName;
    }
    /**
* @ngdoc method
* @name RoomController#GetQuestionUserName
* @methodOf WisR.controller:RoomController
* @description
* Function that gets the display name of the question
* @param {Question} question The question to check for displayname
*/
    $scope.getQuestionUserName = function (question) {
        if (question == null)
            return null;
        return question.CreatedByUserDisplayName == null ? Resources.Anonymous : question.CreatedByUserDisplayName;
    }
    /**
* @ngdoc method
* @name RoomController#GetAnswerUserName
 * @methodOf WisR.controller:RoomController
 * @description
* Function that gets the display name of the answer
* @param {Answer} answer The answer to check for displayname
 */
    $scope.getAnswerUserName = function (answer) {
        if (answer == null)
            return null;
        return answer.UserDisplayName == null ? Resources.Anonymous : answer.UserDisplayName;
    }
    /**
 * @ngdoc method
 * @name RoomController#postChatMessage
 * @methodOf WisR.controller:RoomController
 * @description
 * Function for creating a chatMessage
 * @param {String} message The message to pos to the rest-api
 */
    $scope.postChatMessage = function (message) {
        ///Clear text area, so that it is ready for a new message
        $scope.textAreaModel = "";

        ///Make get request for json object conversion
        $http.post('/Room/toJsonChatMessage', { userId: window.userId, userDisplayName: $scope.anonymousUser ? null : $scope.currentUser.DisplayName, roomId: MyRoomIdFromViewBag, text: message }).
            then(function (response) {
                ///Use response to send to REST API
                $http.post(configs.restHostName + '/Chat/CreateChatMessage', { ChatMessage: JSON.stringify(response.data) });
            });
    }
    //#endregion

    //#region HelperFunction
    /**
 * @ngdoc method
 * @name RoomController#modalChanger
 * @methodOf WisR.controller:RoomController
 * @description
 * Helper function to change the state of a modal window
 * @param {String} id the id of the modal to change
 * @param {String} state the state we wish to change to
 */
    ///Modal state changer
    $scope.modalChanger = function (id, state) {
        $("#" + id).modal(state);
    }
    /**
           * @ngdoc method
           * @name RoomController#GetErrorOutput
           * @methodOf WisR.controller:RoomController
           * @description
           * Helper function toget the error outputs
           * @param {Array<ErrorCode>} errors array of errors
           */
    $scope.GetErrorOutput = function (errors) {
        var output = Resources.Error + ": ";
        for (var i = 0; i < errors.length; i++) {
            var error = "";
            switch (errors[i]) {
                case 0:
                    error = Resources.RoomSecretAlreadyInUse + " " + Resources.Error + ":" + errors[i];
                    break;
                case 1:
                    error = Resources.NoRoomWithThatSecret + " " + Resources.Error + ":" + errors[i];
                    break;
                case 2:
                    error = Resources.RabbitMqError + " " + Resources.Error + ":" + errors[i];
                    break;
                case 3:
                    error = Resources.StringIsNotJsonFormat + " " + Resources.Error + ":" + errors[i];
                    break;
                case 4:
                    error = Resources.CouldNotParseJsonToClass + " " + Resources.Error + ":" + errors[i];
                    break;
                case 5:
                    error = Resources.CouldNotAddRoomToDatabase + " " + Resources.Error + ":" + errors[i];
                    break;
                case 6:
                    error = Resources.CouldNotGetRoomsFromDatabase + " " + Resources.Error + ":" + errors[i];
                    break;
                case 7:
                    error = Resources.CouldNotDeleteAllChatMessages + " " + Resources.Error + ":" + errors[i];
                    break;
                case 8:
                    error = Resources.CouldNotDeleteAllQuestions + " " + Resources.Error + ":" + errors[i];
                    break;
                case 9:
                    error = Resources.CouldNotDeleteRoom + " " + Resources.Error + ":" + errors[i];
                    break;
                case 10:
                    error = Resources.CouldNotUpdateRoom + " " + Resources.Error + ":" + errors[i];
                    break;
                case 11:
                    error = Resources.CouldNotGetUsers + " " + Resources.Error + ":" + errors[i];
                    break;
                case 12:
                    error = Resources.CouldNotAddUser + " " + Resources.Error + ":" + errors[i];
                    break;
                case 13:
                    error = Resources.CouldNotUpdateUser + " " + Resources.Error + ":" + errors[i];
                    break;
                case 14:
                    error = Resources.UserNotFound + " " + Resources.Error + ":" + errors[i];
                    break;
                case 15:
                    error = Resources.CouldNotDeleteUser + " " + Resources.Error + ":" + errors[i];
                    break;
                case 16:
                    error = Resources.CouldNotGetQuestions + " " + Resources.Error + ":" + errors[i];
                    break;
                case 17:
                    error = Resources.CouldNotGetQuestionType + " " + Resources.Error + ":" + errors[i];
                    break;
                case 18:
                    error = Resources.NewQuestionIdShouldBeNull + " " + Resources.Error + ":" + errors[i];
                    break;
                case 19:
                    error = Resources.RoomDoesNotExist + " " + Resources.Error + ":" + errors[i];
                    break;
                case 20:
                    error = Resources.CouldNotAddQuestion + " " + Resources.Error + ":" + errors[i];
                    break;
                case 21:
                    error = Resources.CouldNotUpdateQuestion + " " + Resources.Error + ":" + errors[i];
                    break;
                case 22:
                    error = Resources.QuestionExpired + " " + Resources.Error + ":" + errors[i];
                    break;
                case 23:
                    error = Resources.ActiveDirctoryError + " " + Resources.Error + ":" + errors[i];
                    break;
                case 24:
                    error = Resources.CouldNotGetChatMessages + " " + Resources.Error + ":" + errors[i];
                    break;
                default:
                    error = "ERROR NOT HANDLED YET";
            }
            output = output + error;
        }
        return output;
    }
    /**
                    * @ngdoc method
                    * @name RoomController#monErrorAlert
                    * @methodOf WisR.controller:RoomController
                    * @description
                    * Helper function to alert that error has occured when communicating with restapi
                    * @param {Error} error the error that has occured
                    */
    $scope.onErrorAlert = function (error) {
        alert(Resources.NoConnectionToServer);
    }
    /**
 * @ngdoc method
 * @name RoomController#findWithAttr
 * @methodOf WisR.controller:RoomController
 * @description
 * Helper function to find index of object in array
 * @param {Array} array the array to traverse
 * @param {Attribute} attr the attribute to check for the value
 * @param {Value} value the value to check for in the array property
 * @returns {Integer} index The index of the value in the array
 */
    ///Helper function to find index of object in array
    function findWithAttr(array, attr, value) {
        for (var i = 0; i < array.length; i += 1) {
            if (array[i][attr] === value) {
                return i;
            }
        }
        return -1;
    }
    /**
* @ngdoc method
* @name RoomController#setQuestionInputs
* @methodOf WisR.controller:RoomController
* @description
* Function to fill information from a question into the update modal window field
* @param {Question} question the question to fill into the input fields
*/
    var setQuestionInputs = function (question) {
        $scope.QuestionText = question.QuestionText;
        $scope.QuestionType = question._t;
        $(function () {
            $("#questionTypeId option[value='" + question._t + "']").prop('selected', true);
            //$("#questionTypeId").val(question._t);
        });

        $scope.ResponseOptions = question.ResponseOptions;
        $scope.questionImage = question.Img;
        $scope.ExpirationTime = 0;
    }
    /**
* @ngdoc method
* @name RoomController#toggleModalWithQuestion
* @methodOf WisR.controller:RoomController
* @description
* Function to fill information from a question into the update modal window field
* @param {String} modal the jquery id string for the modal window to toggle
* @param {Question} question the question to put into a scope variable so that we can work with it
*/
    $scope.toggleModalWithQuestion = function (modal, question) {
        $(modal).modal('toggle');
        $scope.SpecificQuestion = question;
        if (modal === '#myModalCreate') {
            $scope.UpdateQuestionBool = true;// if called from here it is an update
            setQuestionInputs(question);
        }

    }
    /**
* @ngdoc method
* @name RoomController#toggleCreateModal
* @methodOf WisR.controller:RoomController
* @description
* Function to fill information from a question into the update modal window field. Also sets the UpdateQuestionBool to false since this is a create call
* @param {String} modal the jquery id string for the modal window to toggle
*/
    $scope.toggleCreateModal = function (modal) {
        $(modal).modal('toggle');
        $scope.UpdateQuestionBool = false; //if called from here, it is a create
    }
    /**
* @ngdoc method
* @name RoomController#toggleCreateModal
* @methodOf WisR.controller:RoomController
* @description
* Function to toggle dropdown
* @param {String} questionid id for the dropdown to toggle
*/
    $scope.toggleDropdown = function (questionId) {
        $("#dropdown" + questionId).dropdown("toggle");
    }
    /**
* @ngdoc method
* @name RoomController#resizeImg
* @methodOf WisR.controller:RoomController
* @description
* Function to resize image, found at:http://stackoverflow.com/questions/18922880/html5-canvas-resize-downscale-image-high-quality
* @param {Image} img the img that is to be resized
* @param {String} maxWidth the max width after resizing
* @param {String} maxHeight the max height after resizing
* @param {Integer} degress the degress to rotate the picture(not used at the moment)
*/
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

