//
//  ChatViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, Paged {
    let pageIndex = 2
    var roomId: String?
    var chat = String()
    
    @IBOutlet weak var chatTextField: UITextView!
    
    override func viewDidLoad() {
        
        
        HttpHandler.getChatMessages(roomId!) { (messages) -> Void in
            for m in messages {
                let line = DateTimeHelper.getTimeStringFromEpochString(m.Timestamp) + " " + m.Value! + "\n"
                self.chat += line
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.chatTextField.text = self.chat
            })
        }
    }
}
