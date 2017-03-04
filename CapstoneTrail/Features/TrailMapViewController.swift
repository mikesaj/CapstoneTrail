//
//  TrailMapViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 4..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class TrailMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    @IBOutlet var trailMapView: MKMapView!

    // MARK: Variable
    var locationManager: CLLocationManager!
    var locationAuthStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    var currentCoordinate: CLLocationCoordinate2D!
    var coordinateSpan: MKCoordinateSpan!
    let coordinateSpanValue: Double = 0.05
    var coordinateRegion: MKCoordinateRegion!

    override func viewDidLoad() {

        super.viewDidLoad()

        // Initialize location manager
        locationManager = CLLocationManager()

        // Initialize map delegate
        trailMapView.delegate = self

        // Request location authorization permission
        locationManager.requestWhenInUseAuthorization()

        // Show user location
        trailMapView.showsUserLocation = true

        // Get current location coordinate
        makeLocationRegion()
    }

    // Get current location coordinate
    func makeLocationRegion() {

        guard let currentLocation = locationManager.location else {
            debugPrint("Cannot fetch current location")
            return
        }

        currentCoordinate = currentLocation.coordinate
        coordinateSpan = MKCoordinateSpan(latitudeDelta: coordinateSpanValue, longitudeDelta: coordinateSpanValue)
        coordinateRegion = MKCoordinateRegion(center: currentCoordinate, span: coordinateSpan)

        trailMapView.setRegion(coordinateRegion, animated: true)
    }
}


