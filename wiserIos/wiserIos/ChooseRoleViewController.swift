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

class ChooseRoleViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Properties
    @IBOutlet var mapView: MKMapView!
    
    //Actions
    
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
        
        locationManager.stopUpdatingLocation()
        return pinView
    }
    
    //CLLocationManagerDelegate
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update location")
        
        if let location = manager.location {
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location \(error.localizedDescription)")
    }
    

}

