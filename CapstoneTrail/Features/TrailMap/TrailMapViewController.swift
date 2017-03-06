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
    var trail: Trail!
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

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedAction))
        trailMapView.addGestureRecognizer(tapGesture)
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
            let trailPolyline = TrailPolyline(coordinates: trail.coordinate2DList, count: trail.coordinate2DList.count)
            trailPolyline.trail = trail

            trailMapView.add(trailPolyline)
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
        // Set stroke line width
        polylineRenderer.lineWidth = 1.3

        // Set stroke line colour
        if overlay is TrailPolyline {
            var strokeColour: UIColor

            let trailPolyline = overlay as! TrailPolyline
            if let trail = trailPolyline.trail {
                let trailType: String = trail.pathType

                switch trailType {
                    case "DOMINIC CARDILLO TRAIL":
                        strokeColour = UIColor.red
                    case "IRON HORSE TRAIL":
                        strokeColour = UIColor.brown
                    case "WALTER BEAN GRAND RIVER TRAIL":
                        strokeColour = UIColor.magenta
                    case "WATERLOO SPURLINE TRAIL":
                        strokeColour = UIColor.cyan
                    case "TRANS-CANADA TRAIL":
                        strokeColour = UIColor.orange
                    default:
                        strokeColour = UIColor.blue()
                }
            } else {
                strokeColour = UIColor.blue()
            }

            polylineRenderer.strokeColor = strokeColour
        } else {
            polylineRenderer.strokeColor = UIColor.blue()
        }

        return polylineRenderer
    }
}
