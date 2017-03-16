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

    var trailData = [Trail]()
    var epochDate: UInt32?
    var coordinate2DList: [CLLocationCoordinate2D]!

    override func viewDidLoad() {

        super.viewDidLoad()

        guard let epochDate = epochDate else {
            debugPrint("Schedule has no epoch date")
            scheduleDate.text = ""
            return
        }

        scheduleMap.mapType = .standard
        scheduleMap.delegate = self

        // Set schedule date/time
        scheduleDate.text = epochToDateString(epochDate)

        // Get CLLocationCoordinate2D list
        coordinate2DList = TrailUtils.makeCoordinate2D(coordinates: trailData[0].coordinates)
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
        let middlePosition = Int(roundf(Float(coordinate2DList.count) / Float(2)))
        let middleTrailCoordinate = coordinate2DList[middlePosition]
        let mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let mapRegion: MKCoordinateRegion = MKCoordinateRegionMake(middleTrailCoordinate, mapSpan)

        scheduleMap.setRegion(mapRegion, animated: true)

        let pinTitle = NSLocalizedString("Schedule_pin", comment: "Metre and minutes")
        let trailLength = trailData[0].length

        // Make pin
        let trailPin: MKPointAnnotation = MKPointAnnotation()
        trailPin.coordinate = middleTrailCoordinate
        trailPin.title = String(format: pinTitle, trailLength, TrailUtils.metre2minute(lengthIn: trailLength))
        trailPin.subtitle = trailData[0].street

        scheduleMap.addAnnotation(trailPin)
    }

    // Create polyline with the CLLocationCoordinate2D list
    func makePolyline() {

        // Create MKPolyline object from the specified set of coordinates
        let polyline: MKPolyline = MKPolyline(coordinates: coordinate2DList, count: coordinate2DList.count)
        // Add the polyline as single overlay object to the map
        scheduleMap.add(polyline)
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
