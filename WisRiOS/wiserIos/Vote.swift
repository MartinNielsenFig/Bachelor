//
//  Vote.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 21/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Vote {
    var CreatedById: String?
    var Value: Int?
    
    init(createdById: String, value: Int){
        self.CreatedById = createdById
        self.Value = value
    }
}