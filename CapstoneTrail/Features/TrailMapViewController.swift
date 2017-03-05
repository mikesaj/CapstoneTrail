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
import CoreData


class TrailMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Interface builder properties
    @IBOutlet var trailMapView: MKMapView!

    // MARK: CoreLocation variables
    var locationManager: CLLocationManager!
    var locationAuthStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    // MARK: Current location variables
    var currentCoordinate: CLLocationCoordinate2D!
    var coordinateSpan: MKCoordinateSpan!
    let coordinateSpanValue: Double = 0.05
    var coordinateRegion: MKCoordinateRegion!
    // MARK: Trail Core Data variables
    var trailList: Array<NSManagedObject>!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var fetchRequest: NSFetchRequest<NSManagedObject>!

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


    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // Prepare for fetching trail data
        appDelegate = UIApplication.shared.delegate as! AppDelegate!
        managedContext = appDelegate.persistentContainer.viewContext
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trail")
        do {
            // Try to fetch
            trailList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            debugPrint("Could not fetch trail data. \(error), \(error.userInfo)")
        }
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


