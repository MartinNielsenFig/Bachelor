//
//  Coordinate.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Coordinate {
    var latitude: Double
    var longitude: Double
    var accuracyMeters: Int
    var formattedAddress: String
    var timestamp: String
    
    init(latitude: Double, longitude: Double, accuracyMeters: Int, formattedAddress: String, timestamp: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracyMeters = accuracyMeters
        self.formattedAddress = formattedAddress
        self.timestamp = timestamp
    }
}