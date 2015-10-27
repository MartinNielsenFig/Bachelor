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
describe("SignalR Tests", function () {

    beforeEach(angular.mock.module('wisrApp'));

    describe("Home controller", function () {

        var scope, controller;

        beforeEach(inject(function ($rootScope, $controller) {
            scope = $rootScope.$new();
 
           controller = $controller('HomeController', { $scope: scope, window: window });
        }));

        it('should add one room to rooms', function () {
            scope.Rooms = [];
            $.connection.roomHub.client.broadcastRoom('{"_id": "562a2e8416d239241cb4c20e", "Name": "JasmineRoom", "CreatedById": "560e65f116d23914d4b08f74", "Location": { "Latitude": 56.1719015, "Longitude": 10.189167500000002, "AccuracyMeters": 20, "FormattedAddress": "IT-byen, Aarhus, Danmark", "Timestamp": "1445604940073" }, "Radius": 50, "Tag": "JasmineTag", "HasPassword": true, "EncryptedPassword": "a4a81d2d54e8deda9c7a1397413764851a6c5bb2b39d5a862d62c33d83683b1e96f2c99d8b9dacb5c9a9b502cd11f893b53c8ce520539cc5e7b8a4b37372090d", "HasChat": true, "UsersCanAsk": true, "AllowAnonymous": true, "UseLocation": true}');
            expect(scope.Rooms.length).toBe(1);
        });

        it('should update one room to rooms', function () {
            scope.Rooms = [];
            scope.Rooms[0] = { _id: "562a2e8416d239241cb4c20e", Name: "JasmineRoom", CreatedById: "560e65f116d23914d4b08f74", Location: { Latitude: 56.1719015, Longitude: 10.189167500000002, AccuracyMeters: 20, FormattedAddress: "IT-byen, Aarhus, Danmark", Timestamp: "1445604940073" }, Radius: 50, Tag: "JasmineTag", HasPassword: true, EncryptedPassword: "a4a81d2d54e8deda9c7a1397413764851a6c5bb2b39d5a862d62c33d83683b1e96f2c99d8b9dacb5c9a9b502cd11f893b53c8ce520539cc5e7b8a4b37372090d", HasChat: true, UsersCanAsk: true, AllowAnonymous: true, UseLocation: true };

            //The change is the position
            $.connection.roomHub.client.broadcastUpdateRoom('{"_id": "562a2e8416d239241cb4c20e", "Name": "JasmineRoom", "CreatedById": "560e65f116d23914d4b08f74", "Location": { "Latitude": 0, "Longitude":0, "AccuracyMeters": 20, "FormattedAddress": "IT-byen, Aarhus, Danmark", "Timestamp": "1445604940073" }, "Radius": 50, "Tag": "JasmineTag", "HasPassword": true, "EncryptedPassword": "a4a81d2d54e8deda9c7a1397413764851a6c5bb2b39d5a862d62c33d83683b1e96f2c99d8b9dacb5c9a9b502cd11f893b53c8ce520539cc5e7b8a4b37372090d", "HasChat": true, "UsersCanAsk": true, "AllowAnonymous": true, "UseLocation": true}');

            expect(scope.Rooms[0].Location.Latitude).toBe(0);
            expect(scope.Rooms[0].Location.Longitude).toBe(0);
        });
    });
        describe("Room controller", function () {

            var scope, controller;

            beforeEach(inject(function ($rootScope, $controller) {
                scope = $rootScope.$new();

                scope.CurrentRoom = { _id: "560e66bc16d23936284bf130" };

                controller = $controller('RoomController', { $scope: scope, window: window });
            }));

            it('should add one chat message to ChatMessages', function () {
                scope.ChatMessages = [];
                $.connection.chatHub.client.broadcastChatMessage('{ "_id" : "562e300dc7f56237b8652b48", "ByUserId" : "NoUser", "RoomId" : "560e66bc16d23936284bf130", "Value" : "Jasmin Test", "Timestamp" : "1445867533701" }');
                expect(scope.ChatMessages.length).toBe(1);
            });

            it('should add question to questions', function () {
                scope.Questions = [];
                $.connection.questionHub.client.broadcastQuestion('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" : [], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');
                expect(scope.Questions.length).toBe(1);
            });

            it('should update currentRoom', function() {
                scope.CurrentRoom = { _id: "562a2e8416d239241cb4c20e", Name: "JasmineRoom", CreatedById: "560e65f116d23914d4b08f74", Location: { Latitude: 56.1719015, Longitude: 10.189167500000002, AccuracyMeters: 20, FormattedAddress: "IT-byen, Aarhus, Danmark", Timestamp: "1445604940073" }, Radius: 50, Tag: "JasmineTag", HasPassword: true, EncryptedPassword: "a4a81d2d54e8deda9c7a1397413764851a6c5bb2b39d5a862d62c33d83683b1e96f2c99d8b9dacb5c9a9b502cd11f893b53c8ce520539cc5e7b8a4b37372090d", HasChat: true, UsersCanAsk: true, AllowAnonymous: true, UseLocation: true };

                spyOn(scope, "toggleRoomLocation");

                //The change is the position
                $.connection.roomHub.client.broadcastUpdateRoom('{"_id": "562a2e8416d239241cb4c20e", "Name": "JasmineRoom", "CreatedById": "560e65f116d23914d4b08f74", "Location": { "Latitude": 0, "Longitude":0, "AccuracyMeters": 20, "FormattedAddress": "IT-byen, Aarhus, Danmark", "Timestamp": "1445604940073" }, "Radius": 50, "Tag": "JasmineTag", "HasPassword": true, "EncryptedPassword": "a4a81d2d54e8deda9c7a1397413764851a6c5bb2b39d5a862d62c33d83683b1e96f2c99d8b9dacb5c9a9b502cd11f893b53c8ce520539cc5e7b8a4b37372090d", "HasChat": true, "UsersCanAsk": true, "AllowAnonymous": true, "UseLocation": true}');

                expect(scope.CurrentRoom.Location.Latitude).toBe(0);
                expect(scope.CurrentRoom.Location.Longitude).toBe(0);
                expect(scope.toggleRoomLocation).toHaveBeenCalled();
            });

            it('should update question', function() {
                scope.Questions = [{_t:	"MultipleChoiceQuestion", _id:"562e3b88c7f56237b8652b49",RoomId:"560e66bc16d23936284bf130", CreatedById:	"NoUser", Votes:[0], Img:	"R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==",QuestionText	:	"askldjk", ResponseOptions:	[{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result:[0], CreationTimestamp:	"1445870472559", ExpireTimestamp:"1473258372559"}];
                $.connection.questionHub.client.broadcastUpdateQuestion('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" : [{ "CreatedById" : "560e7203c7f562bd7cadd5f0", "Value" : -1 },{ "CreatedById" : "560e7203c7Asdasdd5f0", "Value" : 1 }], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');
                expect(scope.Questions[0].Votes.length).toBe(2);
            });

            it('should update question and specific question', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                scope.SpecificQuestion = { _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" };

                spyOn(scope, "createPieChart");

                $.connection.questionHub.client.broadcastUpdateQuestion('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" : [-1,1], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');

                expect(scope.Questions[0].Votes.length).toBe(2);
                expect(scope.SpecificQuestion.Votes.length).toBe(2);
            });

            it('should delete question', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                $.connection.questionHub.client.broadcastDeleteQuestion('562e3b88c7f56237b8652b49');
                expect(scope.Questions.length).toBe(0);
            });

            it('should update questions results', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                $.connection.questionHub.client.broadcastUpdateResult('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" : [], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [{ "Value" : "a", "UserId" : "560e65f116d23914d4b08f74" }], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');
                expect(scope.Questions[0].Result.length).toBe(1);
            });

            it('should update questions and specific questions results', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                scope.SpecificQuestion = { _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" };

                spyOn(scope, "createPieChart");

                $.connection.questionHub.client.broadcastUpdateResult('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" : [], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [{ "Value" : "a", "UserId" : "560e65f116d23914d4b08f74" }], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');

                expect(scope.Questions[0].Result.length).toBe(1);
                expect(scope.SpecificQuestion.Result.length).toBe(1);
            });

            it('should update questions votes', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                $.connection.questionHub.client.broadcastUpdateVotes('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" :  [{ "CreatedById" : "560e7203c7f562bd7cadd5f0", "Value" : -1 },{ "CreatedById" : "560e7203c7Asdasdd5f0", "Value" : 1 }], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');
                expect(scope.Questions[0].Votes.length).toBe(2);
            });

            it('should update questions and specific questions votes', function () {
                scope.Questions = [{ _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" }];
                scope.SpecificQuestion = { _t: "MultipleChoiceQuestion", _id: "562e3b88c7f56237b8652b49", RoomId: "560e66bc16d23936284bf130", CreatedById: "NoUser", Votes: [0], Img: "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", QuestionText: "askldjk", ResponseOptions: [{ Value: "adsa", Weight: 0 }, { Value: "dsadasd", Weight: 0 }], Result: [0], CreationTimestamp: "1445870472559", ExpireTimestamp: "1473258372559" };
                
                $.connection.questionHub.client.broadcastUpdateVotes('{ "_t" : "MultipleChoiceQuestion", "_id" : "562e3b88c7f56237b8652b49", "RoomId" : "560e66bc16d23936284bf130", "CreatedById" : "NoUser", "Votes" :  [{ "CreatedById" : "560e7203c7f562bd7cadd5f0", "Value" : -1 },{ "CreatedById" : "560e7203c7Asdasdd5f0", "Value" : 1 }], "Img" : "R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==", "QuestionText" : "askldjk", "ResponseOptions" : [{ "Value" : "adsa", "Weight" : 0 }, { "Value" : "dsadasd", "Weight" : 0 }], "Result" : [], "CreationTimestamp" : "1445870472559", "ExpireTimestamp" : "1473258372559" }');
               
                expect(scope.Questions[0].Votes.length).toBe(2);
                expect(scope.SpecificQuestion.Votes.length).toBe(2);
            });


        });
});