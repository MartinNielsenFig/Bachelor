//
//  Paged.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/**
*	A protocol that each sub-ViewController of RoomPageViewController comforms to. 
*/
protocol Paged {
    var pageIndex: Int { get }
    var roomId: String? { get set }
}