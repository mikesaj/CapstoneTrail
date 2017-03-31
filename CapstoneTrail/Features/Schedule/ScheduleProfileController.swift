//
//  ScheduleProfileController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit


class ScheduleProfileController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

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

    var currLat  = 0.0
    var currLong = 0.0

    
    var trailData: [Trail] = []
    var epochDate: UInt32?
    var coordinate2DList: [[CLLocationCoordinate2D]] = []

    var totalLength: Double = 0
    var totalTime: Double = 0

    override func viewDidLoad() {

        super.viewDidLoad()
        
        // get current location
        self.getLocation()
        
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

    @IBAction func startWalking(_ sender: UIButton) {
        
        // DEMO GPS DATA AT THE MOMENT
        //let distanceDiff = self.getDistanceDiff(lat1: 50.0, lon1: 5.0, lat2: 5.0, lon2: 3.0)
        //43.397361, -80.408792 // pioneer park area
        
        
        print(" trail data \(trailData)")

        
        
        let distanceDiff = self.getDistanceDiff(lat1: 43.394750, lon1: -80.418158, lat2: 43.397361, lon2: -80.408792)
        
        if(distanceDiff <= 30)// 30 meter difference
        {
            // under 1 mile
            print(distanceDiff)
        }
        else
        {
            // out of 1 mile
            print("You are \(distanceDiff)m away from trail's starting point")
            
            displayMessage(ttl: "Notice", msg: "You are \(distanceDiff)m away from trail's starting point \n Please walk to the starting point of the Trail")
            return
        }
        
        
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
    
    // Distance between geo-locations and return result in meters
    func getDistanceDiff(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Int {
        
        // get current location
        getLocation()
        
        let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        
        print(distanceInMeters)
        
        return Int(distanceInMeters)
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
    
    
    // Compute current location and get the difference
    
    // instantiating the location manager
    let locationManager = CLLocationManager()
    
    
    // get co-ordinates and location from location manager
    // Also checks for user's location permissions
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayMessage(ttl: "Location Error", msg: "Location services are disabled on your device. In order to use this app, go to " +
                "Settings → Privacy → Location Services and turn location services on.")
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                displayMessage(ttl: "Location Error", msg: "This app is not authorized to access your location. \nIn order to use this app, " +
                    "go to Settings → HikeTrails → Location and select the \"While Using " +
                    "the App\" setting.")
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                //getLocation()
                break
                
            default:
                print("Oops! Shouldn't have come this far.")
            }
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    // This is called if:
    // - the location manager is updating, and
    // - it was able to get the user's location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        
        let newLocation = locations.last!
        
        let currLocation = newLocation.coordinate
        
        self.currLat  = Double(currLocation.latitude)
        self.currLong = Double(currLocation.longitude)
        
        print( "Location: Lat\(currLat) lon\(currLong)")
        //print(currLocation)
        
    }
    
    // This is called if:
    // - the location manager is updating, and
    // - it WASN'T able to get the user's location.
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error)")
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            //let city   = placemark.locality ?? ""
            //let region = placemark.administrativeArea ?? ""
            
            //locationLabel.text = city + ", " + region
            
            print(placemark.locality ?? "")
            print(placemark.administrativeArea ?? "")
            print(placemark.country ?? "")
        }
    }
    
    
    
    
    

}
