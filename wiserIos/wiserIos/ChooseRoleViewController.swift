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
    
    //Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Map delegation for pin behaviour
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Log off btn
        if CurrentUser.sharedInstance.FacebookId != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "logOffFacebook")
            //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "logOffFacebook")
        }
        
        
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            circle.strokeColor = UIColor.blueColor()
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKOverlayRenderer()
        }
    }
    
    //CLLocationManagerDelegate
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("did update location")
        
        if let location = manager.location {
            self.location = location
            
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            
            let circle = MKCircle(centerCoordinate: location.coordinate, radius: location.horizontalAccuracy as CLLocationDistance)
            self.mapView.addOverlay(circle)
            
            NSLog(String(location.horizontalAccuracy))
            NSLog(String(location.verticalAccuracy))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            //Save to singleton
            CurrentUser.sharedInstance.location.Latitude = location.coordinate.latitude
            CurrentUser.sharedInstance.location.Longitude = location.coordinate.longitude
            let meters = sqrt(pow((location.horizontalAccuracy), 2) + pow((location.verticalAccuracy), 2))
            CurrentUser.sharedInstance.location.AccuracyMeters = Int(meters)
            
            locationManager.stopUpdatingLocation()
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Error while updating location \(error.localizedDescription)")
    }
    
    //Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateRoom" {
            let createRoomViewController = segue.destinationViewController as! CreateRoomViewController
            createRoomViewController.userLocation = location
        }
        else if segue.identifier == "Login" {
            let loginRoomViewController = segue.destinationViewController as! LoginViewController
            loginRoomViewController.previousNavigationController = self.navigationController
        }
    }
    
    //Facebook
    func logOffFacebook() {
        FacebookHelper.logOff()
        self.navigationItem.rightBarButtonItem = nil
    }
}

