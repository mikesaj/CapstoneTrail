//
//  HistoryProfileViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-04-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import MapKit

class HistoryProfileViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapObj: MKMapView!
    @IBOutlet weak var trailName: UILabel!
    @IBOutlet weak var hikeDate: UILabel!

    let trailStreet = NSMutableArray()
    var trailData: [Trail] = []
    var currdate = ""
    
    
    
    
    
    var totalLength: Double = 0
    var totalTime: Double = 0
    
    //set current location
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var steps: [MKRouteStep]!
    var currentStep: Int! = 0
    var isInitialTrial: Bool! = true
    var trailPin: MKPointAnnotation!

    
    
    
    

    var coordinate2DList: [[CLLocationCoordinate2D]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        mapObj.delegate = self
        
        for trail in trailData {
            print("Trail id: \(trail.id)")
            print("Trail area: \(trail.area)")
            print("Trail street: \(trail.street)")
            trailStreet.add(trail.street)
            
            //totalLength += trail.length
            //totalTime += trail.travelTime
            coordinate2DList.append(trail.coordinate2DList)
        }

        trailName.text = String(describing: trailStreet[0])
        hikeDate.text = currdate
        
        // Center map to the trail
        centreToTrail()
        
        //  Create polyline with the CLLocationCoordinate2D list
        makePolyline()


        mapObj.selectAnnotation(mapObj.annotations[0], animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create polyline with the CLLocationCoordinate2D list
    func makePolyline() {
        
        for coordinate2Ds in coordinate2DList {
            // Create MKPolyline object from the specified set of coordinates
            let polyline: MKPolyline = MKPolyline(coordinates: coordinate2Ds, count: coordinate2Ds.count)
            // Add the polyline as single overlay object to the map
            mapObj.add(polyline)
        }
    }
    
    // Customise annotation
    @objc(mapView: viewForAnnotation:) func mapView(_ mapView: MKMapView,
                                                    viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        } else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "weatherAnnotation") ?? MKAnnotationView()
            
            annotationView.image = UIImage(named: "Flag")
            annotationView.canShowCallout = true
            
            return annotationView
        }
    }

    // MARK: MKMapViewDelegate
    // Ask the delegate for a renderer object to use when drawing the specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Initialize and return a new overlay view using the specified polyline overlay object
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Set stroke line colour
        polylineRenderer.strokeColor = UIColor.blue()
        // Set stroke line width
        polylineRenderer.lineWidth = 2
        
        return polylineRenderer
    }

    

    // Centre map to the trail
    func centreToTrail() {
        
        if self.trailPin != nil{
            mapObj.removeAnnotation(self.trailPin)
        }
        
        self.currentLocation = CLLocation(latitude: trailData[currentStep].coordinates[0][1], longitude: trailData[currentStep].coordinates[0][0])
        
        let regionRadius: CLLocationDistance = 800
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapObj.setRegion(coordinateRegion, animated: true)
        
        var pinLength: String = "%.0f m"
        if totalLength > 1000 {
            totalLength /= 1000
            pinLength = "%.1f km, "
        }
        var pinTime: String = "%.0f minutes"
        if totalTime > 60 {
            totalTime /= 60
            pinTime = "%.1f hours"
        }
        //let pinTitle: String = pinLength + ", " + pinTime
        
        // Make pin
        trailPin = MKPointAnnotation()
        trailPin.coordinate = trailData[currentStep].coordinate2DList[0]
        //trailPin.title = String(format: pinTitle, totalLength, totalTime)
        trailPin.subtitle = String(format: "Start @ %@", trailData[0].street)
        
        mapObj.addAnnotation(trailPin)
    }
        
    
}
