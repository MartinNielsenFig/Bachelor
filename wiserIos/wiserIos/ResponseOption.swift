//
//  ResponseOption.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class ResponseOption {
    var value: String
    var weight: Int
    
    init(value: String, weight: Int) {
        self.value = value
        self.weight = weight
    }
}