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
    });
});