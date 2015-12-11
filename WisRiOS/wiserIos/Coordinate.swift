//
//  Coordinate.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// A coordinate in the world.
class Coordinate {
 /// Latitude value
    var Latitude: Double?
 /// Longitude value
    var Longitude: Double?
 /// Accuracy of the coordinate in meters when acquired
    var AccuracyMeters: Int?
 /// The formatted address of the coordinate. Currently not being used by iOS
    var FormattedAddress: String?
 /// Timestamp when the coordinate was acquired
    var Timestamp: String?
}