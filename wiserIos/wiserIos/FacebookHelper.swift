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
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        CurrentUser.sharedInstance.FacebookId = nil
    }
    
    static func requestCurrentUserInformation(createUser createUser: Bool) {
        //http://stackoverflow.com/questions/30049450/get-fbsdkloginmanagerloginresults-email-and-name
        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        fbRequest.startWithCompletionHandler {
            (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                NSLog("User Info : \(result)")
                let fbId = result["id"]
                let name = result["name"]
                
                CurrentUser.sharedInstance.FacebookId = fbId as? String
                CurrentUser.sharedInstance.DisplayName = name as? String
                let user = User()
                user.FacebookId = CurrentUser.sharedInstance.FacebookId
                user.DisplayName = CurrentUser.sharedInstance.DisplayName
                
                let userJson = JSONSerializer.toJson(user)
                
                if createUser {
                    HttpHandler.createUser(userJson, completionHandler: {(inout mongoDBId: String) in
                        CurrentUser.sharedInstance._id = mongoDBId
                    })
                }
                
            } else {
                NSLog("Error Getting Info \(error)");
            }
        }
    }
}