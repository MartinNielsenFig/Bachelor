//
//  ChatViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UITextFieldDelegate, Paged {
    
    //JSQMessagesViewController
    //Framework by jessesquires https://github.com/jessesquires/JSQMessagesViewController
    //Tutorial inspired by https://www.syncano.io/ios-chat-app-jsqmessagesviewcontroller/
    var userName = String()
    var messages = [JSQMessage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.collectionView!.reloadData()
            }
        }
    }
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 231/255, green: 231/255, blue: 233/255, alpha: 1.0))!
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0))!
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = self.messages[indexPath.row]
        if (data.senderId == self.senderId) {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    /*override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView!.textColor = UIColor.blackColor()
        return cell
    }*/
        
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let newJsqMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages += [newJsqMessage]
        
        let msg = ChatMessage()
        msg.ByUserId = CurrentUser.sharedInstance._id
        msg.RoomId = roomId
        //message timestamp gets created on restApi
        msg.Value = newJsqMessage.text
        
        HttpHandler.sendChatMessage(JSONSerializer.toJson(msg))

        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
    
    //Paged
    let pageIndex = 2
    var roomId: String?
    
    override func viewDidLoad() {
        
        self.userName = "iPhone"
        self.collectionView!.reloadData()
        self.senderDisplayName = self.userName
        self.senderId = self.userName
        
        HttpHandler.getChatMessages(roomId!) { (messages) -> Void in
            var tmpMessages = [JSQMessage]()
            for m in messages {
                let date = DateTimeHelper.getDateFromEpochString(m.Timestamp)
                tmpMessages += [JSQMessage(senderId: m.ByUserId ?? self.userName, senderDisplayName: "StillNeedFetch", date: date, text: m.Value)]
            }
            
            self.messages += tmpMessages
        }
        
        super.viewDidLoad()
    }
}
