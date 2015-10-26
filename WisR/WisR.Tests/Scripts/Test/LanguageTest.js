///<reference path="~/Scripts/jasmine/jasmine.js"/>
///<reference path="~/Scripts/ResoursesForTest/da-DK.js"/>
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

describe("Danish Test", function () {

    beforeEach(angular.mock.module('wisrApp'));

    describe("Home controller", function () {

        var scope, controller, httpBackend, config;

        beforeEach(inject(function ($rootScope, $controller, $httpBackend, configs) {
            scope = $rootScope.$new();
            config = configs;
            httpBackend = $httpBackend;

            //Setup for http request
            httpBackend.when('GET', 'http://localhost:1337/Room/GetAll').respond({});
            httpBackend.when('POST', 'http://localhost:7331/Home/toJsonRoom').respond({});
            httpBackend.when('POST', 'http://localhost:1337/Room/CreateRoom').respond({
                data: '12;Hest'
            });
            httpBackend.when('POST', 'http://localhost:7331/Home/toJsonUser').respond({});
            httpBackend.when('POST', 'http://localhost:1337/User/UpdateUser').respond({});

            //Setup for currentUser
            scope.currentUser = { ConnectedRoomIds: [] }

            //Setup for location
            scope.currentLocation = { coords: { latitude: 1 } };
            scope.currentLocation = { coords: { longitude: 1 } };

            controller = $controller('HomeController', { $scope: scope, window: window });
        }));


        it('should change $scope.message to "Rummet med det tag, kræver at du logger ind"', function () {
            var room = { AllowAnonymous: false }
            scope.userId = 'NoUser';
            scope.changeViewToRoom(room);
            expect(scope.Message).toBe('Rummet med det tag, kræver at du logger ind');
        });
    });
});