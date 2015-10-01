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

//Function that returns true if room should be added to table
var shouldBeAdded = function (room, scope) {
    if (room.UseLocation === true) {
        var temp = (getDistanceFromLatLonInKm(room.Location.Latitude, room.Location.Longitude, scope.currentLocation.coords.latitude, scope.currentLocation.coords.longitude) * 1000);

        if (temp <= (room.Radius + room.Location.AccuracyMeters + scope.currentLocation.coords.accuracy)) {
            return true;
        }
    }
    return false;
}

//Filter that counts the amount of votes of specified value (-1 == Downote, 1 == Upvote)
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