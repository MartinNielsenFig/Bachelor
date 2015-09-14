//
//  Paged.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

protocol Paged {
    var pageIndex: Int { get }
    var roomId: String { get }
}