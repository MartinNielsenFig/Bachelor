//
//  ChooseRoleViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import JsonSerializerSwift

/// This is the application start ViewController. Handles the user choices between joining a room or creating a room. Also handles the MapView which collects the user position in a singleton for the application to use, and shows the rooms nearby. This is also where the user can log out.
class ChooseRoleViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    
    /// A reference to the map on the UI
    @IBOutlet var mapView: MKMapView!
    /// The location of the user
    var location = CLLocation()
    /// The rooms that are represented on the map
    var rooms = [Room]()
    /// A boolean indicating whether it's the first time the rooms has loaded. To avoid centering map more than once on user location.
    var firstTimeRoomsLoaded = true
    /// Manages the fetching of the location etc. refer to Apple's documentation on CLLocationManager
    let locationManager = CLLocationManager()
        
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        
        //Map delegation for pin behaviour
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.startUpdatingLocation()
        addLoginLogoutButtons()
        super.viewDidAppear(animated)
    }
    
    //Actions
    /**
    Navigates to CreateRoom if logged in. Else navigate to Login screen.
    
    - parameter sender:	The button pressed
    */
    @IBAction func clickCreateRoomBtn(sender: AnyObject) {
        if CurrentUser.sharedInstance.FacebookId != nil {
            performSegueWithIdentifier("CreateRoom", sender: sender)
        } else {
            performSegueWithIdentifier("Login", sender: sender)
        }
        
    }
    
    //MARK: Utility
    
    /**
    Handles whehether the button should show "log in" or "log out" then renders that button.
    */
    func addLoginLogoutButtons() {
        if CurrentUser.sharedInstance.FacebookId != nil {
            let logoutTitle = NSLocalizedString("Log out", comment: "Log out button")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: logoutTitle, style: .Plain, target: self, action: "logOffFacebook")
        } else {
            let loginTitle = NSLocalizedString("Log in", comment: "Log in button")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: loginTitle, style: .Plain, target: self, action: "clickCreateRoomBtn:")
        }
    }
    
    /**
     Shows a UI Alert so user can confirm logging out of Facebook.
     */
    func logOffFacebook() {
        
        let confirmTitle = NSLocalizedString("Confirm Logout", comment: "Confirm logging out title")
        let confirmMessage = NSLocalizedString("Are you sure?", comment: "Question to confirm logging out message")
        let cancel = NSLocalizedString("Cancel", comment: "Cancel an action dismissing an alert")
        let logout = NSLocalizedString("Logout", comment: "Logout Button")
        
        //http://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        let alert = UIAlertController(title: confirmTitle, message: confirmMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: { action in
            //Do nothing
        }))
        
        alert.addAction(UIAlertAction(title: logout, style: .Default, handler: { action in
            FacebookHelper.logOff()
            self.addLoginLogoutButtons()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Loads all rooms from the WisR web api and filters them by user location. Then shows these rooms on the map as circles. See showRoomsOnMapAsCircles
     */
    func loadRoomsBasedOnLocation() {
        //Show nearby rooms
        HttpHandler.requestWithResponse(action: "Room/GetAll", type: "GET", body: "") {
            (notification, response, error) in
            
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                var tmpRooms = [Room]()
                
                //try? operator makes roomsJson nil if .toArray throws instead of do try catch-pattern
                if let data = notification.Data, jsonArray = try? JSONSerializer.toArray(data) {
                    for room in jsonArray {
                        tmpRooms += [Room(jsonDictionary: room as! NSDictionary)]
                    }
                    let filteredRooms = RoomFilterHelper.filterRoomsByLocation(tmpRooms, metersRadius: 5000)
                    if filteredRooms.count <= 0 {
                        let noRooms = Room()
                        noRooms._id = "system"
                        
                        let noRoomsNearby = NSLocalizedString("No rooms nearby", comment: "")
                        noRooms.Name = noRoomsNearby
                        tmpRooms = [noRooms]
                    } else {
                        tmpRooms = filteredRooms
                    }
                } else {
                    let errorRoom = Room()
                    let couldNotLoadRooms = NSLocalizedString("Could not load rooms", comment: "")
                    errorRoom.Name = couldNotLoadRooms
                    errorRoom._id = "system"
                    tmpRooms = [errorRoom]
                }
                
                self.rooms = tmpRooms
                self.showRoomsOnMapAsCircles()
                
            } else {
                print("error in getting rooms")
                print(notification.Errors)
            }
        }
    }
    
    /**
     Renders the rooms as circles on the map with the room radius + room location accuracy as the radius of the circle.
     */
    func showRoomsOnMapAsCircles() {
        
        /*if self.rooms.count > 100 {
            print("many rooms detected nearby, not drawing circles to conserve power")
            return
        }*/
        
        //Show on map
        self.mapView.removeOverlays(self.mapView.overlays)
        for room in self.rooms {
            if let lat = room.Location.Latitude, long = room.Location.Longitude {
                let roomPosition = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let circleRadius = (room.Location.AccuracyMeters ?? 0) + (room.Radius ?? 0)
                let circle = MKCircle(centerCoordinate: roomPosition, radius: CLLocationDistance(circleRadius))
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addOverlay(circle)
                }
            }
        }
    }
    
    //MARK: MKMapViewDelegate
    
    //http://stackoverflow.com/questions/24523702/stuck-on-using-mkpinannotationview-within-swift-and-mapkit/24532551#24532551
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.purpleColor()
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = .blueColor()
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKOverlayRenderer()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location {
            
            print("updated location")
            print(location.horizontalAccuracy)
            
            //Save position
            let currentAccuracy = location.horizontalAccuracy
            self.location = location
            CurrentUser.sharedInstance.location.Latitude = location.coordinate.latitude
            CurrentUser.sharedInstance.location.Longitude = location.coordinate.longitude
            CurrentUser.sharedInstance.location.AccuracyMeters = Int(currentAccuracy)
            
            //Replace and update overlays, annotations and positioning
            mapView.removeAnnotations(mapView.annotations)
            
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if firstTimeRoomsLoaded {
                mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
            }
            
            //Current location circle todo need fixing
            /*
            let circle = MKCircle(centerCoordinate: location.coordinate, radius: location.horizontalAccuracy as CLLocationDistance)
            mapView.addOverlay(circle)
            */
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
        //Get rooms first time to show on map
        if firstTimeRoomsLoaded {
            firstTimeRoomsLoaded = false
            loadRoomsBasedOnLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating location \(error.localizedDescription)")
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateRoom" {
            //let createRoomViewController = segue.destinationViewController as! CreateRoomViewController
        }
        else if segue.identifier == "Login" {
            let loginRoomViewController = segue.destinationViewController as! LogonViewController
            loginRoomViewController.previousNavigationController = self.navigationController
            loginRoomViewController.previousViewController = self
        }
        else if segue.identifier == "JoinRoom" {
            //let roomTableViewController = segue.destinationViewController as! RoomTableViewController
            //no need for initializing
        }
    }
}