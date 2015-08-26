//
//  ViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 26/08/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Location
    let locationManager = CLLocationManager()

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        }
        var pm = [CLPlacemark]()
        CLGeocoder().reverseGeocodeLocation(locations[0], completionHandler: {
            (placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
            if placemarks != nil {
                pm = placemarks as [CLPlacemark]!
            }
        })
        if pm.count <= 0 { return }
        print(pm[0].country)
        print(pm[0].postalCode)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location \(error.localizedDescription)")
    }
    

}

