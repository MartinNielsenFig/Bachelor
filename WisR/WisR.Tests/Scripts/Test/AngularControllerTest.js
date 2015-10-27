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
            httpBackend.when('POST','http://localhost:1337/User/GetById').respond({});

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
    });
});