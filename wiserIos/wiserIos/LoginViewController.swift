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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var previousNavigationController: UINavigationController? = nil

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
        print(result.grantedPermissions)
        
        FacebookHelper.requestCurrentUserInformation()
        previousNavigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Facebook log off")
    }
}
