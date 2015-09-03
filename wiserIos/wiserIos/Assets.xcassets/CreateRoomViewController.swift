//
//  CreateRoomViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 02/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class CreateRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Properties
    var roomNameInputCell: TextInputCell? = nil
    var roomTagInputCell: TextInputCell? = nil
    var pwSwitchCell: BooleanInputCell? = nil
    var pwInputCell: TextInputCell? = nil
    var radiusInputCell: SegmentedInputCell? = nil
    var chatInputCell: BooleanInputCell? = nil
    var anonymousInputCell: BooleanInputCell? = nil
    var userQuestionInputCell: BooleanInputCell? = nil
    
    var room = Room()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addRoomButtonPressed:"))
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Room name"
            roomNameInputCell = cell
            return cell
        }
            
        else if indexPath.row == 1 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Room tag"
            roomTagInputCell = cell
            return cell
        }
        
        else if indexPath.row == 2 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            
            cell.label.text = "Enable password"
            pwSwitchCell = cell
            
            //Save as field and add a delegate function to this viewcontroller with name enablePwSwitchChanged
            pwSwitchCell?.uiSwitch.addTarget(self, action: Selector("enablePwSwitchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            
            return cell
        }
        
        else if indexPath.row == 3 {
            
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Password"
            cell.inputField.secureTextEntry = true
            
            pwInputCell = cell
            
            if let uiSwitch = pwSwitchCell?.uiSwitch {
                if !uiSwitch.on {
                    cell.inputField.enabled = false
                }
                else {
                    cell.inputField.enabled = true
                }
            }
            
            return cell
            
        }
            
        else if indexPath.row == 4 {
            let cellIdentifier = "SegmentedInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SegmentedInputCell
            cell.label.text = "Room radius"
            radiusInputCell = cell
            return cell

        }
            
        else if indexPath.row == 5 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable chat"
            chatInputCell = cell
            return cell
        }
        
        else if indexPath.row == 6 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable anonymous"
            anonymousInputCell = cell
            return cell
        }
        
        else if indexPath.row == 7 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Enable user questions"
            userQuestionInputCell = cell
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    //Handle selector events
    
    //Password switch
    func enablePwSwitchChanged(uiSwitch: UISwitch) {
        print("password switch pressed")
        pwInputCell?.inputField.enabled = uiSwitch.on
    }
    
    //Add room
    func addRoomButtonPressed(button: UIBarButtonItem) {
        print("add room button pressed")
        
        room.Name = roomNameInputCell?.inputField.text
        room.AllowAnonymous = (anonymousInputCell?.uiSwitch.on)!
        room.CreatedById = "id not implemented on iOS"
        room.HasChat = (chatInputCell?.uiSwitch.on)!
        room.HasPassword = (pwSwitchCell?.uiSwitch.on)!
        room.Location.Latitude = 1.0
        room.Location.Longitude = 1.0
        room.Location.AccuracyMeters = 1
        
        let seg = radiusInputCell?.segment
        let metersStr = seg?.titleForSegmentAtIndex((seg?.selectedSegmentIndex)!)
        if metersStr != nil {
            let meters = StringExtractor.highestNumberInString(metersStr!)
            room.Radius = meters
        }
        
        room.Tag = roomTagInputCell?.inputField.text
        room.UsersCanAsk = (userQuestionInputCell?.uiSwitch.on)!
        room.EncryptedPassword = pwInputCell?.inputField.text
        
        HttpHandler.createRoom(JSONSerializer.toJson(room))
    }
}
