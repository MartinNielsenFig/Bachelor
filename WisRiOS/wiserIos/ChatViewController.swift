//
//  ChatViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JsonSerializerSwift

/// A sub-ViewController of RoomPageViewController. This handles the chat logic for the room.
class ChatViewController: UIViewController, UITextFieldDelegate, Paged {
    
    //Properties
    let pageIndex = 2
    var roomId: String?
    
    var chat = String() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.chatTextField.text = self.chat
                let range = NSMakeRange(self.chatTextField.text.characters.count - 1, 1)
                self.chatTextField.scrollRangeToVisible(range)
            }
        }
    }
    
    @IBOutlet weak var chatTextField: UITextView!
    @IBOutlet weak var chatMessageInput: UITextField!
    
    //Lifecycle
    override func viewDidLoad() {
        
        print("ChatViewController instantiated, roomId: \(self.roomId)")
        super.viewDidLoad()
        
        chatMessageInput.delegate = self
        
        let body = "roomId=\(roomId!)"
        HttpHandler.requestWithResponse(action: "Chat/GetAllByRoomId", type: "POST", body: body) { (data, response, error) in
            
            var tempChat = String()
            if let msg = try? ReturnMessage.parse(data), jsonArray = try? JSONSerializer.toArray(msg.Data)  {
                var messageArray = [ChatMessage]()
                for chatMsg in jsonArray {
                    let m = ChatMessage(jsonDictionary: chatMsg as! NSDictionary)
                    messageArray += [m]
                    let line = DateTimeHelper.getTimeStringFromEpochString(m.Timestamp) + " " + m.Value! + "\n"
                    tempChat += line
                }
            }
            else {
                tempChat += "Could not load the chat"
            }
            self.chat = tempChat
        }
    }

    //UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text where text.isEmpty {
            return false
        }
        
        let msg = ChatMessage()
        msg.ByUserId = CurrentUser.sharedInstance._id
        msg.RoomId = roomId
        //message timestamp gets created on restApi
        msg.Value = textField.text
        
        
        let msgJson = JSONSerializer.toJson(msg)
        let body = "ChatMessage=\(msgJson)"
        HttpHandler.requestWithResponse(action: "Chat/CreateChatMessage", type: "POST", body: body) { (data, response, error) in
            NSLog("Chat/CreateChatMessage Done")
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        movePlate(textField, up: true)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        movePlate(textField, up: false)
    }
    
    //Utilities
    /**
    Moves the view up/down when displaying the keyboard. This function is inspired heavely by http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
    - parameter field:	The text field the user entered which triggered this function
    - parameter up:		Determines whether the plate should move up (true) or down (false)
    */
    func movePlate(field: UITextField, up: Bool) {
        
        let movementDistance = 220 // tweak as needed
        let movementDuration = 0.3 // tweak as needed
        
        let movement = (up ? -movementDistance : movementDistance)
        
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(movementDuration))
        self.view.frame = CGRectOffset(self.view.frame, 0, CGFloat(movement))
        UIView.commitAnimations()
    }
    
    /*
    in viewDidLoad:
    //Todo remove observer
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)
    
    
    var keyboardHeight = CGFloat(200)
    var totalMovement = CGFloat(0)
    //http://stackoverflow.com/questions/11284321/what-is-the-height-of-iphones-onscreen-keyboard
    func getboardHeight(notification: NSNotification) -> CGFloat {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        return keyboardFrame.height
    }
    func keyboardShown(notification: NSNotification) {
        movePlate(chatMessageInput, up: true, movementDistance: getboardHeight(notification))
    }
    func keyboardHidden(notification: NSNotification) {
        movePlate(chatMessageInput, up: false, movementDistance: getboardHeight(notification))
    }*/
}
