//
//  Toast.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 27/10/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// A simple Android style toast/on screen message that dismisses itself after a chosen period. Can call an optional callback function when dismissing.
class Toast {
    
    /**
     Shows toast for user with ok button for confirmation that they read the message.
     - parameter title:			Title for alert
     - parameter message:		Message for alert
     - parameter presenter:	The presenter to show the alert
     */
    static func showOkToast(title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Cancel, handler: {
            action in
            //Do nothing
        }))
        presenter.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Shows a Toast android style for the user without ok button that dismisses itself after a specified time.
     - parameter message:		Message for alert
     - parameter durationMs:	Duration before dismissing itself
     - parameter presenter:	The presenter to show the alert
     - parameter imageName:	An optional string name for a image to be shown with the toast.
     - parameter callback:		An optional callback method to be called after the toast dismissed itself.
     */
    static func showToast(message: String, durationMs: Int, presenter: UIViewController, imageName: String? = nil, callback: (() -> Void)? = nil) {
        
        let toast = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        
        //http://stackoverflow.com/questions/26347085/add-image-to-uialertaction-in-uialertcontroller
        if let imageName = imageName {
            let image = UIImage(named: imageName)!
            let action = UIAlertAction(title: "", style: .Default, handler: nil)
            action.setValue(image, forKey: "image")
            toast.addAction(action)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            presenter.presentViewController(toast, animated: true, completion: nil)
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(durationMs) * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
            toast.dismissViewControllerAnimated(true, completion: nil)
            if callback != nil {
                callback!()
            }
        }
    }
}