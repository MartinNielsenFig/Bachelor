﻿//Code for geolocation
var map;
var initialLoad = true;
var marker;
var positionId;
var geocoder = new google.maps.Geocoder();

//Used to move the map to the position given
function moveMap(position) {

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
    
    map.setZoom(15);

    map.panTo(latLng);

    //Shows the accuaracy of the postition to the user
    $("#accuracy").html(Resources.Precision + position.coords.accuracy +" "+ Resources.Meters);

    //Get address from location
    geocoder.geocode({ 'location': latLng }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            if (results[1]) {
                $("#address").html(Resources.YouAreHere + results[1].formatted_address);
            } else {
                window.alert(Resources.NoResultsFound);
            }
        } else {
            window.alert(Resources.GeoCoderFailedDueTo + status);
        }
    });
}

function handleError(error) { alert(error.message); }

//initialize the map where you see your current position
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
//calculates the distance in km between to points on the globe
//http://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1);  // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)
    ;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
}

//Converts degress to radians
function deg2rad(deg) {
    return deg * (Math.PI / 180);
}
