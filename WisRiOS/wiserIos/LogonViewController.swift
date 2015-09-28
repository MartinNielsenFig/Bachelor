//
//  LoginViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 08/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

/// Handles the logon view logic.
class LogonViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    //Properties
    var previousNavigationController: UINavigationController? = nil
    var previousViewController: UIViewController? = nil
    
    //Utilities
    @IBAction func cancelLogonBtn() {
        previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Lifecycle
    override func viewDidLoad() {
        //Login button
        let loginBtn = FBSDKLoginButton()
        loginBtn.center = self.view.center
        loginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        loginBtn.delegate = self
        self.view.addSubview(loginBtn)
    }
    
    //FBSDKLoginButtonDelegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if let granted = result.grantedPermissions {
            FacebookHelper.requestCurrentUserInformation(createUser: true)
            previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
            previousViewController?.performSegueWithIdentifier("CreateRoom", sender: previousViewController)
        } else {
            NSLog("Could not log onto Facebook")
            previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("Facebook log off")
    }
}
