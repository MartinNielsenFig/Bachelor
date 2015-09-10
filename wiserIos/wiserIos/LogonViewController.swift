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

class LogonViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var previousNavigationController: UINavigationController? = nil
    
    @IBAction func cancelLogonBtn() {
        previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        print("Facebook login")
        
        if let granted = result.grantedPermissions {
            NSLog(String(granted))
            FacebookHelper.requestCurrentUserInformation()
        } else {
            NSLog("Could not log onto Facebook")
        }
        
        previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Facebook log off")
    }
}
