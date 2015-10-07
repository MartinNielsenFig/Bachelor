///<reference path="~/Scripts/jasmine/jasmine.js"/>
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

describe("Homecontroller", function () {

    beforeEach(angular.mock.module('wisrApp'));

    describe("Home controller", function () {

        var scope, controller;

        beforeEach(inject(function ($rootScope, $controller) {
            scope = $rootScope.$new();

            controller = $controller('HomeController', { $scope: scope });
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
            expect(scope.Message).toBe('The room-tag you have entered requires you to be logged in');
        });
    
        it('should change location to ?RoomId=1', function () {
            var room = { _id: 1 }
            scope.userId = 'NoUser';
            scope.changeViewToRoom(room);
            expect(location.href).toBe('http://localhost:63385/?RoomId=1');
        });
    });
});