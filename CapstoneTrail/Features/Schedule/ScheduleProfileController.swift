//
//  ScheduleProfileController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import SwiftyJSON
import MapKit
import CoreLocation
import WatchConnectivity


class ScheduleProfileController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, WCSessionDelegate {

    // MARK: Properties
    @IBOutlet weak var scheduleDate: UILabel!
    //@IBOutlet weak var scheduleTime: UILabel!
    @IBOutlet weak var scheduleMap: MKMapView!
    //@IBOutlet weak var indexIcon: UIImageView!
    @IBOutlet weak var trailStreetName: UILabel!
    @IBOutlet weak var indexMessage: UILabel!
    @IBOutlet weak var indexPoint: UILabel!
    @IBOutlet weak var imgDirection: UIImageView!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    @IBOutlet weak var btnStartWalking: UIButton!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var conditionText: UILabel!
    
    // Start/Stop Button
    let stopColor  = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)

    //MARK: - HealthKit class to save data
    var userHealthData = ActivityViewController()
    
    // Pedometer instance
    var pedometer = CMPedometer()
    
    // timers
    var timer         = Timer()
    var timer1        = Timer()
    let timerInterval = 1.0
    var timeElapsed:TimeInterval = 0.0
    var TempSteps:  Int = 0

    var Steps1:      Int = 0
    var numberOfSteps:Int! = 0//nil;
    var DistanceData:Double = 0.0
    var startDate = Date()
    let trailStreet = NSMutableArray()


    
    //MARK: - timer functions
    func startTimer(){
        //start date/time
        self.startDate = Date() //timer start date
        
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval,target: self,selector: #selector(timerAction(timer:)) ,userInfo: nil,repeats: true)
    }
    
    func stopTimer(){
        self.timer.invalidate()
        displayPedometerData()
        
        self.Steps1 = numberOfSteps
    }
    
    func timerAction(timer:Timer){
        displayPedometerData()
    }
    
    //MARK: - Display and time format functions
    
    // convert seconds to hh:mm:ss as a string
    func timeIntervalFormat(interval:TimeInterval)-> String{
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }
    
    // display the updated data
    func displayPedometerData(){
        timeElapsed += 1.0
        statusTitle.text = timeIntervalFormat(interval: timeElapsed)
        //Number of steps
        if let numberOfSteps = self.numberOfSteps{
            stepsLabel.text = String(format:"%i",numberOfSteps)
        }

        //Distance Covered
        if self.DistanceData != 0.0 {
            
            distanceCoveredLabel.text = String(format:"%i m", DistanceData)
        }
        
        
    }

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

        print("Trail Data: \(trailData)")

        for trail in trailData {
            print("Trail id: \(trail.id)")
            print("Trail area: \(trail.area)")
            print("Trail street: \(trail.street)")
            trailStreet.add(trail.street)
            
            totalLength += trail.length
            totalTime += trail.travelTime
            coordinate2DList.append(trail.coordinate2DList)
        }
        
        trailStreetName.text = String(describing: trailStreet[0])
        lblInstructions.text = String(describing: trailStreet[0])
        
        // Set schedule date/time
        scheduleDate.text = epochToDateString(epochDate)

        // Center map to the trail
        centreToTrail()
        
        //  Create polyline with the CLLocationCoordinate2D list
        makePolyline()

        scheduleMap.selectAnnotation(scheduleMap.annotations[0], animated: true)
        
        //lblDistance.isHidden = true
        //lblInstructions.isHidden = true
        //imgDirection.isHidden = true
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
    
    
    /* MikeSaj Geo Implmentation: START */

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
    // - it WASN'T able to get the user's location.
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error)")
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
                    self.displaySteps(distance: self.steps[0].distance, instructions: self.steps[0].instructions)
                }
                else{
                    self.displaySteps(distance: self.steps[1].distance, instructions: self.steps[1].instructions)
                }
            
                //}
                
            }
        }
    }
    
    func displaySteps(distance: Double, instructions: String){
        self.lblInstructions.text = instructions
        self.lblDistance.text =  String(format: " Distance : %.2f m", distance)
        
        var dist = "\(distance) m"
        var imageName: String = ""
        
        if instructions.contains("left") == true{
            imageName = "left"
            self.imgDirection.image = UIImage(named: "left")
        }
        else if instructions.contains("right") == true {
            imageName = "right"
            self.imgDirection.image = UIImage(named: "right")
        }
        else{
            self.imgDirection.image = UIImage(named: "straight")
            imageName = "straight"
            
            if self.isInitialTrial == false {
                self.lblDistance.text =  "---"
                dist = ""
            }
            else
            {
                self.isInitialTrial = false
                self.displayMessage(ttl: "Warning", msg: String(format: " you are at %.2f m away from your trail", distance))
            }
        }
        
        self.sendInfoToWatch(distance: dist, instructions: instructions, imageName: imageName, isDone: false, isStopped: false)
    }
    
    func sendInfoToWatch(distance: String, instructions: String, imageName: String, isDone: Bool, isStopped: Bool){
        let messageToSend = ["instructions":instructions, "distance": distance, "imageName": imageName, "isDone": isDone, "isStopped": isStopped] as [String : Any]
        
        watchSession?.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["directions"] as? String
            print(value)
            
            }, errorHandler: {error in
                print(error)
        })
    }
    
    func onTick(){
        
        centreToTrail()
            
        if self.currentStep < self.coordinate2DList.count - 2{
            self.calculateDirections(nextIndex: self.currentStep + 2)
        }
        
        self.currentStep = self.currentStep + 1
        
        if self.currentStep == self.coordinate2DList.count{
            self.lblDistance.text = "0m"
            self.lblInstructions.text =  "You have arrived at your destination"

            btnStartWalking.setTitle("Start Walking", for: .normal)
            self.sendInfoToWatch(distance: "", instructions: self.lblInstructions.text!, imageName: "straight", isDone: true, isStopped: false)
            btnStartWalking.backgroundColor = startColor

            self.timer1.invalidate()
            self.stopTimer()
            self.displayMessage(ttl: "Congratulations!", msg: "You have completed this trail. ")
        }
        
    }
    
    @IBAction func btnStartWalking_Click(_ sender: UIButton) {
        self.manageWalkingTrail()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let index = message["index"] as! Int
        
        if index == 0 {
            self.manageWalkingTrail()
        }
        else{
            onTick()
        }
    }
    
    func manageWalkingTrail(){
        self.currentStep = 0
        self.isInitialTrial = true
        self.centreToTrail()
        
        if btnStartWalking.currentTitle == "Start Walking" {
            
            
             //Start the pedometer
             pedometer = CMPedometer()
             startTimer() //start the timer
             pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                if let pedData = pedometerData{
             
             //Getting data from the pedometer sensor
                let StepsData      = Int(pedData.numberOfSteps)
                self.numberOfSteps = StepsData + self.Steps1

             // Distance Travelled
                let distance  = Double(pedData.distance!)
                self.DistanceData  = distance + self.DistanceData

                self.startDate = Date()
             } else {
                self.stepsLabel.text = "Steps: Not Available"
             }
             })
             //Toggle the UI to on state
             //statusTitle.text = "Pedometer On"
 
            
            //lblDistance.isHidden = false
            //lblInstructions.isHidden = false
            //imgDirection.isHidden = false
        
            //Directions Connected with Timer
            self.timer1 = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
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
            btnStartWalking.backgroundColor = stopColor
        }
        else{
            
            //Stop the pedometer
            pedometer.stopUpdates()
            stopTimer() // stop the timer
            
            //save steps in healthkit
            self.userHealthData.startHealthShit(startDate: self.startDate, endDate: Date(), steps: self.numberOfSteps - TempSteps)
            TempSteps = self.numberOfSteps
            
            //Toggle the UI to off state
            //statusTitle.text = "Pedometer Off: "
            btnStartWalking.setTitle("Start Walking", for: .normal)
            btnStartWalking.backgroundColor = startColor
            
            
            //lblDistance.isHidden = true
            //lblInstructions.isHidden = true
            //imgDirection.isHidden = true
            
            //self.timer.invalidate()
            
            self.sendInfoToWatch(distance: "", instructions: "", imageName: "", isDone: true, isStopped: true)
        }
    }
    
}
