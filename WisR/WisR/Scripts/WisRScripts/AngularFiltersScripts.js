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