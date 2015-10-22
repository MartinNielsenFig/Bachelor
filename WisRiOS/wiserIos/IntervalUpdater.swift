//
//  IntervalUpdater.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 22/10/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

class Updater: NSObject {
    var timer: NSTimer?
    var userFunction: (() -> Void)?
    
    init(secondsDelay: Double, function: () -> Void) {
        super.init()
        userFunction = function
        timer = NSTimer.scheduledTimerWithTimeInterval(secondsDelay, target: self, selector: "execute", userInfo: nil, repeats: true)
    }
    
    func execute() {
        userFunction!()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}