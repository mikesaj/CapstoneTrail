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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
