///<reference path="~/Scripts/jasmine/jasmine.js"/>
///<reference path="~/Scripts/ResoursesForTest/en-GB.js"/>
///<reference path="~/../WisR/Scripts/CryptoJS/rollups/sha512.js"/>
///<reference path="~/../WisR/Scripts/jquery-1.11.3.js"/>
///<reference path="~/../WisR/Scripts/jquery.signalR-2.2.0.js"/>
///<reference path="~/../WisR/Scripts/angular.js"/>
///<reference path="~/../WisR/Scripts/angular-animate.js"/>
///<reference path="~/../WisR/Scripts/angular-mocks.js"/>
///<reference path="~/../WisR/Scripts/angular-base64-upload.js"/>
///<reference path="~/../WisR/Scripts/scrollglue.js"/>
///<reference path="~/../WisR/Scripts/Chart.js"/>
///<reference path="~/../WisR/Scripts/angular-chart.js"/>

///<reference path="~/Scripts/GoogleForTest/googleForTest.js"/>
///<reference path="~/Scripts/SignalRForTest/server.js"/>
///<reference path="~/Scripts/GlobalVarriablesForTest/GlobalVarriables.js"/>

///<reference path="~/../WisR/Scripts/WisRScripts/geolocationScripts.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/AngularModule.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/Config.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/AngularHomeController.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/AngularRoomController.js"/>

describe("English Test", function () {

    beforeEach(angular.mock.module('wisrApp'));

    describe("Home controller", function () {

        var scope, controller, httpBackend, config, window;

        beforeEach(inject(function ($rootScope, $controller, $httpBackend, $window, configs) {
            scope = $rootScope.$new();
            config = configs;
            httpBackend = $httpBackend;
            $window = { location: { replace: jasmine.createSpy() } };
            window = $window;

            //Setup for http request
            httpBackend.when('GET', 'http://localhost:1337/Room/GetAll').respond({});
            httpBackend.when('POST', 'http://localhost:7331/Home/toJsonRoom').respond({});
            httpBackend.when('POST', 'http://localhost:7331/Home/toJsonUser').respond({});
            httpBackend.when('POST', 'http://localhost:1337/User/UpdateUser').respond({});
            httpBackend.when('POST', 'http://localhost:1337/User/GetById').respond({});

            //Setup for currentUser
            scope.currentUser = {ConnectedRoomIds: ["12312312"] }

            //Setup for location
            scope.currentLocation = { coords: { latitude: 1 } };
            scope.currentLocation = { coords: { longitude: 1 } };
            
            controller = $controller('HomeController', { $scope: scope, $window: window});
        }));


        it('should set the room name to ""', function () {
            expect(scope.RoomName).toBe('');
        });

        it('should set the room radius to 50', function () {
            expect(scope.Radius).toBe(50);
        });

        it('should change $scope.message to "The room-tag you have entered requires you to be logged in"', function() {
            var room = { AllowAnonymous: false }
            scope.userId = 'NoUser';
            scope.changeViewToRoom(room);
            expect(scope.Message).toBe('The room-secret you have entered requires you to login');
        });
    
        it('should change location to ?RoomId=1', function () {
            var room = { _id: 1, AllowAnonymous: true }
            scope.userId = 'Martin';
            scope.changeViewToRoom(room);
            expect(scope.RoomId).toBe(1);
        });

        it('should give call GetAll', function() {
            httpBackend.expectGET('http://localhost:1337/Room/GetAll');
            scope.getRooms();
            httpBackend.flush();
        });

        it('should call toJsonRoom, CreateRoom, toJsonUser and UpdateUser', function () {
            httpBackend.when('POST', 'http://localhost:1337/Room/CreateRoom').respond("562a1ae9c7f562790c95a505;");
            httpBackend.expectPOST('http://localhost:7331/Home/toJsonRoom');
            httpBackend.expectPOST('http://localhost:1337/Room/CreateRoom');
            httpBackend.expectPOST('http://localhost:7331/Home/toJsonUser');

            httpBackend.expectPOST('http://localhost:1337/User/UpdateUser');
            scope.postRoom();
            httpBackend.flush();
        });

        it('should call toJsonRoom, CreateRoom and then the an error message is promt', function () {
            httpBackend.when('POST', 'http://localhost:1337/Room/CreateRoom').respond({ErrorMessage: "Error" });
            httpBackend.expectPOST('http://localhost:7331/Home/toJsonRoom');
            httpBackend.expectPOST('http://localhost:1337/Room/CreateRoom');
            
            scope.postRoom();
            httpBackend.flush();
            expect(scope.RoomCreationError).toBe("Error: Error");
        });

        it('password should have been encrypted', function() {
            scope.Password = "Martin";
            scope.postRoom();
            expect(scope.HashedPassword.length === 128);
        });

        it('password shouldn\'t have been encrypted', function () {
            scope.postRoom();
            expect(scope.HashedPassword === undefined);
        });

        it('changeViewToRoom should have been called', function () {
            httpBackend.when('POST', 'http://localhost:1337/Room/GetByUniqueSecret').respond({ _id: 1 });
            httpBackend.expectPOST('http://localhost:1337/Room/GetByUniqueSecret');
            spyOn(scope, 'changeViewToRoom');
            scope.connectWithUniqueSecret();
           
            httpBackend.flush();
            expect(scope.changeViewToRoom).toHaveBeenCalled();
        });

        it('message should be "No room with the Secret: 20"', function () {
            httpBackend.when('POST', 'http://localhost:1337/Room/GetByUniqueSecret').respond({});
            httpBackend.expectPOST('http://localhost:1337/Room/GetByUniqueSecret');
            
            scope.uniqueRoomSecret = 20;
            scope.connectWithUniqueSecret();
          
            httpBackend.flush();
            expect(scope.Message).toBe("No room with the secret: 20");
        });

        it('should call GetByUniqueSecret', function () {
            httpBackend.when('POST', 'http://localhost:1337/Room/GetByUniqueSecret').respond({ _id: 1 });
            httpBackend.expectPOST('http://localhost:1337/Room/GetByUniqueSecret');
            scope.connectWithUniqueSecret();
            httpBackend.flush();
        });

        it('anonymousUser should be true', function () {
            window.userId = "NoUser";
            scope.$apply();
            expect(scope.anonymousUser).toBe(true);
        });

        it('should call User/GetById', function () {
            httpBackend.expectPOST('http://localhost:1337/User/GetById');

            window.userId = "Martin";
            scope.$apply();

            httpBackend.flush();
        });
    });

    describe("Room controller", function() {
        var scope, controller, httpBackend, config, window;

        beforeEach(inject(function ($rootScope, $controller, $httpBackend, $window, configs) {
            scope = $rootScope.$new();
            config = configs;
            httpBackend = $httpBackend;
            $window = { location: { replace: jasmine.createSpy() } };
            window = $window;

            //Setup for http request
            httpBackend.when('POST', 'http://localhost:1337/User/GetById').respond({});
            httpBackend.when('GET', 'http://localhost:1337/Question/GetQuestionsForRoomWithoutImages?roomId=1').respond({});
            httpBackend.when('POST','/Room/toJsonQuestion').respond({});
            httpBackend.when('POST', 'http://localhost:1337/Question/CreateQuestion').respond({});
            httpBackend.when('POST', "http://localhost:1337/Question/AddQuestionResponse").respond({});

            //Setup for currentUser
            scope.currentUser = { ConnectedRoomIds: ["12312312"] }

            //Setup for location
            scope.currentLocation = { coords: { latitude: 1 } };
            scope.currentLocation = { coords: { longitude: 1 } };

            controller = $controller('RoomController', { $scope: scope, $window: window});
        }));

        it('should set chartType to "Pie";', function () {
            expect(scope.chartType).toBe("Pie");
        });

        it('should have called getRoom with false', function() {
            spyOn(scope, 'getRoom');
            window.userId = "NoUser";
            scope.$apply();
            expect(scope.getRoom).toHaveBeenCalledWith(false);
        });

        it('should have called getRoom with true, and called /User/GetById', function () {
            spyOn(scope, 'getRoom');
            httpBackend.expectPOST('http://localhost:1337/User/GetById');

            window.userId = "Martin";
            scope.$apply();

            httpBackend.flush();
            expect(scope.getRoom).toHaveBeenCalledWith(true);
        });

        it('Image should not be to big', function () {
            scope.questionImage = { filesize: 2000, base64: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" };
            scope.$apply();
           
            expect(scope.imageTooBig).toBe(false);
        });

        it('Image should be to big', function () {
            scope.questionImage = { filesize: 2000000000, base64: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" };
            scope.$apply();

            expect(scope.imageTooBig).toBe(true);
        });

        it('should change the imageMessage to "Loading image..."', function () {
            scope.setImageMessage();

            expect(scope.ImageMessage).toBe("Loading image...");
        });

        it('should call /GetQuestionsForRoomWithoutImages?roomId=1', function() {
            httpBackend.expectGET('http://localhost:1337/Question/GetQuestionsForRoomWithoutImages?roomId=1');

            scope.getQuestions();

            httpBackend.flush();
        });

        it('should call /Room/toJsonQuestion and /Question/CreateQuestion, updated and no image', function () {
            httpBackend.expectPOST('/Room/toJsonQuestion', '{"RoomId":1,"ResponseOptions":"undefined,undefined"}');
            httpBackend.expectPOST('http://localhost:1337/Question/CreateQuestion');

            scope.UpdateQuestionBool = true;
            spyOn(scope, "modalChanger");
            spyOn(scope, "deleteQuestion");

            scope.postQuestion();

            httpBackend.flush();

            expect(scope.deleteQuestion).toHaveBeenCalled();
        });

        it('should call /Room/toJsonQuestion and /Question/CreateQuestion, updated and image', function () {
            httpBackend.expectPOST('/Room/toJsonQuestion', '{"RoomId":1,"Image":"R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==","ResponseOptions":"undefined,undefined"}');
            httpBackend.expectPOST('http://localhost:1337/Question/CreateQuestion');

            scope.UpdateQuestionBool = true;
            scope.questionImage = { base64: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" }
            spyOn(scope, "modalChanger");
            spyOn(scope, "deleteQuestion");

            scope.postQuestion();

            httpBackend.flush();

            expect(scope.deleteQuestion).toHaveBeenCalled();
        });


        it('should call /Room/toJsonQuestion and /Question/CreateQuestion, not update and no image', function () {
            httpBackend.expectPOST('/Room/toJsonQuestion', '{"RoomId":1,"Image":null,"ResponseOptions":"undefined,undefined"}');
            httpBackend.expectPOST('http://localhost:1337/Question/CreateQuestion');

            scope.UpdateQuestionBool = false;
            spyOn(scope, "modalChanger");
           
            scope.postQuestion();

            httpBackend.flush();
            });

        it('should call /Room/toJsonQuestion and /Question/CreateQuestion, not update and image', function () {
            httpBackend.expectPOST('/Room/toJsonQuestion', '{"RoomId":1,"Image":"R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==","ResponseOptions":"undefined,undefined"}');
            httpBackend.expectPOST('http://localhost:1337/Question/CreateQuestion');

            scope.UpdateQuestionBool = false;
            scope.questionImage = { base64: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" }
            spyOn(scope, "modalChanger");
            
            scope.postQuestion();

            httpBackend.flush();
        });

        it('should get the users answer', function() {
            scope.currentUser = { _id: "Martin" };
            
            var question = { Result: [{ UserId: "Martin", Value: 1 }, { UserId: "Nikolaj", Value: 2 }] }

            expect(scope.getSpecificAnswer(question)).toBe(1);
        });

        it('should get the null', function () {
            scope.currentUser = { _id:"Peter" };

            var question = { Result: [{ UserId: "Martin", Value: 1 }, { UserId: "Nikolaj", Value: 2 }] }

            expect(scope.getSpecificAnswer(question)).toBe(null);
        });

        it('should call /Question/AddQuestionResponse', function() {
            httpBackend.expectPOST("http://localhost:1337/Question/AddQuestionResponse");

            scope.answerChoosen = {Value: "Yes"};
            scope.SpecificQuestion= {_id:1};
        
            scope.AddAnswer();

            httpBackend.flush();
        });

        it('should increase responseoptions with 1', function() {
            scope.ResponseOptions = [];
            scope.AddResponseOption();

            expect(scope.ResponseOptions.length).toBe(1);
        });

        it('should decrease responseoptions with 1', function () {
            scope.ResponseOptions = [{ id: 0, val: "Test" },{ id: 1, val: "Test2" }];
            scope.RemoveResponseOption(scope.ResponseOptions[0]);

            expect(scope.ResponseOptions.length).toBe(1);
        });

        it('should call /Question/GetImageByQuestionId?questionId=1, image found', function () {
            httpBackend.when('GET', "http://localhost:1337/Question/GetImageByQuestionId?questionId=1").respond({});
            httpBackend.expectGET("http://localhost:1337/Question/GetImageByQuestionId?questionId=1");

            spyOn(scope, "getSpecificAnswer");
            spyOn(scope, "createPieChart");

            var question = { _id: 1 };
            scope.ShowSpecificQuestion(question);

            httpBackend.flush();

            expect(scope.NoPicture).toBe(false);
            expect(scope.getSpecificAnswer).toHaveBeenCalled();
            expect(scope.createPieChart).toHaveBeenCalled();
        });

        it('should call /Question/GetImageByQuestionId?questionId=1, image not found', function () {
            httpBackend.when('GET', "http://localhost:1337/Question/GetImageByQuestionId?questionId=1").respond("");
            httpBackend.expectGET("http://localhost:1337/Question/GetImageByQuestionId?questionId=1");

            spyOn(scope, "getSpecificAnswer");
            spyOn(scope, "createPieChart");

            var question = { _id: 1 };
            scope.ShowSpecificQuestion(question);

            httpBackend.flush();

            expect(scope.NoPicture).toBe(true);
            expect(scope.getSpecificAnswer).toHaveBeenCalled();
            expect(scope.createPieChart).toHaveBeenCalled();
        });

        it('timeLeft should be 00:10:00', function () {
            spyOn(Date, "now").and.returnValue(0);
            scope.SpecificQuestion = { CreationTimestamp: "0", ExpireTimestamp: "600000" }

            scope.getPercentage();

            expect(scope.timeLeft).toBe("00:10:00");
        });

        it('timeLeft should be "Time has run out" and scope.progressCancel should be undefined', function () {
            spyOn(Date, "now").and.returnValue(650000);
            scope.SpecificQuestion = { CreationTimestamp: "0", ExpireTimestamp: "600000" }
            scope.progressCancel = true;
            scope.getPercentage();

            expect(scope.timeLeft).toBe("Time has run out");
            expect(scope.progressCancel).toBe(undefined);
        });

        it('',function() {
            
        });
    });
});