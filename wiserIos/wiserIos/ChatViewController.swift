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
    var userName = "Peheje"
    var messages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.blueColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
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
        /*for i in 1...10 {
            let sender = (i%2 == 0) ? "Syncano" : self.userName
            let message = JSQMessage(senderId: sender, displayName: sender, text: "Text")
            self.messages += [message]
        }*/
        
        self.collectionView!.reloadData()
        self.senderDisplayName = self.userName
        self.senderId = self.userName
        
        
        HttpHandler.getChatMessages(roomId!) { (messages) -> Void in
            for m in messages {
                
                let date = DateTimeHelper.getDateFromEpochString(m.Timestamp)
                self.messages += [JSQMessage(senderId: m.ByUserId ?? self.userName, senderDisplayName: "StillNeedFetch", date: date, text: m.Value)]
            }
        }
        
        super.viewDidLoad()
    }
}
