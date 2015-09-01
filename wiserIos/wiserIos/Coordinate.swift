//
//  Coordinate.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Coordinate {
    var Latitude: Double
    var Longitude: Double
    var AccuracyMeters: Int
    var FormattedAddress: String
    var Timestamp: String
    
    init(latitude: Double, longitude: Double, accuracyMeters: Int, formattedAddress: String, timestamp: String) {
        self.Latitude = latitude
        self.Longitude = longitude
        self.AccuracyMeters = accuracyMeters
        self.FormattedAddress = formattedAddress
        self.Timestamp = timestamp
    }
}