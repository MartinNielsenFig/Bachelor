//
//  ResponseOption.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// ResponseOption is a part of a Question. A Question can have one or more ResponseOptions.
class ResponseOption {
    var Value: String
    var Weight: Int
    
    init(value: String, weight: Int) {
        self.Value = value
        self.Weight = weight
    }
}