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
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, Paged {
    
    //MARK: Properties
    
    let pageIndex = 2
    let kbOffset = CGFloat(38)
    let inputAccessoryViewId = 100  //id is given from storyboard
    
    var roomId: String?
    var messages = [ChatMessage]()
    var updater: Updater?
    var firstLoad = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textMessageInput: UITextField!
    @IBOutlet weak var messageInputStack: UIStackView!
    @IBOutlet weak var messageInputStackContainerView: UIView!
    
    //MARK: Actions
    
    @IBAction func sendPressed(sender: AnyObject) {
        updater?.stop()
        if let text = textMessageInput.text where text.isEmpty {
            print("empty message not allowed in chat")
            return
        }
        
        let msg = ChatMessage()
        msg.ByUserId = CurrentUser.sharedInstance._id
        msg.RoomId = roomId
        //message timestamp gets created on restApi
        msg.Value = textMessageInput.text
        
        let msgJson = JSONSerializer.toJson(msg)
        let body = "ChatMessage=\(msgJson)"
        HttpHandler.requestWithResponse(action: "Chat/CreateChatMessage", type: "POST", body: body) { (data, response, error) in
            NSLog("Chat/CreateChatMessage Done")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.textMessageInput.text = ""
                
                //If the last message is not visible, scroll to bottom
                if self.stickToBottom() {
                    self.scrollToBottom()
                }
                self.updater?.start()
                self.updater?.execute()
            }
        }
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        print("ChatViewController instantiated, roomId: \(self.roomId)")
        textMessageInput.delegate = self
        
        //Add border to keyboard input field
        //http://stackoverflow.com/questions/17355280/how-to-add-a-border-just-on-the-top-side-of-a-uiview
        let border = UIView()
        border.backgroundColor = UIColor.lightGrayColor()
        border.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        border.frame = CGRectMake(0, 0, self.messageInputStackContainerView.frame.width, 0.5)
        self.messageInputStackContainerView.addSubview(border)
        
        //tableView.keyboardDismissMode = .Interactive
        
        //Add gesture recognizer to enable swipe keyboard down
        let swipe = UISwipeGestureRecognizer(target: self, action: "userSwipeDownKeyboard")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.messageInputStackContainerView.addGestureRecognizer(swipe)
    }
    
    //Setup registering for keyboard events
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appGoesToBackground:", name: UIApplicationWillResignActiveNotification, object: nil)
        
        updater = Updater(secondsDelay: 1) {
            self.updateChatPoll()
        }
        updater?.execute()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        
        updater?.stop()
    }
    
    //MARK: Utilities
    
    func updateChatPoll() {
        let body = "roomId=\(self.roomId!)"
        HttpHandler.requestWithResponse(action: "Chat/GetAllByRoomId", type: "POST", body: body) { (data, response, error) in
            let sticky = self.stickToBottom()
            var newMessages = false
            if let jsonArray = try? JSONSerializer.toArray(data)  {
                
                for chatMsg in jsonArray {
                    let m = ChatMessage(jsonDictionary: chatMsg as! NSDictionary)
                    
                    if Double(m.Timestamp!) > self.oldestMessageEpochByIndex() {
                        self.messages += [m]
                        newMessages = true
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if newMessages {
                        self.tableView.reloadData()
                    }
                    
                    if sticky || self.firstLoad {
                        self.scrollToBottom()
                        self.firstLoad = false
                    }
                }
            }
            else {
                print("could not update chat")
            }
        }

    }
    
    /**
    Called when user swiped down on messageInputStackContainerView. Used to hide the keyboard.
    */
    func userSwipeDownKeyboard() {
        print("user did swipe down keyboard")
        textMessageInput.resignFirstResponder()
    }
    
    /**
     Scrolls to the bottom of the table view presented on this page
     */
    func scrollToBottom() {
        let chatFieldHeight = self.messageInputStack.frame.height + 10
        dispatch_async(dispatch_get_main_queue()) {
            if self.messages.count > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                //self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y + chatFieldHeight), animated: true)
            }
        }
    }
    
    /**
     Policy that determines whether updates to the chat should scroll the UITableView to the bottom. This is to ensure that the user can scroll up the list to look at older messages, without the UITableView scrolling down again.
     - returns: Whether UITableView should scroll to bottom on updates.
     */
    func stickToBottom() -> Bool {
        if self.messages.count > 1 {
            return self.isMessageShown(self.messages.count-1)
        } else {
            return false
        }
    }
    
    /**
     Determines whether the cell with index.row is shown on the UI
     - parameter row:	The row of the cell to check if is visible
     - returns: True if the cell with given row is shown on GUI. Else false.
     */
    func isMessageShown(row: Int) -> Bool {
        var visible = false
        if messages.count > 0 {
            self.tableView.indexPathsForVisibleRows?.forEach({ (indexPath) -> () in
                if indexPath.row == row {
                    visible = true
                }
            })
        } else {
            return true
        }
        return visible
    }
    
    /**
     Looks through the downloaded messages and looks for the oldest message. Then returns its timestamp. Could probably just look at the message last in the array.
     - returns: Timestamp as seconds since 1-1-1970.
     */
    func oldestMessageEpochByIteration() -> Double {
        var oldestTime = 0.0
        for m in self.messages {
            if let timeStamp = m.Timestamp {
                let timeStampDouble = Double(timeStamp.stringByReplacingOccurrencesOfString(",", withString: "."))
                if timeStampDouble > oldestTime {
                    oldestTime = timeStampDouble!
                }
            }
        }
        return oldestTime
    }
    
    /**
     Assumes the oldest message is the last one in the array.
     - returns: Timestamp of the presumably oldest message as seconds sinde 1-1-1970
     */
    func oldestMessageEpochByIndex() -> Double {
        if self.messages.count > 0 {
            if let ts = self.messages[self.messages.count-1].Timestamp {
                return Double(ts.stringByReplacingOccurrencesOfString(",", withString: "."))!
            }
        }
        return Double(0)
    }
    
    
    //MARK: UITableViewController
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.numberOfLines = 0
        let msg = messages[indexPath.row]
        cell.textLabel?.text = msg.Value
        
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        
        if msg.ByUserId == CurrentUser.sharedInstance._id {
            cell.backgroundColor = UIColor(red: 35/255, green: 213/255, blue: 22/255, alpha: 1)
            cell.textLabel?.textAlignment = .Right
        } else {
            cell.backgroundColor = UIColor(red: 25/255, green: 140/255, blue: 240/255, alpha: 1)
            cell.textLabel?.textAlignment = .Left
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("scroll began")
        updater?.stop()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scroll ended")
        updater?.start()
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendPressed(self)
        return true
    }
    
    //MARK: NSNotification
    
    /**
    Called when the app goes to the background e.g. from user pressing home button or opening the multi task switcher. The purpose is to disable the keyboard from being pushed beyond the window bounds, as keyboardWillShow is called twice in a row if the observer is not removed.
    - parameter notification:	The notification bound to this event.
    */
    func appGoesToBackground(notification: NSNotification) {
        print("app goes to background")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    //Keyboard hide/show based upon https://github.com/Lightstreamer/Lightstreamer-example-Chat-client-ios-swift with modifications
    func keyboardWillShow(notification: NSNotification) {
        print("\(__FUNCTION__) has been called")
        
        // Reducing size of table
        let baseView = self.view
        let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        let visibleRows = tableView!.indexPathsForVisibleRows
        var lastIndexPath : NSIndexPath? = nil
        
        if (visibleRows != nil) && visibleRows!.count > 0 {
            lastIndexPath = visibleRows![visibleRows!.count-1] as NSIndexPath
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height - keyboardFrame.height + self.kbOffset)
            }, completion: {
                (finished: Bool) in
                if lastIndexPath != nil {
                    // Scroll down the table so that the last
                    // visible row remains visible
                    self.tableView.scrollToRowAtIndexPath(lastIndexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("\(__FUNCTION__) has been called")
        
        // Expanding size of table
        let baseView = self.view
        let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height + keyboardFrame.height - self.kbOffset)
            
            }, completion: nil)
    }
}


















