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
    var coreDataTrailList: Array<NSManagedObject>!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var fetchRequest: NSFetchRequest<NSManagedObject>!
    // MARK: Trail routes variables
    var trails: Array<Trail> = []
    var trailPolyline: Array<MKPolyline> = [MKPolyline()]

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
            coreDataTrailList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            debugPrint("Could not fetch trail data. \(error), \(error.userInfo)")
        }

        // Create trail objects from Core Data
        for coreDataTrail in coreDataTrailList {
            let trail = Trail(trail: coreDataTrail)
            trails.append(trail)
        }

        // Add polyline on the map
        for trail in trails {
            trailMapView.add(trail.routePolyline)
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

    // MARK: MKMapViewDelegate
    // Ask the delegate for a renderer object to use when drawing the specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        // Initialize and return a new overlay view using the specified polyline overlay object
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Set stroke line colour
        polylineRenderer.strokeColor = UIColor.blue()
        // Set stroke line width
        polylineRenderer.lineWidth = 1

        return polylineRenderer
    }
}


