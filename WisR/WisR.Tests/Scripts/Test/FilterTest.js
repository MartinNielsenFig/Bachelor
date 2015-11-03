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
///<reference path="~/../WisR/Scripts/WisRScripts/AngularFiltersScripts.js"/>

describe("Filter Test", function() {
    beforeEach(angular.mock.module('wisrApp'));

    it('has a CountVotes filter', inject(function ($filter) {
        expect($filter('CountVotes')).not.toBeNull();
    }));

    it('bool filter should return 2', inject(function (CountVotesFilter) {
        expect(CountVotesFilter([{ Value: 1 }, { Value: 1 }, { Value: -1 }],1)).toBe(2);
    }));

    it('bool filter should return null', inject(function (CountVotesFilter) {
        expect(CountVotesFilter(null, 1)).toBe(null);
    }));

    it('roomsNearfilter should return array', inject(function (roomsNearFilter) {

        spyOn(scope, "shouldBeAdded").to.returnValue(true);
        expect(roomsNearFilter([{ Name: "Room1" }, { Name: "Room2" }, { Name: "Room3" }], { Place: Here })).toBeEqual([{ Name: "Room1" }, { Name: "Room2" }, { Name: "Room3" }]);
    }));
});