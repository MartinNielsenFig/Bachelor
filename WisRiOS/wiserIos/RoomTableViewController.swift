//
//  RoomTableViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Shows the rooms nearby in a list, enabling the user to join the room.
class RoomTableViewController: UITableViewController {
    
    //Properties
    
    //Gets set from ChooseRoleViewController
    var rooms = [Room]()
    
    //Lifecycle
    override func viewDidLoad() {
        
        rooms = RoomFilterHelper.filterRoomsByLocation(self.rooms, metersRadius: 1000)
        
        self.tableView.reloadData()
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
        
        let room = rooms[indexPath.row]
        
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
    
    
    //Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SelectRoom" {
            if let selectedCell = sender as? UITableViewCell {
                
                let roomViewController = segue.destinationViewController as! RoomPageViewController
                let index = tableView.indexPathForCell(selectedCell)!
                let selectedRoom = rooms[index.row]
                
                
                roomViewController.room = selectedRoom
            }
        }
    }
}