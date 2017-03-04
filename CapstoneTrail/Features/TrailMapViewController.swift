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

    override func viewDidLoad() {

        super.viewDidLoad()

        // Initialize location manager
        locationManager = CLLocationManager()

        // Initialize map delegate
        trailMapView.delegate = self

        // Request location authorization permission
        locationManager.requestWhenInUseAuthorization()
    }
}
