//
//  RoomTableViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JsonSerializerSwift
import CryptoSwift  //CryptoSwift https://github.com/krzyzanowskim/CryptoSwift all credits to krzyzanowskim

/// Shows the rooms nearby in a list, enabling the user to join the room. Also enables the user to join a room by a secret.
class RoomTableViewController: UITableViewController {
    
    //MARK: Properties
    
    /// The rooms being represented by the tableView.
    var rooms = [Room]()
    /// All of the rooms on the system. Used because filtering of location is client side. Could be moved to WisR Web API. Loaded from previous ViewController
    var allRooms = [Room]()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        self.title = NSLocalizedString("Rooms nearby", comment: "")
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Use Secret", comment: ""), style: .Plain, target: self, action: "useSecret")
        
        fetchRooms(refreshControl)
        super.viewDidLoad()
    }
    
    //MARK: UITableViewController
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if rooms.count <= 0 {
            return false
        }
        let roomAtRow = self.rooms[indexPath.row]
        return roomAtRow.CreatedById == (CurrentUser.sharedInstance._id ?? "-1")
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if rooms.count <= 0 {
            return
        }
        let roomId = self.rooms[indexPath.row]._id
        HttpHandler.requestWithResponse(action: "Room/DeleteRoom?id=\(roomId!)", type: "DELETE", body: "") {
            (notification, response, error) -> Void in
            
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                print("Did delete room")
                self.fetchRooms()
            } else {
                print("Could not delete room")
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.rooms.count <= 0 {
            return UITableViewCell()
        }
        
        //We're using a predefined one with subtitles, see in Storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("SubtitleCell", forIndexPath: indexPath)
        
        let room = self.rooms[indexPath.row]
        
        cell.textLabel?.text = room.Name
        
        if room._id == "system" {
            cell.textLabel?.text = NSLocalizedString("No rooms nearby", comment: "")
            cell.detailTextLabel?.text = ""
        } else {
            cell.detailTextLabel?.text = ""
        }
        /*else if let cLong = CurrentUser.sharedInstance.location.Longitude, cLat = CurrentUser.sharedInstance.location.Latitude, rLong = room.Location.Longitude, rLat = room.Location.Latitude {
            let distance = Int(RoomFilterHelper.distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong))
            cell.detailTextLabel?.text = String(format: NSLocalizedString("%d meters away", comment: ""), distanceText)
        }*/
        
        return cell
    }
    
    //MARK: UIRefreshControl
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchRooms(refreshControl)
    }
    
    //MARK: Utilities
    
    /**
    Removes current loaded rooms both in self.rooms and self.allRooms and loads new rooms from the database.
    
    - parameter refreshControl:	An optional refreshcontrol indicating loading.
    */
    func fetchRooms(refreshControl: UIRefreshControl? = nil) {
        if let rc = refreshControl {
            rc.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -rc.frame.size.height), animated: true)
        }
        
        let start = NSDate()
        HttpHandler.requestWithResponse(action: "Room/GetAll", type: "GET", body: "") {
            (notification, response, error) in
            print("duration of \(__FUNCTION__) took \(NSDate().timeIntervalSinceDate(start))")

            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                var tmpRooms = [Room]()
                
                if let data = notification.Data, jsonArray = try? JSONSerializer.toArray(data) {
                    for room in jsonArray {
                        tmpRooms += [Room(jsonDictionary: room as! NSDictionary)]
                    }
                }
                
                self.rooms.removeAll()
                self.allRooms.removeAll()
                
                self.allRooms = tmpRooms
                self.rooms = RoomFilterHelper.filterRoomsByLocation(self.allRooms)
                
                if self.rooms.count <= 0 {
                    let noRooms = Room()
                    noRooms._id = "system"
                    noRooms.Name = NSLocalizedString("No rooms nearby", comment: "")
                    self.rooms += [noRooms]
                }
                
                refreshControl?.endRefreshing()
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                print("could not get all rooms")
                print(notification.Errors)
            }
        }
    }
    
    /**
     Enables the user to join by secret.
     */
    func useSecret() {
        var secretInput: UITextField?
        
        let alert = UIAlertController(title: NSLocalizedString("Connect with secret", comment: ""), message: NSLocalizedString("You can connect to any room in the world if you know the secret.", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {(action) -> Void in
            //Nothing
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Connect", comment: ""), style: .Default, handler: { action in
            
            //Find room with secret
            if let secret = secretInput?.text, foundRoom = (self.allRooms.filter(){ return $0.Secret == secret }).first {
                if self.shouldPerformSegueWithIdentifier("SelectRoom", sender: foundRoom) {
                    self.performSegueWithIdentifier("SelectRoom", sender: foundRoom)
                }
            } else {
                print("secret not found")
                Toast.showOkToast(NSLocalizedString("Secret doesn't exist", comment: ""), message: "", presenter: self)
            }
        }))
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            secretInput = textField
            textField.placeholder = NSLocalizedString("Enter room secret", comment: "")
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var selectedRoom: Room?
        
        //Can either be called where sender is UITableViewCell (from storyboard) or where sender is the actual Room (programmatically)
        if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
            selectedRoom = rooms[indexPath.row]
        }
        else if let room = sender as? Room {
            selectedRoom = room
        }
        
        //Check for system room
        if selectedRoom?._id == "system" {
            return false
        }
        
        //Check for anonymous user
        if let room = selectedRoom, allowAnon = room.AllowAnonymous where !allowAnon && CurrentUser.sharedInstance._id == nil {
            Toast.showOkToast(NSLocalizedString("No anonymous users", comment: ""), message: NSLocalizedString("Anonymous users are not allowed in this room. Please log in.", comment: ""), presenter: self)
            return false
        }
        
        //Check for password
        if let room = selectedRoom, hasPw = room.HasPassword where hasPw {
            print("ROOM HAS PW")
            var pwTextField: UITextField?
            pwTextField?.secureTextEntry = true
            
            let alert = UIAlertController(title: NSLocalizedString("Enter password", comment: ""), message: NSLocalizedString("The room you selected is password protected. Enter the password for the room.", comment: ""), preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { (action) -> Void in
                //Nothing
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Connect", comment: ""), style: .Default, handler: { action in
                if let pw = pwTextField!.text, roomEncryptedPw = room.EncryptedPassword where pw.sha512() == roomEncryptedPw {
                    print("CORRECT PASSWORD")
                    self.performSegueWithIdentifier("SelectRoom", sender: room)
                }
                else {
                    print("WRONG PASSWORD")
                    Toast.showToast(NSLocalizedString("Wrong password", comment: ""), durationMs: 2000, presenter: self, imageName: "Lock", callback: nil)
                }
            }))
            
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.secureTextEntry = true
                pwTextField = textField
                textField.placeholder = NSLocalizedString("Enter room password", comment: "")
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectRoom" {
            var selectedRoom: Room?
            
            if let foundRoom = sender as? Room {
                selectedRoom = foundRoom
            }
            else if let selectedCell = sender as? UITableViewCell, index = tableView.indexPathForCell(selectedCell) {
                selectedRoom = rooms[index.row]
            }
            let roomViewController = segue.destinationViewController as! RoomPageViewController
            roomViewController.room = selectedRoom
        }
    }
}