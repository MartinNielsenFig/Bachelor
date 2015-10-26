///<reference path="~/Scripts/jasmine/jasmine.js"/>
///<reference path="~/Scripts/ResoursesForTest/en-GB.js"/>
///<reference path="~/../WisR/Scripts/CryptoJS/rollups/sha512.js"/>
///<reference path="~/../WisR/Scripts/jquery-1.11.3.js"/>
///<reference path="~/../WisR/Scripts/jquery.signalR-2.2.0.js"/>
///<reference path="~/../WisR/Scripts/angular.js"/>
///<reference path="~/../WisR/Scripts/angular-mocks.js"/>
///<reference path="~/../WisR/Scripts/angular-base64-upload.js"/>
///<reference path="~/../WisR/Scripts/scrollglue.js"/>
///<reference path="~/../WisR/Scripts/Chart.js"/>
///<reference path="~/../WisR/Scripts/angular-chart.js"/>

///<reference path="~/Scripts/GoogleForTest/googleForTest.js"/>
///<reference path="~/Scripts/SignalRForTest/server.js"/>

///<reference path="~/../WisR/Scripts/WisRScripts/geolocationScripts.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/AngularModule.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/Config.js"/>
///<reference path="~/../WisR/Scripts/WisRScripts/AngularHomeController.js"/>
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
});