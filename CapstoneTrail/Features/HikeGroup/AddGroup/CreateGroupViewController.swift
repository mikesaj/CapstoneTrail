//
//  CreateGroupViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-16.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import CoreLocation

class CreateGroupViewController: UIViewController, CLLocationManagerDelegate {

    //Location label declaration
    @IBOutlet weak var locationLabel: UILabel!
    var currentLocation = "Undefined Location"
    
    // instantiating the location manager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // default location text
        locationLabel.text = currentLocation
        
        // Calls the location manager to get co-ordinate
        getLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Create hike group button
    @IBAction func createGroupButton() {
        
        // Calls the location manager to get co-ordinate
        getLocation()
        
        currentLocation = locationLabel.text!
        
        if currentLocation == "Undefined Location" {
            
            displayMessage(ttl: "Error Creating Group", msg: "Hike Group cannot be created without a location. \nPlease authorize this app to access your location")
            return
        }
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "HikerInvitation") as! HikerInvitation
        myVC.locationName = currentLocation
        
        // for slide view, without navigation
        self.present(myVC, animated: true, completion: nil)
        
        //allows navigation appear
        //navigationController?.pushViewController(myVC, animated: true)
        
        //navigationController?.present(myVC, animated: true)
    return
    }
    
    // get co-ordinates and location from location manager
    // Also checks for user's location permissions
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled on your device. In order to use this app, go to " +
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
                    getLocation()
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
    /*
        let newLocation = locations.last!
        
        let currLocation = newLocation.coordinate
        
        let lat  = String(currLocation.latitude)
        let long = String(currLocation.longitude)
        
        locationLabel.text = "Location: " + lat + ", " + long
        print(currLocation)
    */
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
            
            let city   = placemark.locality ?? ""
            let region = placemark.administrativeArea ?? ""
            
            locationLabel.text = city + ", " + region
            
            print(placemark.locality ?? "")
            print(placemark.administrativeArea ?? "")
            print(placemark.country ?? "")
        }
    }
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}