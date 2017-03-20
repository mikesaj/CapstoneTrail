//
//  ScheduleProfileController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit


class ScheduleProfileController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    @IBOutlet weak var scheduleDate: UILabel!
    @IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var scheduleMap: MKMapView!
    @IBOutlet weak var indexIcon: UIImageView!
    @IBOutlet weak var indexMessage: UILabel!
    @IBOutlet weak var indexPoint: UILabel!

    @IBOutlet weak var conditionText: UILabel!
    @IBOutlet weak var temperatureText: UILabel!
    @IBOutlet weak var temperatureValue: UILabel!
    @IBOutlet weak var feelsLikeText: UILabel!
    @IBOutlet weak var feelsLikeValue: UILabel!
    @IBOutlet weak var windText: UILabel!
    @IBOutlet weak var windValue: UILabel!
    @IBOutlet weak var cloudText: UILabel!
    @IBOutlet weak var cloudValue: UILabel!
    @IBOutlet weak var precipitationText: UILabel!
    @IBOutlet weak var precipitationValue: UILabel!
    @IBOutlet weak var humidityText: UILabel!
    @IBOutlet weak var humidityValue: UILabel!


    // MARK: Variables
    var uid: String = ""
    var scheduleTitle: String = ""

    var trailData: [Trail] = []
    var epochDate: UInt32?
    var coordinate2DList: [[CLLocationCoordinate2D]] = []

    var totalLength: Double = 0
    var totalTime: Double = 0

    override func viewDidLoad() {

        super.viewDidLoad()

        guard let epochDate = epochDate else {
            debugPrint("Schedule has no epoch date")
            scheduleDate.text = ""
            return
        }

        scheduleMap.mapType = .standard
        scheduleMap.delegate = self

        for trail in trailData {
            totalLength += trail.length
            totalTime += trail.travelTime
            coordinate2DList.append(trail.coordinate2DList)
        }

        print("totalLength", totalLength)
        print("totalTime", totalTime)

        // Set schedule date/time
        scheduleDate.text = epochToDateString(epochDate)

        // Center map to the trail
        centreToTrail()
        //  Create polyline with the CLLocationCoordinate2D list
        makePolyline()

        scheduleMap.selectAnnotation(scheduleMap.annotations[0], animated: true)
    }


    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
    }


    // Make human readable date string from epoch time
    func epochToDateString(_ epochDate: UInt32) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none

        let dateTime = Date(timeIntervalSince1970: TimeInterval(epochDate))

        return dateFormatter.string(from: dateTime)
    }


    func epochToTimeString(_ epochDate: UInt32) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .full

        let dateTime = Date(timeIntervalSince1970: TimeInterval(epochDate))

        return dateFormatter.string(from: dateTime)
    }

    // Centre map to the trail
    func centreToTrail() {

        // Get middle position of the coordinate list
        let middlePosition = Int(roundf(Float(coordinate2DList[0].count) / Float(2)))
        let middleTrailCoordinate = coordinate2DList[0][middlePosition]
        let mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.005, 0.005)
        let mapRegion: MKCoordinateRegion = MKCoordinateRegionMake(middleTrailCoordinate, mapSpan)

        scheduleMap.setRegion(mapRegion, animated: true)

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
        let pinTitle: String = pinLength + ", " + pinTime

        // Make pin
        let trailPin: MKPointAnnotation = MKPointAnnotation()
        trailPin.coordinate = middleTrailCoordinate
        trailPin.title = String(format: pinTitle, totalLength, totalTime)
        trailPin.subtitle = String(format: "Start @ %@", trailData[0].street)

        scheduleMap.addAnnotation(trailPin)
    }

    // Create polyline with the CLLocationCoordinate2D list
    func makePolyline() {

        for coordinate2Ds in coordinate2DList {
            // Create MKPolyline object from the specified set of coordinates
            let polyline: MKPolyline = MKPolyline(coordinates: coordinate2Ds, count: coordinate2Ds.count)
            // Add the polyline as single overlay object to the map
            scheduleMap.add(polyline)
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
}
