//
//  CreateRoomViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 02/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import MapKit
import JsonSerializerSwift

/// Handles creation of a room with all its settings.
class CreateRoomViewController: UITableViewController {
    
    //Properties
    var roomNameInputCell: TextInputCell?
    var roomTagInputCell: TextInputCell?
    var pwSwitchCell: BooleanInputCell?
    var pwInputCell: TextInputCell?
    var radiusInputCell: SegmentedInputCell?
    var chatInputCell: BooleanInputCell?
    var anonymousInputCell: BooleanInputCell?
    var userQuestionInputCell: BooleanInputCell?
    var roomUsesLocationInputCell: BooleanInputCell?
    var pwLabel: UILabel?
    
    var room = Room()
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addRoomButtonPressed:")
    }
    
    //Tableview
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
    
    //Utilities
    func enablePwSwitchChanged(uiSwitch: UISwitch) {
        pwInputCell?.inputField.enabled = uiSwitch.on
        pwLabel?.enabled = uiSwitch.on
    }
    
    /**
    Method triggered by add room button. Fetches the data from the UI and instantiates the Room field. Then sends the room as JSON to the RestAPI which handles creation.
    - parameter button:	The button that initated the function call.
    */
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
        room.EncryptedPassword = pwInputCell?.inputField.text?.sha512()
        
        let jsonRoom = JSONSerializer.toJson(self.room)
        let body = "room=\(jsonRoom)"
        HttpHandler.requestWithResponse(action: "Room/CreateRoom", type: "POST", body: body) { (data, response, error) in
            if let error = try? ReturnMessage.parse(data) {
                print(error.ErrorMessage)
                
                if error.ErrorCode == ErrorCodes.RoomTagAlreadyInUse.rawValue {
                    print("TAG ALREADY IN USE")
                    
                    let alert = UIAlertController(title: "Tag in use", message: "Tag is already in use, choose another.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                        self.roomTagInputCell?.inputField.becomeFirstResponder()
                    }))
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                self.room._id = data
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("RoomCreated", sender: self)
                }
            }
        }
    }
    
    //Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RoomCreated" {
            let roomPageViewController = segue.destinationViewController as! RoomPageViewController
            roomPageViewController.room = self.room
            //assert(false)   //Fix yo shit dawg
        }
    }
}
