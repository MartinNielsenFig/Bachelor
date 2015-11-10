//
//  ErrorTypes.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 04/11/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/**
 *	Notification class has an ErrorType after a Http call to the RestAPI. This indicates whether it went ok, ok but with errors (non essential errors that did not conflict with the main goal of the call) or it went wrong.
 */
public enum ErrorTypes: Int {
    case Ok = 0
    case Error
    case OkWithError
}