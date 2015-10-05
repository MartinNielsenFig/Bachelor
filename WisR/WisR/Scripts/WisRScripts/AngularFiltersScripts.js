/**
 * @ngdoc filter
 * @name WisR.filter:roomsNear
 * @description
 *Filter that returns the rooms that are nearby(based on location)
 * @param {Array<Room>} rooms the array of rooms to be filtered
 * @param {Scope} scope the angular scope for the controller(so that we can access the currentLocation of the user)
 * @returns {Array<Room>} filtered the filtered array of rooms
 */
//Filters if the room is near the currentLocation
app.filter('roomsNear', function () {
    return function (rooms, scope) {
        if (rooms != undefined && scope.currentLocation != undefined) {
            var filtered = [];
            
            for (var i = 0; i < rooms.length; i++) {
                var room = rooms[i];
                if (shouldBeAdded(room, scope))
                    filtered.push(room);
            }
            return filtered;
        }
    };
});

/**
            * @ngdoc method
            * @name roomsNear#shouldBeAdded
            * @methodOf WisR.filter:roomsNear
            * @param {Room} room the room to check the location of
            * @param {Scope} scope the angular scope for the controller(so that we can access the currentLocation of the user)
            * @description
            * Helper function for the roomsNear filter that figures out whether or not a room is near the users location
            * @returns {Boolean} bool True if the room should be added to the filtered list
            */
var shouldBeAdded = function (room, scope) {
    if (room.UseLocation === true) {
        var temp = (getDistanceFromLatLonInKm(room.Location.Latitude, room.Location.Longitude, scope.currentLocation.coords.latitude, scope.currentLocation.coords.longitude) * 1000);

        if (temp <= (room.Radius + room.Location.AccuracyMeters + scope.currentLocation.coords.accuracy)) {
            return true;
        }
    }
    return false;
}
/**
 * @ngdoc filter
 * @name WisR.filter:Votes
 * @description
 * Filter that counts the amount of votes of specified value (-1 == Downote, 1 == Upvote)
 * @param {Array<Vote>} votes Array with votes to be filtered
 * @param {Integer} value The value to check for(-1 or 1)
 * @returns {Integer} counter the filtered ammount of votes of the specified value
 */
app.filter('Votes',function() {
    return function (votes, value) {
        if (votes != undefined) {
            var counter = 0;

            for (var i = 0; i < votes.length; i++) {
                if (votes[i].Value == value) {
                    counter = counter + 1;
                }
            }

            return counter;
        } else {
            return null;
        }
    }
})