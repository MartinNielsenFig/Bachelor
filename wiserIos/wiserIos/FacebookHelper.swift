//
//  FacebookHelper.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 08/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookHelper {
    
    static func logOff() {
        print("begin log off facebook")
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        CurrentUser.sharedInstance.FacebookId = nil
    }
    
    static func requestCurrentUserInformation() {
        //http://stackoverflow.com/questions/30049450/get-fbsdkloginmanagerloginresults-email-and-name
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        fbRequest.startWithCompletionHandler {
            (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                print("User Info : \(result)")
                let fbId = result["id"]
                let name = result["name"]
                
                CurrentUser.sharedInstance.FacebookId = fbId as? String
                CurrentUser.sharedInstance.DisplayName = name as? String
                
            } else {
                print("Error Getting Info \(error)");
            }
        }
    }
}