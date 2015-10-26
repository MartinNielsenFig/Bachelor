//
//  IntervalUpdater.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 22/10/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation

/// A wrapper for NSTimer.scheduledTimerWithTimeInterval that takes a function as closure that it saves, so that the task can be easily stopped/resumed.
class Updater: NSObject {
    var timer: NSTimer!
    var userFunction: (() -> Void)!
    var secondsDelay: Double!
    
    init(secondsDelay: Double, function: () -> Void) {
        super.init()
        self.userFunction = function
        self.secondsDelay = secondsDelay
        timer = NSTimer.scheduledTimerWithTimeInterval(secondsDelay, target: self, selector: "execute", userInfo: nil, repeats: true)
    }
    
    func execute() {
        userFunction!()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(secondsDelay, target: self, selector: "execute", userInfo: nil, repeats: true)
    }
}