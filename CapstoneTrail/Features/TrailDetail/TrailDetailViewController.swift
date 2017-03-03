//
//  TrailDetailViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 22..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Firebase

class TrailDetailViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var trailIDLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var txtDateTrail: UITextField!
    
    let datePicker = UIDatePicker()
    
    // MARK: Variables
    var trail: NSManagedObject!
    var id: NSNumber!
    var area: String!
    var street: String!
    var status: String!
    var surface: String!
    var pathType: String!
    var owner: String!
    var length: Double!
    var coordinates: [[Double]]!
    var coordinate2DList: [CLLocationCoordinate2D]!
    var travelTime: Double!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
        
        setupDatePicker()
        
        // Assign TrailMO values to local variables
        assignTrailData()
        // Get CLLocationCoordinate2D list
        coordinate2DList = makeCoordinate2D()
        // Center map to the trail
        centerToTrail()
        //  Create polyline with the CLLocationCoordinate2D list
        makePolyline()
        
        let detailStr = NSLocalizedString("Trail detail info", comment: "Trail detail")
        areaLabel.text = String(format: "%@ %@", area.capitalized, pathType.capitalized)
        trailIDLabel.text = String(format: "#%d", id)
        detailLabel.text = String(format: detailStr, street.capitalized, status.capitalized, surface.lowercased(), length, travelTime)
    }
    
    func setupDatePicker()
    {
        txtDateTrail.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        txtDateTrail.inputAccessoryView = toolbar
    }
    
    func donePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        txtDateTrail.text = formatter.string(for: datePicker.date)
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let currentDate: Date = Date()
        self.datePicker.minimumDate = currentDate
        
        self.datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        textField.inputView = datePicker
    }
    
    @IBAction func btnAdd_Click(_ sender: AnyObject) {
        if txtDateTrail.text == ""{
            self.displayMessage(ttl: "Error", msg: "Please, choose a date")
            return 
        }
        
        let ref = FIRDatabase.database().reference()
        
        //Group
        let groupUid = UUID().uuidString
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let groupReference = ref.child("groups").child(groupUid)
        
        groupReference.child("owneruid").setValue(uid)
        groupReference.child("members").child("0").setValue(uid)
        groupReference.child("isPublic").setValue(false)        
        groupReference.child("name").setValue("name")
        groupReference.child("locationName").setValue("locationName")
        groupReference.child("description").setValue("groupDescription")
        groupReference.child("longitude").setValue("longitude")
        groupReference.child("latitude").setValue("latitude")
        
        //Walking Schedule
        let TrailId = UUID().uuidString
        let walkingScheduleReference = ref.child("walkingSchedules").child(groupUid).child(TrailId)
        walkingScheduleReference.child("date").setValue(self.txtDateTrail.text)
        walkingScheduleReference.child("trail").setValue(self.street)
        
        //User
        self.addGrouptoUser(userId: uid!, groupId: groupUid)
        
        self.displayMessage(ttl: "Warning", msg: "Trail was saved successfully")
    }
    
    func addGrouptoUser(userId: String, groupId: String){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    var userGroups = [String]()
                    
                    if value?["groups"] != nil {
                        
                        // get user's group list
                        userGroups = (value?["groups"] as? [String])!
                    }
                    
                    // add group id to user's list
                    userGroups.append(groupId)
                    
                    // add group to the user's group list
                    ref.child("users").child(userId).child("groups").setValue(userGroups);
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Assign TrailMO values to variables
    func assignTrailData() {
        
        guard let trail = trail else {
            fatalError("No TrailMO retrieved")
        }
        
        id = trail.value(forKey: "id") as! NSNumber
        area = trail.value(forKey: "area") as! String
        street = trail.value(forKey: "street") as! String
        status = trail.value(forKey: "status") as! String
        surface = trail.value(forKey: "surface") as! String
        pathType = trail.value(forKey: "pathType") as! String
        owner = trail.value(forKey: "owner") as! String
        length = trail.value(forKey: "length") as! Double
        coordinates = trail.value(forKey: "coordinates") as! [[Double]]
        travelTime = TrailUtils.metre2minute(lengthIn: length)
    }
    
    // Create CLLocationCoordinate2D list from double type coordinates
    func makeCoordinate2D() -> [CLLocationCoordinate2D] {
        
        // CLLocationCoordinate2D container
        var coordinates2DList: [CLLocationCoordinate2D] = []
        for coordinate in coordinates {
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate[1], coordinate[0])
            coordinates2DList.append(point)
        }
        
        return coordinates2DList
    }
    
    // Center map to the trail
    func centerToTrail() {
        
        // Get middle position of the coordinate list
        let middlePosition = Int(roundf(Float(coordinate2DList.count) / Float(2)))
        let middleTrailCoordinate = coordinate2DList[middlePosition]
        let mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let mapRegion: MKCoordinateRegion = MKCoordinateRegionMake(middleTrailCoordinate, mapSpan)
        
        mapView.setRegion(mapRegion, animated: true)
        
        // Make pin
        let pinSubtitleString = NSLocalizedString("MapPin", comment: "Street name, (length)m")
        let trailPin: MKPointAnnotation = MKPointAnnotation()
        trailPin.coordinate = middleTrailCoordinate
        trailPin.title = pathType?.capitalized
        trailPin.subtitle = String(format: pinSubtitleString, street!.capitalized, length!)
        
        mapView.addAnnotation(trailPin)
    }
    
    //  Create polyline with the CLLocationCoordinate2D list
    func makePolyline() {
        
        // Create MKPolyline object from the specified set of coordinates
        let polyline: MKPolyline = MKPolyline(coordinates: coordinate2DList, count: coordinate2DList.count)
        // Add the polyline as single overlay object to the map
        mapView.add(polyline)
    }
    
    
    // MARK: MKMapViewDelegate
    // Ask the delegate for a renderer object to use when drawing the specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Initialize and return a new overlay view using the specified polyline overlay object
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Set stroke line colour
        polylineRenderer.strokeColor = UIColor.blue
        // Set stroke line width
        polylineRenderer.lineWidth = 4
        
        return polylineRenderer
    }
}
