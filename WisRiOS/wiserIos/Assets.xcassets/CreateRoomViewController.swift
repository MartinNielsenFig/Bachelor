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
    
    //MARK: Properties
    
    /// Reference to inputcell
    var roomNameInputCell: TextInputCell?
    /// Reference to inputcell
    var roomSecretInputCell: TextInputCell?
    /// Reference to inputcell
    var pwSwitchCell: BooleanInputCell?
    /// Reference to inputcell
    var pwInputCell: TextInputCell?
    /// Reference to inputcell
    var radiusInputCell: SegmentedInputCell?
    /// Reference to inputcell
    var chatInputCell: BooleanInputCell?
    /// Reference to inputcell
    var anonymousInputCell: BooleanInputCell?
    /// Reference to inputcell
    var userQuestionInputCell: BooleanInputCell?
    /// Reference to inputcell
    var roomUsesLocationInputCell: BooleanInputCell?
    /// Reference to password label
    var pwLabel: UILabel?
    
    /// Room being created by this ViewController
    var room = Room()
    
    /// The default state for boolean input cells (Switches)
    let onDefault = true
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addRoomBtn:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        
    }
    
    //MARK: Tableview
    
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
            
            cell.label.text = NSLocalizedString("Name", comment: "")
            cell.inputField.placeholder = NSLocalizedString("Name of the room", comment: "")
            roomNameInputCell = cell
            return cell
        }
        else if indexPath.row == 1 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            
            cell.inputField.autocapitalizationType = .None
            cell.inputField.autocorrectionType = .No
            cell.label.text = NSLocalizedString("Secret", comment: "")
            cell.inputField.placeholder = NSLocalizedString("Let others join with secret", comment: "")
            roomSecretInputCell = cell
            return cell
        }
        else if indexPath.row == 2 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            
            cell.label.text = NSLocalizedString("Enable password", comment: "")
            cell.uiSwitch.on = false
            pwSwitchCell = cell
            
            //Save as field and add a delegate function to this viewcontroller with name enablePwSwitchChanged
            pwSwitchCell?.uiSwitch.addTarget(self, action: "enablePwSwitchChanged:", forControlEvents: UIControlEvents.ValueChanged)
            
            return cell
        }
        else if indexPath.row == 3 {
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = NSLocalizedString("Password", comment: "")
            cell.inputField.placeholder = NSLocalizedString("Optional password for room", comment: "")
            cell.inputField.secureTextEntry = true
            
            pwLabel = cell.label
            pwInputCell = cell
            
            let on = pwSwitchCell?.uiSwitch.on ?? onDefault
            cell.inputField.enabled = on
            pwLabel?.enabled = on
            
            return cell
            
        }
            
        else if indexPath.row == 4 {
            let cellIdentifier = "SegmentedInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SegmentedInputCell
            cell.label.text = NSLocalizedString("Room radius", comment: "")
            radiusInputCell = cell
            return cell
            
        }
            
        else if indexPath.row == 5 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = NSLocalizedString("Enable chat", comment: "")
            chatInputCell = cell
            return cell
        }
            
        else if indexPath.row == 6 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = NSLocalizedString("Enable anonymous", comment: "")
            anonymousInputCell = cell
            return cell
        }
            
        else if indexPath.row == 7 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = NSLocalizedString("Enable user questions", comment: "")
            userQuestionInputCell = cell
            return cell
        }
            
        else if indexPath.row == 8 {
            let cellIdentifier = "BooleanInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BooleanInputCell
            cell.label.text = NSLocalizedString("Use location", comment: "")
            roomUsesLocationInputCell = cell
            return cell
        }
        
        return UITableViewCell()
    }
    
    //MARK: Utilities
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Enables or disables the password input field based upon the UISwitchs tate
     
     - parameter uiSwitch:	The UI Switch
     */
    func enablePwSwitchChanged(uiSwitch: UISwitch) {
        pwInputCell?.inputField.enabled = uiSwitch.on
        pwLabel?.enabled = uiSwitch.on
    }
    
    /**
     Method triggered by add room button. Fetches the data from the UI and instantiates the Room field. Then sends the room as JSON to the WisRApi which handles creation.
     
     - parameter button:	The button that initated the function call.
     */
    func addRoomBtn(button: UIBarButtonItem) {
        
        //Check user inputs
        var msg = ""
        var missingInformation = false
        if let name = roomNameInputCell?.inputField.text where name == "" {
            missingInformation = true
            msg += NSLocalizedString("Room name cannot be empty. ", comment: "")

        }
        if let secret = roomSecretInputCell?.inputField.text where secret == "" {
            missingInformation = true
            msg += NSLocalizedString("Room secret cannot be empty. ", comment: "")
        }
        if CurrentUser.sharedInstance._id == nil {
            missingInformation = true
            msg += NSLocalizedString("You must be logged in to add a room. ", comment: "")
        }
        if let usesLocation = roomUsesLocationInputCell?.uiSwitch where (CurrentUser.sharedInstance.location.Latitude == nil || CurrentUser.sharedInstance.location.Longitude == nil) && usesLocation.on {
            missingInformation = true
            msg += NSLocalizedString("Your room is location enabled, but the app couldn't get your position. ", comment: "")
        }
        
        if missingInformation == true {
            let alert = UIAlertController(title: NSLocalizedString("Empty values", comment: ""), message: msg, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { action in
                self.roomSecretInputCell?.inputField.becomeFirstResponder()
            }))
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        
        room.Name = roomNameInputCell?.inputField.text
        room.AllowAnonymous = anonymousInputCell?.uiSwitch.on ?? onDefault
        room.CreatedById = CurrentUser.sharedInstance._id!
        room.HasChat = chatInputCell?.uiSwitch.on ?? onDefault
        room.HasPassword = pwSwitchCell?.uiSwitch.on ?? onDefault
        room.UseLocation = roomUsesLocationInputCell?.uiSwitch.on ?? onDefault
        room.Location.Latitude = CurrentUser.sharedInstance.location.Latitude
        room.Location.Longitude = CurrentUser.sharedInstance.location.Longitude
        room.Location.AccuracyMeters = CurrentUser.sharedInstance.location.AccuracyMeters ?? 20
        
        let seg = radiusInputCell?.segment
        let metersStr = seg?.titleForSegmentAtIndex(seg!.selectedSegmentIndex) ?? "20"
        let meters = StringExtractor.highestNumberInString(metersStr)
        room.Radius = meters
        
        room.Secret = roomSecretInputCell?.inputField.text
        room.UsersCanAsk = userQuestionInputCell?.uiSwitch.on ?? onDefault
        room.EncryptedPassword = pwInputCell?.inputField.text?.sha512()
        
        let jsonRoom = JSONSerializer.toJson(self.room)
        let body = "room=\(jsonRoom)"
        HttpHandler.requestWithResponse(action: "Room/CreateRoom", type: "POST", body: body) {
            (notification, response, error) in
            
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                
                if let data = notification.Data {
                    self.room._id = data
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("RoomCreated", sender: self)
                    }
                } else {
                    print("did not receive ID for the created room")
                }
            } else if notification.Errors.contains(ErrorCode.RoomSecretAlreadyInUse) {
                
                print("secret already in use")
                let alert = UIAlertController(title: NSLocalizedString("Secret in use", comment: ""), message: NSLocalizedString("Secret is already in use, choose another.", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                    self.roomSecretInputCell?.inputField.becomeFirstResponder()
                }))
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                
                print("error in creating room")
                print(notification.Errors)
            }
        }
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RoomCreated" {
            let roomPageViewController = segue.destinationViewController as! RoomPageViewController
            roomPageViewController.room = self.room
        }
    }
}
