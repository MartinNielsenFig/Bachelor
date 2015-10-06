//
//  RoomTableViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Shows the rooms nearby in a list, enabling the user to join the room.
class RoomTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    //Properties
    var rooms = [Room]()
    
    //Lifecycle
    override func viewDidLoad() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
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
            self.rooms += tmpRooms
            
            self.rooms = RoomFilterHelper.filterRoomsByLocation(self.rooms, metersRadius: 1000)
            refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
            print("duration of \(__FUNCTION__) took \(NSDate().timeIntervalSinceDate(start))")
        }
    }
    
    //Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
                let selectedRoom = rooms[indexPath.row]
                if let hasPw = selectedRoom.HasPassword where hasPw {
                    print("ROOM HAS PW")
                    
                    //Many quarrels much fight
                    //https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPopoverPresentationController_class/
                    //http://stackoverflow.com/questions/25319179/uipopoverpresentationcontroller-on-ios-8-iphone
                    let roomPwViewController: UIViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("InputRoomPassword")
                    roomPwViewController.modalPresentationStyle = .FormSheet
                    roomPwViewController.presentationController?.delegate = self
                    self.presentViewController(roomPwViewController, animated: true, completion: nil)
                    roomPwViewController.view.backgroundColor = UIColor.redColor()
                    
                    return false
                }
            }
        
        
        print("FREE ACCESSS")
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SelectRoom" {
            if let selectedCell = sender as? UITableViewCell {
                
                let index = tableView.indexPathForCell(selectedCell)!
                let selectedRoom = rooms[index.row]
                
                let roomViewController = segue.destinationViewController as! RoomPageViewController
                roomViewController.room = selectedRoom
            }
        }
    }
}