//
//  CreateGroupViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-16.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class CreateGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate  {

    //Location label declaration
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var groupVisibility: UISegmentedControl!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextView: UITextView!
    
    // Get's logged user's uid
    let currentUserID = FIRAuth.auth()?.currentUser?.uid

    
    var currentLocation = "Undefined Location"
    var lat:String  = ""
    var long:String = ""
    
    let initDescrptionText = "Group description"
    
    // instantiating the location manager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.groupNameTextField.delegate = self
        self.groupDescriptionTextView.delegate = self
        
        // description textView border properties
        groupDescriptionTextView.textColor = UIColor.lightGray
        groupDescriptionTextView.text = initDescrptionText
        groupDescriptionTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        groupDescriptionTextView.layer.borderWidth = 1.0
        groupDescriptionTextView.layer.cornerRadius = 5
        
        // default location text
        locationLabel.text = currentLocation
        
        // Calls the location manager to get co-ordinate
        getLocation()
    }
    
    //hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if groupDescriptionTextView.textColor == UIColor.lightGray {
            groupDescriptionTextView.text = nil
            groupDescriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if groupDescriptionTextView.text.isEmpty {
            groupDescriptionTextView.text = initDescrptionText
            groupDescriptionTextView.textColor = UIColor.lightGray
        }
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
        
        // get group name from UITextField
        guard let groupName:String = groupNameTextField.text else {
            self.displayMessage(ttl: "Group Error!", msg: "Group name field is empty")
            return
        }
        
        if (groupName.isEmpty) {
            self.displayMessage(ttl: "Error", msg: "Please fill empty labels")
            return
        }
        
        // get group description from UITextView
        guard let groupDescription:String = groupDescriptionTextView.text else {
            self.displayMessage(ttl: "Group Error!", msg: "Group description field is empty")
            return
        }
        
        if (groupDescription.isEmpty) {
            self.displayMessage(ttl: "Error", msg: "Please fill group description label")
            return
        }

        // instantiating group db data model
        let groupdDb = GroupDBController()
        let group1 = GroupModel()

        // get Group visibility from UISegmentedControl
        var isPublic = true
        if groupVisibility.selectedSegmentIndex == 1 {
            isPublic = false
        }
        
        group1.name = groupName
        group1.locationName = currentLocation
        group1.longitude    = self.long
        group1.latitude     = self.lat
        group1.isPublic     = isPublic
        group1.groupDescription = groupDescription
        
        // Creates hiking group
        let groupId = groupdDb.CreateGroup(group: group1)
        
        // launch group profile controller
        let myVC = storyboard?.instantiateViewController(withIdentifier: "GroupProfile") as! GroupProfileViewController
        myVC.GroupName    = group1.name!
        myVC.GroupDescrip = group1.groupDescription!
        myVC.locationName = currentLocation
        myVC.memberCount  = 1
        myVC.groupid      = groupId
        myVC.groupOwnerid = currentUserID!
        

        
        // for slide view, without navigation
        //self.present(myVC, animated: true, completion: nil)
        
        //allows navigation appear
        navigationController?.pushViewController(myVC, animated: true)
        
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
        
        self.lat  = String(currLocation.latitude)
        self.long = String(currLocation.longitude)
        
        //locationLabel.text = "Location: " + lat + ", " + long
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
