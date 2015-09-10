//
//  RoomTableViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class RoomTableViewController: UITableViewController {
    
    //Properties
    var rooms = [Room]()
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var rooms = [Room]()
        HttpHandler.getRooms(
            {
                newRooms in
                NSLog("callback completed: ")
                
                self.rooms += self.filterRoomsByLocation(newRooms, metersRadius: 100)
                //self.rooms.sort({room1, room2 in }) //todo sort
                self.tableView.reloadData()
            }
        )
    }
    
    func filterRoomsByLocation(rooms: [Room], metersRadius: Double) -> [Room] {
        
        var filteredRooms = [Room]()
        
        let currentLong = CurrentUser.sharedInstance.location.Longitude
        let currentLat = CurrentUser.sharedInstance.location.Latitude
        let currentAccuracyMeters = Double(CurrentUser.sharedInstance.location.AccuracyMeters ?? 0)
        
        if let cLong = currentLong, cLat = currentLat {
            for room in rooms {
                if room.UseLocation {
                    if let rLong = room.Location.Longitude, rLat = room.Location.Latitude {
                        
                        //todo add room accuracy as well
                        let distance = distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong) + currentAccuracyMeters
                        if distance < metersRadius {
                            filteredRooms += [room]
                        }
                    }
                }
            }
        }
        
        return filteredRooms
    }
    
    //http://www.movable-type.co.uk/scripts/latlong.html
    func distanceBetweenTwoCoordinatesMeters(lat1: Double, _ long1: Double, _ lat2: Double, _ long2: Double) -> Double {
        let r = 6371000.0
        let dLat = degreesToRadians(lat2-lat1)
        let dLong = degreesToRadians(long2-long1)
        
        let a = sin(dLat/2)*sin(dLat/2) + cos(degreesToRadians(lat1))*cos(degreesToRadians(lat2)) * sin(dLong/2)*sin(dLong/2)
        let c = 2*atan2(sqrt(a), sqrt(1-a))
        let d = r*c
        return d
    }
    
    func degreesToRadians(degree: Double) -> Double {
        return (degree*M_PI)/180
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
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
        
        if let cLong = CurrentUser.sharedInstance.location.Longitude, cLat = CurrentUser.sharedInstance.location.Latitude, rLong = room.Location.Longitude, rLat = room.Location.Latitude {
            
            let distance = Int(distanceBetweenTwoCoordinatesMeters(cLat, cLong, rLat, rLong))
            cell.detailTextLabel?.text = "\(distance) meters away"
        }
        
        return cell
    }
    
    
    // Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SelectRoom" {
            if let selectedCell = sender as? UITableViewCell {
                NSLog(String(selectedCell))
                
                let roomViewController = segue.destinationViewController as! RoomPageViewController
                let index = tableView.indexPathForCell(selectedCell)!
                let selectedRoom = rooms[index.row]
                
                
                roomViewController.room = selectedRoom
            }
        }
    }
}