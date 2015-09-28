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
    var rooms = [Room]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loading = Room()
        loading.Name = "Loading rooms..."
        loading._id = "system"
        rooms += [loading]
        
        HttpHandler.requestWithResponse(action: "Room/GetAll", type: "GET", body: "") { (data, response, error) -> Void in
            var rooms = [Room]()
            
            //try? operator makes roomsJson nil if .toArray throws instead of do try catch-pattern
            if let data = data, jsonArray = try? JSONSerializer.toArray(data) {
                for room in jsonArray {
                    rooms += [Room(jsonDictionary: room as! NSDictionary)]
                }
                let filteredRooms = self.filterRoomsByLocation(rooms, metersRadius: 1000)
                if filteredRooms.count <= 0 {
                    let noRooms = Room()
                    noRooms._id = "system"
                    noRooms.Name = "No nearby rooms"
                    self.rooms = [noRooms]
                }
                else {
                    self.rooms = filteredRooms
                }
            } else {
                let errorRoom = Room()
                errorRoom.Name = "Could not load rooms"
                errorRoom._id = "system"
                self.rooms = [errorRoom]
            }
        }
    }
    
    //Utility
    
    /**
    Returns a new array of Room containing only the rooms that are within a specified radius of the current user that is logged on. Required that CurrentUser.sharedInstance.location is set.
    - parameter rooms:				An array of Room to be filtered.
    - parameter metersRadius:	The radius in which the room has to be in proximity to the user. Adds the accuracy of the room location and user location to this.
    - returns: Array of filtered rooms.
    */
    func filterRoomsByLocation(rooms: [Room], metersRadius: Double) -> [Room] {
        
        var filteredRooms = [Room]()
        
        let currentLong = CurrentUser.sharedInstance.location.Longitude
        let currentLat = CurrentUser.sharedInstance.location.Latitude
        let currentAccuracyMeters = Double(CurrentUser.sharedInstance.location.AccuracyMeters ?? 0)
        
        if let cLong = currentLong, cLat = currentLat {
            for room in rooms {
                if let useLocation = room.UseLocation where useLocation == true {
                    if let rLong = room.Location.Longitude, rLat = room.Location.Latitude {
                        
                        let roomAccuracy = Double(room.Location.AccuracyMeters ?? 0)
                        let distance = distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong) + currentAccuracyMeters + roomAccuracy
                        if distance < metersRadius {
                            filteredRooms += [room]
                        }
                    }
                }
            }
        }
        
        return filteredRooms
    }
    
    //
    
    /**
    Calculation based upon http://www.movable-type.co.uk/scripts/latlong.html Calculates the distance between to latitude-longitude pairs.
    - parameter lat1:	latitude of the first coordinate
    - parameter long1:	longitude of the first coordinate
    - parameter lat2:	latitude of the second coordinate
    - parameter long2:	longitude of the second coordinate
    - returns: Distance between the two coordinates
    */
    func distanceBetweenTwoCoordinatesMeters(lat1: Double, _ long1: Double, _ lat2: Double, _ long2: Double) -> Double {
        let r = 6371000.0
        let dLat = degreesToRadians(lat2-lat1)
        let dLong = degreesToRadians(long2-long1)
        
        let a = sin(dLat/2)*sin(dLat/2) + cos(degreesToRadians(lat1))*cos(degreesToRadians(lat2)) * sin(dLong/2)*sin(dLong/2)
        let c = 2*atan2(sqrt(a), sqrt(1-a))
        let d = r*c
        return d
    }
    
    /**
    Converts degrees to radians.
    - parameter degree:	Angle in degree
    - returns: Angle in radians
    */
    func degreesToRadians(degree: Double) -> Double {
        return (degree*M_PI)/180
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
            
            let distance = Int(distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong))
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