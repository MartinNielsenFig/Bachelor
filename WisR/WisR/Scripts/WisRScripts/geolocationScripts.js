//Code for geolocation
var map;
var initialLoad = true;
var marker;
var positionId;
var geocoder = new google.maps.Geocoder();

navigator.geolocation.getCurrentPosition(function(position) {
    window.currentLocation = position;
});


function moveMap(position) {
    //currentLocation = position;
    var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    //Remove previous marker
    if (marker != null) {
        marker.setMap(null);
    }
    marker = new google.maps.Marker({
        position: latLng,
        animation: google.maps.Animation.BOUNCE
    });
    marker.setMap(map);
    //map.addOverlay(marker);
    map.setZoom(15);
    map.panTo(latLng);
    $("#accuracy").html('Precision: ' + position.coords.accuracy + ' meters');

    //Hide map on first load
    
    
    //Get address from location
    geocoder.geocode({ 'location': latLng }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            if (results[1]) {
                $("#address").html('You are here: ' + results[1].formatted_address);


            } else {
                window.alert('No results found');
            }
        } else {
            window.alert('Geocoder failed due to: ' + status);
        }
    });

}

function handleError(error) { alert(error.message); }

function initializeGeolocation() {

    var mapOptions = {
        disableDefaultUI: true
    }
    var positionOptions = {
        enableHighAccuracy: true
    };

    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

    positionId = navigator.geolocation.watchPosition(moveMap, handleError, positionOptions);
    google.maps.event.addDomListener(window, "resize", function () {
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
    });
}
// Code for hiding google maps 

function toggleLocation() {
    $("#googlemaps").toggle();
    if (initialLoad) {
        initializeGeolocation();
        initialLoad = false;
    }

}