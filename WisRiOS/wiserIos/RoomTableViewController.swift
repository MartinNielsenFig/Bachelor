//
//  RoomTableViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import CryptoSwift  //CryptoSwift https://github.com/krzyzanowskim/CryptoSwift all credits to krzyzanowskim

/// Shows the rooms nearby in a list, enabling the user to join the room.
class RoomTableViewController: UITableViewController {
    
    //Properties
    var rooms = [Room]()
    var allRooms = [Room]()
    
    //Lifecycle
    override func viewDidLoad() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Use Tag", style: .Plain, target: self, action: "useTag")
        
        fetchRooms(refreshControl)
        super.viewDidLoad()
    }
    
    //UITableViewController
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
            cell.detailTextLabel?.text = "\(distance) meters away"
        }
        
        return cell
    }
    
    //UIRefreshControl
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchRooms(refreshControl)
    }
    
    //Utilities
    func fetchRooms(refreshControl: UIRefreshControl? = nil) {
        
        let start = NSDate()
        HttpHandler.requestWithResponse(action: "Room/GetAll", type: "GET", body: "") { (data, response, error) -> Void in
            var tmpRooms = [Room]()
            
            if let data = data, jsonArray = try? JSONSerializer.toArray(data) {
                for room in jsonArray {
                    tmpRooms += [Room(jsonDictionary: room as! NSDictionary)]
                }
            }
            
            self.rooms.removeAll()
            self.allRooms.removeAll()
            self.allRooms = tmpRooms
            
            self.rooms = RoomFilterHelper.filterRoomsByLocation(self.allRooms, metersRadius: 1000)
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
            print("duration of \(__FUNCTION__) took \(NSDate().timeIntervalSinceDate(start))")
        }
    }
    
    /**
    Function that runs when user chooses to use a tag to connect to a room
    */
    func useTag() {
        var tagInput: UITextField?
        
        let alert = UIAlertController(title: "Connect with tag", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Connect", style: .Default, handler: { action in
            
            //Find room with tag
            if let tag = tagInput?.text, foundRoom = (self.allRooms.filter(){ return $0.Tag == tag }).first {
                if self.shouldPerformSegueWithIdentifier("SelectRoom", sender: foundRoom) {
                    self.performSegueWithIdentifier("SelectRoom", sender: foundRoom)
                }
            }
            else {
                print("tag not found")
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
            //Nothing
        }))
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            tagInput = textField
            textField.placeholder = "Enter room tag"
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var selectedRoom: Room?
        
        //Can either be called where sender is UITableViewCell (from storyboard) or where sender is the actual Room (programmatically)
        if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
            selectedRoom = rooms[indexPath.row]
        }
        else if let aRoom = sender as? Room {
            selectedRoom = aRoom
        }
        
        if let aRoom = selectedRoom, hasPw = aRoom.HasPassword where hasPw {
            print("ROOM HAS PW")
            var pwTextField: UITextField?
            
            let alert = UIAlertController(title: "Enter password", message: "The room you selected is password protected. Enter the password for the room.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Connect", style: .Default, handler: { action in
                
                //Do some encryption here on user input
                if let pw = pwTextField!.text, inputEncryptedPw = pw.sha512(), roomEncryptedPw = aRoom.EncryptedPassword where roomEncryptedPw == inputEncryptedPw {
                    print("CORRECT PASSWORD")
                    self.performSegueWithIdentifier("SelectRoom", sender: aRoom)
                }
                else {
                    print("WRONG PASSWORD")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
                //Nothing
            }))
            alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                pwTextField = textField
                textField.placeholder = "Enter room password"
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
            else if let selectedCell = sender as? UITableViewCell {
                let index = tableView.indexPathForCell(selectedCell)!
                selectedRoom = rooms[index.row]
            }
            let roomViewController = segue.destinationViewController as! RoomPageViewController
            roomViewController.room = selectedRoom
        }
    }
}