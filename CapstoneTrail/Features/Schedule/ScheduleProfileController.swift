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
import CoreLocation
import WatchConnectivity


class ScheduleProfileController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, WCSessionDelegate {

    // MARK: Properties
    @IBOutlet weak var scheduleDate: UILabel!
    //@IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var scheduleMap: MKMapView!
    @IBOutlet weak var indexIcon: UIImageView!
    @IBOutlet weak var indexMessage: UILabel!
    @IBOutlet weak var indexPoint: UILabel!
    @IBOutlet weak var imgDirection: UIImageView!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var btnStartWalking: UIButton!

    @IBOutlet weak var conditionText: UILabel!
    /*@IBOutlet weak var temperatureText: UILabel!
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
    @IBOutlet weak var humidityValue: UILabel!*/


    // MARK: Variables
    var watchSession : WCSession?
    
    var uid: String = ""
    var scheduleTitle: String = ""

    var currLat  = 0.0
    var currLong = 0.0

    
    var trailData: [Trail] = []
    var epochDate: UInt32?
    var coordinate2DList: [[CLLocationCoordinate2D]] = []

    var totalLength: Double = 0
    var totalTime: Double = 0

    //set current location
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var steps: [MKRouteStep]!
    var currentStep: Int! = 0
    var isInitialTrial: Bool! = true
    var trailPin: MKPointAnnotation!
    
    //to simulate that the user is walking
    var timer = Timer()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // get current location
        self.getLocation()

        if(WCSession.isSupported()){
            watchSession = WCSession.default()
            watchSession!.delegate = self
            watchSession!.activate()
        }
        
        guard let epochDate = epochDate else {
            debugPrint("Schedule has no epoch date")
            scheduleDate.text = ""
            return
        }
        
        scheduleMap.mapType = .standard
        scheduleMap.delegate = self
        
        //// Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        //// For use in foreground
        //self.locationManager.requestWhenInUseAuthorization()
        
        ////set current location
        /*if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }*/
        
        for trail in trailData {
            print(trail.id)
            totalLength += trail.length
            totalTime += trail.travelTime
            coordinate2DList.append(trail.coordinate2DList)
        }
        
        // Set schedule date/time
        scheduleDate.text = epochToDateString(epochDate)

        // Center map to the trail
        centreToTrail()
        
        //  Create polyline with the CLLocationCoordinate2D list
        makePolyline()

        scheduleMap.selectAnnotation(scheduleMap.annotations[0], animated: true)
        
        lblDistance.isHidden = true
        lblInstructions.isHidden = true
        imgDirection.isHidden = true
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("completed")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("completed")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("completed")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("completed")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //var userLocation:CLLocation = locations[0] as! CLLocation
        //let long = userLocation.coordinate.longitude;
        //let lat = userLocation.coordinate.latitude;
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

        if self.trailPin != nil{
            scheduleMap.removeAnnotation(self.trailPin)
        }
        
        self.currentLocation = CLLocation(latitude: trailData[currentStep].coordinates[0][1], longitude: trailData[currentStep].coordinates[0][0])
        
        let regionRadius: CLLocationDistance = 800
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        scheduleMap.setRegion(coordinateRegion, animated: true)

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
        trailPin = MKPointAnnotation()
        trailPin.coordinate = trailData[currentStep].coordinate2DList[0]
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
    
    
    /* MikeSaj Geo Implmentation: END */    

    // Compute current location and get the difference
    
    // instantiating the location manager
    //let locationManager = CLLocationManager()
    
    
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
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
    */
    
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
    
/* MikeSaj Geo Implmentation: END */    
    
    func calculateDirections(nextIndex: Int){
        
        let nextLocation = CLLocation(latitude: trailData[nextIndex].coordinates[0][1], longitude: trailData[nextIndex].coordinates[0][0])
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: nextLocation.coordinate.latitude, longitude: nextLocation.coordinate.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                
                //for step in route.steps {
                self.steps = route.steps
                
                if self.steps.count == 2{
                    self.displaySteps(distance: String(format: " Distance : %.2f m",self.steps[0].distance), instructions: self.steps[0].instructions)
                }
                else{
                    self.displaySteps(distance: String(format: " Distance : %.2f m", self.steps[1].distance), instructions: self.steps[1].instructions)
                }
            
                //}
                
            }
        }
    }
    
    func displaySteps(distance: String, instructions: String){
        self.lblInstructions.text = instructions
        self.lblDistance.text =  distance
        
        if instructions.contains("left") == true{
            self.imgDirection.image = UIImage(named: "left")
        }
        else if instructions.contains("right") == true {
            self.imgDirection.image = UIImage(named: "right")
        }
        else{
            self.imgDirection.image = UIImage(named: "straight")
            
            if self.isInitialTrial == false {
                self.lblDistance.text =  ""
            }
            else
            {
                self.isInitialTrial = false
                self.displayMessage(ttl: "Warning", msg: String(format: " you are at %.2f m away from your trail", distance))
            }
        }
    }
    
    func onTick(){
        
        centreToTrail()
            
        if self.currentStep < self.coordinate2DList.count - 2{
            self.calculateDirections(nextIndex: self.currentStep + 2)
        }
        
        self.currentStep = self.currentStep + 1
        
        if self.currentStep == self.coordinate2DList.count{
            self.lblDistance.text = ""
            self.lblInstructions.text =  "You arrived at your destination"
            btnStartWalking.setTitle("Start Walking", for: .normal)
            self.timer.invalidate()
        }
        
    }
    
    @IBAction func btnStartWalking_Click(_ sender: AnyObject) {
        
        self.currentStep = 0
        self.isInitialTrial = true
        self.centreToTrail()
        
        if btnStartWalking.currentTitle == "Start Walking" {
            lblDistance.isHidden = false
            lblInstructions.isHidden = false
            imgDirection.isHidden = false
        
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
                _ in self.onTick()
            }
        
            if self.currentStep < self.coordinate2DList.count - 2{
                self.calculateDirections(nextIndex: self.currentStep + 2)
            }
            else{
                self.calculateDirections(nextIndex: self.currentStep + 1)

            }
            
            self.currentStep = 1
        
            btnStartWalking.setTitle("Stop Walking", for: .normal)
        }
        else{
            lblDistance.isHidden = true
            lblInstructions.isHidden = true
            imgDirection.isHidden = true
            
            btnStartWalking.setTitle("Start Walking", for: .normal)
            self.timer.invalidate()
        }
    }
    
    /*func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    */
}
