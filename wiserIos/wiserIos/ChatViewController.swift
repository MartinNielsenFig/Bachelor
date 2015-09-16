//
//  ChatViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, Paged {
    let pageIndex = 2
    var roomId: String?
    
    var chat = String() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.chatTextField.text = self.chat
                let range = NSMakeRange(self.chatTextField.text.characters.count - 1, 1)
                self.chatTextField.scrollRangeToVisible(range)
            }
        }
    }
    
    @IBOutlet weak var chatTextField: UITextView!
    @IBOutlet weak var chatMessageInput: UITextField!
    
    override func viewDidLoad() {
        
        chatMessageInput.delegate = self
        
        HttpHandler.getChatMessages(roomId!) { (messages) -> Void in
            
            for m in messages {
                let line = DateTimeHelper.getTimeStringFromEpochString(m.Timestamp) + " " + m.Value! + "\n"
                self.chat += String(line)
            }
        }
        
        
    }
    
    //UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        movePlate(textField, up: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        movePlate(textField, up: false)
    }
    
    //http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
    func movePlate(field: UITextField, up: Bool) {
        let movementDistance = 120 // tweak as needed
        let movementDuration = 0.3 // tweak as needed
        
        let movement = (up ? -movementDistance : movementDistance)
        
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(movementDuration))
        self.view.frame = CGRectOffset(self.view.frame, 0, CGFloat(movement))
        UIView.commitAnimations()
    }
    
}
