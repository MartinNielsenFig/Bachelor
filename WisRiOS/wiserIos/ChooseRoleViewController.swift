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
import FBSDKCoreKit
import FBSDKLoginKit

class ChooseRoleViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Properties
    @IBOutlet var mapView: MKMapView!
    var location = CLLocation()

    //Actions
    @IBAction func clickCreateRoomBtn(sender: AnyObject) {
        if CurrentUser.sharedInstance.FacebookId != nil {
            performSegueWithIdentifier("CreateRoom", sender: sender)
        }
        else {
            performSegueWithIdentifier("Login", sender: sender)
        }
    }
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        
        //Map delegation for pin behaviour
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        //Log off btn
        if CurrentUser.sharedInstance.FacebookId != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .Plain, target: self, action: "logOffFacebook")
        }
        
        super.viewDidAppear(animated)
    }
    
    //MKMapViewDelegate
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
    
    //CLLocationManagerDelegate
    let locationManager = CLLocationManager()
    var bestAccuracy = Double.init(Int.max)
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("didUpdateLocations")
        
        //locationManager.stopUpdatingLocation()

        if let location = manager.location {
            let currentAccuracy = location.horizontalAccuracy
            if currentAccuracy < bestAccuracy {
                
                //Save position to singleton
                self.location = location
                CurrentUser.sharedInstance.location.Latitude = location.coordinate.latitude
                CurrentUser.sharedInstance.location.Longitude = location.coordinate.longitude
                CurrentUser.sharedInstance.location.AccuracyMeters = Int(currentAccuracy)
                
                //Replace marker
                let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
                
                let circle = MKCircle(centerCoordinate: location.coordinate, radius: location.horizontalAccuracy as CLLocationDistance)
                mapView.addOverlay(circle)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                
                bestAccuracy = currentAccuracy
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating location \(error.localizedDescription)")
    }
    
    //Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateRoom" {
            //let createRoomViewController = segue.destinationViewController as! CreateRoomViewController
        }
        else if segue.identifier == "Login" {
            let loginRoomViewController = segue.destinationViewController as! LogonViewController
            loginRoomViewController.previousNavigationController = self.navigationController
            loginRoomViewController.previousViewController = self
        }
    }
    
    //Facebook
    func logOffFacebook() {
        
        //http://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        let alert = UIAlertController(title: "Confirm logout", message: "Confirm logging out", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            //Do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            FacebookHelper.logOff()
            self.navigationItem.rightBarButtonItem = nil
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
