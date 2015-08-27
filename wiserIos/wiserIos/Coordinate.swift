//
//  Coordinate.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Coordiante {
    var latitude: Double
    var longitude: Double
    var accuracy: Int
    var formattedAddress: String
    var timeStamp: String
    
    init(latitude: Double, longitude: Double, accuracy: Int, formattedAddress: String, timeStamp: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.formattedAddress = formattedAddress
        self.timeStamp = timeStamp
    }
}