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

    // database reference
    let ref = FIRDatabase.database().reference()
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
    var epochDate: Double?
    
    var groupId: String = ""//"22ED0638-C875-4B89-8D90-DE31BB5019AC"

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
        
        // Transform to epoch date
        epochDate = formatter.date(from: txtDateTrail.text!)?.timeIntervalSince1970
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
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        //Create Hiking Event
        let hikeId = UUID().uuidString
        let hikeScheduleReference = ref.child("hikingSchedules").child(hikeId)
        hikeScheduleReference.child("groupId").setValue(self.groupId)
        hikeScheduleReference.child("trailId").setValue(self.id)
        hikeScheduleReference.child("trail").setValue(self.street)
        hikeScheduleReference.child("date").setValue(self.txtDateTrail.text)
        hikeScheduleReference.child("attendees").child("0").setValue(uid)
        // Add additional data for weather features
        hikeScheduleReference.child("area").setValue(self.area)
        if epochDate != nil {
            hikeScheduleReference.child("epochDate").setValue(self.epochDate)
        }
        
        //add event to group
        self.addHikingScheduletoGroup(groupId: self.groupId, hikeId: hikeId)
        
        self.displayMessage(ttl: self.street, msg: "Trail was saved successfully")
    }
    
    // invite group members
    func inviteGroupMembers(memberIds: [String], hikeId: String){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        for memberid in memberIds {
            if memberid != uid {
            ref.child("users")
                .queryOrderedByKey()
                .queryEqual(toValue: memberid)
                .observe(.childAdded, with: { (snapshot) in
                    
                    let value = snapshot.value as? [String: AnyObject]
                    
                    if value != nil{
                        
                        var hikingSchedules = [String]()
                        
                        if value?["hikeInvites"] != nil {
                            
                            // get user's group list
                            hikingSchedules = (value?["hikeInvites"] as? [String])!
                        }
                        
                        // add hikingSchedule id to user's invitation list
                        hikingSchedules.insert(hikeId, at: 0)
                        
                        // add group to the user's group list
                        self.ref.child("users").child(memberid).child("hikeInvites").setValue(hikingSchedules);
                        
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
            }
          }
        }
        
        
    }
    
    
    //add's a hiking schedule to group
    func addHikingScheduletoGroup(groupId: String, hikeId: String) {

        let uid = FIRAuth.auth()?.currentUser?.uid
        
        // add hikingSchedule to the group onwer's list
        self.addHikeScheduleToUser(userId: uid!, hikeId: hikeId)

        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                print("\(groupId): empty nothing 1")
                
                if value != nil{
                    
                    var hikingSchedules = [String]()
                    var membersids = [String]()
                    
                    if value?["hikingSchedules"] != nil {
                        
                        // get user's group list
                        hikingSchedules = (value?["hikingSchedules"] as? [String])!
                    }

                    // add hikingSchedule-id to group list
                    hikingSchedules.insert(hikeId, at: 0)
                    //hikingSchedules.append(trailId)
                    
                    // add schedule to the group's hiking list
                    self.ref.child("groups")
                        .child(groupId).child("hikingSchedules")
                        .setValue(hikingSchedules);
                    
                    // invite group members
                    if value?["members"] != nil {
                        
                        // get group members list
                        membersids = (value?["members"] as? [String])!

                        // invite group members
                        self.inviteGroupMembers(memberIds: membersids, hikeId: hikeId)
                    }
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    
    // add hiking Schedule event to user's list
    func addHikeScheduleToUser(userId: String, hikeId: String){
        
        ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    var hikingSchedules = [String]()
                    
                    if value?["hikingSchedules"] != nil {
                        
                        // get user's group list
                        hikingSchedules = (value?["hikingSchedules"] as? [String])!
                    }
                    
                    // add hikingSchedule id to user's list
                    hikingSchedules.insert(hikeId, at: 0)
                    //hikingSchedules.append(trailId)
                    
                    // add group to the user's group list
                    self.ref.child("users").child(userId).child("hikingSchedules").setValue(hikingSchedules);
                    
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
