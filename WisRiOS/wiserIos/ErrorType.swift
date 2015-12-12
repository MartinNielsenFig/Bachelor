//
//  ErrorTypes.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 04/11/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/**
 *	Notification class has an ErrorType after a Http call to the WisRApi. This indicates whether it went ok, ok but with errors (non essential errors that did not conflict with the main goal of the call) or it went wrong.
 */
enum ErrorTypes: Int {
    /**
     *	Received from wep api when the http request was succesful
     */
    case Ok = 0
    /**
     *	Received from wep api when the http request was Unsuccesful. Read the errors in Notification.ErrorCodes
     */
    case Error
    /**
     *	Received from wep api when the http request was succesful but with errors. Read the errors in Notification.ErrorCodes
     */
    case OkWithError
}