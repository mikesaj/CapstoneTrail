//
//  TrailMapViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 4..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import MapKit


class TrailMapViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet var trailMapView: MKMapView!

    // MARK: Variable
    var locationManager: CLLocationManager!

    override func viewDidLoad() {

        super.viewDidLoad()
        
        // Initialize location manager
        locationManager = CLLocationManager()
    }
}
