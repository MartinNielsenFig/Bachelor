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

/// Shows the rooms nearby in a list, enabling the user to join the room.
class RoomTableViewController: UITableViewController {
    
    //MARK: Properties
    var rooms = [Room]()    //is the one being represented by the tableView
    var allRooms = [Room]()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Use Secret", comment: ""), style: .Plain, target: self, action: "useSecret")
        
        fetchRooms(refreshControl)
        super.viewDidLoad()
    }
    
    //MARK: UITableViewController
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if rooms.count > 0 {
        let roomAtRow = self.rooms[indexPath.row]
            return roomAtRow.CreatedById == CurrentUser.sharedInstance._id
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if rooms.count > 0 {
            let roomId = self.rooms[indexPath.row]._id
            HttpHandler.requestWithResponse(action: "Room/DeleteRoom?id=\(roomId!)", type: "DELETE", body: "") { (data, response, error) -> Void in
                if data.containsString("deleted") {
                    print("Did delete room")
                    let roomAtRow = self.rooms[indexPath.row]
                    
                    var indexInAllRooms = -1
                    for (index, room) in self.allRooms.enumerate() {
                        if room._id == roomAtRow._id {
                            indexInAllRooms = index
                        }
                    }
                    
                    assert(self.rooms[indexPath.row]._id == self.allRooms[indexInAllRooms]._id)
                    self.rooms.removeAtIndex(indexPath.row)
                    self.allRooms.removeAtIndex(indexInAllRooms)
                    
                    self.fetchRooms()
                } else {
                    print("Could not delete room")
                }
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
        
        //We're using a predefined one with subtitles, see in Storyboard
        let cellIdentifier = "SubtitleCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let room = self.rooms[indexPath.row]
        
        cell.textLabel?.text = room.Name
        
        if room._id == "system" {
            cell.detailTextLabel?.text = ""
        }
        else if let cLong = CurrentUser.sharedInstance.location.Longitude, cLat = CurrentUser.sharedInstance.location.Latitude, rLong = room.Location.Longitude, rLat = room.Location.Latitude {
            
            let distance = Int(RoomFilterHelper.distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong))
            cell.detailTextLabel?.text = String(format: NSLocalizedString("%d meters away", comment: ""), distance)
        }
        
        return cell
    }
    
    //MARK: UIRefreshControl
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchRooms(refreshControl)
    }
    
    //MARK: Utilities
    
    /**
    Removes current loaded rooms and loads new rooms from the database
    - parameter refreshControl:	A refreshcontrol
    */
    func fetchRooms(refreshControl: UIRefreshControl? = nil) {
        
        let start = NSDate()
        HttpHandler.requestWithResponse(action: "Room/GetAll", type: "GET", body: "") { (data, response, error) in
            
            var tmpRooms = [Room]()
            
            if let jsonArray = try? JSONSerializer.toArray(data) {
                for room in jsonArray {
                    tmpRooms += [Room(jsonDictionary: room as! NSDictionary)]
                }
            }
            
            self.rooms.removeAll()
            self.allRooms.removeAll()
            
            self.allRooms = tmpRooms
            self.rooms = RoomFilterHelper.filterRoomsByLocation(self.allRooms, metersRadius: 1000)
            refreshControl?.endRefreshing()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            print("duration of \(__FUNCTION__) took \(NSDate().timeIntervalSinceDate(start))")
        }
    }
    
    /**
     Function that runs when user chooses to use a secret to connect to a room
     */
    func useSecret() {
        var secretInput: UITextField?
        
        let alert = UIAlertController(title: NSLocalizedString("Connect with secret", comment: ""), message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Destructive, handler: { (action) -> Void in
            //Nothing
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Connect", comment: ""), style: .Default, handler: { action in
            
            //Find room with secret
            if let secret = secretInput?.text, foundRoom = (self.allRooms.filter(){ return $0.Secret == secret }).first {
                if self.shouldPerformSegueWithIdentifier("SelectRoom", sender: foundRoom) {
                    self.performSegueWithIdentifier("SelectRoom", sender: foundRoom)
                }
            }
            else {
                print("secret not found")
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
        
        if let room = selectedRoom, hasPw = room.HasPassword where hasPw {
            print("ROOM HAS PW")
            var pwTextField: UITextField?
            pwTextField?.secureTextEntry = true
            
            let alert = UIAlertController(title: NSLocalizedString("Enter password", comment: ""), message: NSLocalizedString("The room you selected is password protected. Enter the password for the room.", comment: ""), preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Destructive, handler: { (action) -> Void in
                //Nothing
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Connect", comment: ""), style: .Default, handler: { action in
                //Do some encryption here on user input
                if let pw = pwTextField!.text, roomEncryptedPw = room.EncryptedPassword where pw.sha512() == roomEncryptedPw {
                    print("CORRECT PASSWORD")
                    self.performSegueWithIdentifier("SelectRoom", sender: room)
                }
                else {
                    print("WRONG PASSWORD")
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