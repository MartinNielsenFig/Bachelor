//
//  RoomFilterHelper.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 28/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class RoomFilterHelper {
    /**
    Returns a new array of Room containing only the rooms that are within a specified radius of the current user that is logged on. Required that CurrentUser.sharedInstance.location is set.
    - parameter rooms:				An array of Room to be filtered.
    - parameter metersRadius:	The radius in which the room has to be in proximity to the user. Adds the accuracy of the room location and user location to this.
    - returns: Array of filtered rooms.
    */
    static func filterRoomsByLocation(rooms: [Room], metersRadius: Double) -> [Room] {
        let start = NSDate()
        var filteredRooms = [Room]()
        
        let currentLong = CurrentUser.sharedInstance.location.Longitude
        let currentLat = CurrentUser.sharedInstance.location.Latitude
        let currentAccuracyMeters = Double(CurrentUser.sharedInstance.location.AccuracyMeters ?? 0)
        
        if let cLong = currentLong, cLat = currentLat {
            for room in rooms {
                if let useLocation = room.UseLocation where useLocation == true {
                    if let rLong = room.Location.Longitude, rLat = room.Location.Latitude {
                        
                        let roomAccuracy = Double(room.Location.AccuracyMeters ?? 0)
                        let distance = distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong) + currentAccuracyMeters + roomAccuracy
                        if distance < metersRadius {
                            filteredRooms += [room]
                        }
                    }
                }
            }
        }
        print("duration of \(__FUNCTION__) took \(NSDate().timeIntervalSinceDate(start))")
        return filteredRooms
    }
    
    
    /**
    Calculation based upon http://www.movable-type.co.uk/scripts/latlong.html Calculates the distance between to latitude-longitude pairs.
    - parameter lat1:	latitude of the first coordinate
    - parameter long1:	longitude of the first coordinate
    - parameter lat2:	latitude of the second coordinate
    - parameter long2:	longitude of the second coordinate
    - returns: Distance between the two coordinates
    */
    static func distanceBetweenTwoCoordinatesMeters(lat1: Double, _ long1: Double, _ lat2: Double, _ long2: Double) -> Double {
        let r = 6371000.0
        let dLat = degreesToRadians(lat2-lat1)
        let dLong = degreesToRadians(long2-long1)
        
        let a = sin(dLat/2)*sin(dLat/2) + cos(degreesToRadians(lat1))*cos(degreesToRadians(lat2)) * sin(dLong/2)*sin(dLong/2)
        let c = 2*atan2(sqrt(a), sqrt(1-a))
        let d = r*c
        return d
    }
    
    /**
    Converts degrees to radians.
    - parameter degree:	Angle in degree
    - returns: Angle in radians
    */
    static func degreesToRadians(degree: Double) -> Double {
        return (degree*M_PI)/180
    }
}