//
//  CreateRoomViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 02/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import MapKit

class CreateRoomViewController: UITableViewController {
    
    //Properties
    var roomNameInputCell: TextInputCell? = nil
    var roomTagInputCell: TextInputCell? = nil
    var pwSwitchCell: BooleanInputCell? = nil
    var pwInputCell: TextInputCell? = nil
    var radiusInputCell: SegmentedInputCell? = nil
    var chatInputCell: BooleanInputCell? = nil
    var anonymousInputCell: BooleanInputCell? = nil
    var userQuestionInputCell: BooleanInputCell? = nil
    var roomUsesLocationInputCell: BooleanInputCell? = nil
    var pwLabel: UILabel? = nil
    
    var room = Room()
    
    //Get's initialized in prepareForSegue from Choose Role
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addRoomButtonPressed:")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
            pwSwitchCell?.uiSwitch.addTarget(self, action: "enablePwSwitchChanged:", forControlEvents: UIControlEvents.ValueChanged)
            
            return cell
        }
            
        else if indexPath.row == 3 {
            
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Password"
            cell.inputField.secureTextEntry = true
            
            pwLabel = cell.label
            pwInputCell = cell
            
            let on = (pwSwitchCell?.uiSwitch.on)!
            cell.inputField.enabled = on
            pwLabel?.enabled = on
            
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
        
        else if indexPath.row == 8 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = "Uses location"
            roomUsesLocationInputCell = cell
            return cell
        }
        
        return UITableViewCell()
    }
    
    //Handle selector events
    
    //Password switch
    func enablePwSwitchChanged(uiSwitch: UISwitch) {
        pwInputCell?.inputField.enabled = uiSwitch.on
        pwLabel?.enabled = uiSwitch.on
    }
    
    //Add room
    func addRoomButtonPressed(button: UIBarButtonItem) {        
        room.Name = roomNameInputCell?.inputField.text
        room.AllowAnonymous = (anonymousInputCell?.uiSwitch.on)!
        room.CreatedById = CurrentUser.sharedInstance._id
        room.HasChat = (chatInputCell?.uiSwitch.on)!
        room.HasPassword = (pwSwitchCell?.uiSwitch.on)!
        room.UseLocation = (roomUsesLocationInputCell?.uiSwitch.on)!
        room.Location.Latitude = CurrentUser.sharedInstance.location.Latitude
        room.Location.Longitude = CurrentUser.sharedInstance.location.Longitude
        room.Location.AccuracyMeters = CurrentUser.sharedInstance.location.AccuracyMeters ?? 20
        
        let seg = radiusInputCell?.segment
        let metersStr = seg?.titleForSegmentAtIndex((seg?.selectedSegmentIndex)!)
        if metersStr != nil {
            let meters = StringExtractor.highestNumberInString(metersStr!)
            room.Radius = meters
        }
        
        room.Tag = roomTagInputCell?.inputField.text
        room.UsersCanAsk = (userQuestionInputCell?.uiSwitch.on)!
        room.EncryptedPassword = pwInputCell?.inputField.text
        
        //Creating the room callback adds the id and navigates (todo loading bar or indicator)
        HttpHandler.createRoom(JSONSerializer.toJson(self.room)) { (roomId) -> Void in
            self.room._id = roomId
            
            //Navigate
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("RoomCreated", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RoomCreated" {
            let roomPageViewController = segue.destinationViewController as! RoomPageViewController
            roomPageViewController.room = self.room
            //assert(false)   //Fix yo shit dawg
        }
    }
}
