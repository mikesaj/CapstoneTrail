//
//  MakeScheduleViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 17..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit
import MapKit

import Firebase


class MakeScheduleViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scheduleDate: UITextField!
    @IBOutlet weak var scheduleMap: MKMapView!
    @IBOutlet weak var trailStreets: UILabel!
    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var scheduleWeather: UILabel!

    // MARK: Variables
    let datePicker: UIDatePicker = UIDatePicker()
    var currentTrail: Trail!
    var coordinate2DList: [CLLocationCoordinate2D] = []
    var neighbourIDs: [String] = []
    var neighbourTrails: [Trail] = []
    // Neighbour trails of current trail's neighbours
    var nestedIDs: [String] = []
    var nestedTrails: [Trail] = []

    // To be stored in database
    var scheduledTrails: [Trail] = []
    var scheduledTrailIDs: [String] = []
    var scheduledDateEpoch: Double = 0
    var totalLength: Double = 0
    var totalTime: Double = 0

    // database reference
    let ref = FIRDatabase.database()
                         .reference()
    var groupID: String = ""

    // MARK: Button actions
    // Discard all selection
    @IBAction func cancelButton(_ sender: UIButton) {

        let discardAction = UIAlertAction(title: "DISCARD", style: .destructive, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        })
        let stayAction = UIAlertAction(title: "STAY", style: .default)

        displayAlert(title: "Discard?", message: "Are you sure to discard all details?", actions: [discardAction, stayAction])
    }

    // Store on database
    @IBAction func doneButton(_ sender: UIButton) {

        // Check schedule date is set
        if scheduleDate.text == "" {
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            displayAlert(title: "No schedule date", message: "Please select a date", actions: [action])
            return
        }

        // Make current user's UID
        guard let userID = FIRAuth.auth()?.currentUser?.uid else {
            fatalError("Cannot get uid")
        }
        // Make schedule ID
        let scheduleID = UUID().uuidString

        // Create walking schedule
        createSchedule(userID, scheduleID)
        // Add schedule ID to user property
        addScheduleIDToUser(userID, scheduleID)
        // Add schedule ID to user's group
        if groupID != "" {
            addScheduleIDToGroup(userID, groupID, scheduleID)
        }

        // Display alert window
        let storeAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        })
        displayAlert(title: "Saved", message: "The schedule is saved successfully", actions: [storeAction])
    }

    // Set date picker
    func setDatePicker() {

        scheduleDate.becomeFirstResponder()

        scheduleDate.delegate = self

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(finishDatePicker))
        toolbar.setItems([doneButton], animated: false)

        scheduleDate.inputAccessoryView = toolbar
    }

    // Finish date picker
    func finishDatePicker() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        // Set date on the text field
        let pickedDate: Date = datePicker.date
        scheduleDate.text = dateFormatter.string(for: pickedDate)
        // Set epoch date
        scheduledDateEpoch = pickedDate.timeIntervalSince1970

        titleLabel.text = "Make your walking path"

        self.view.endEditing(true)
    }

    // Display alert window
    func displayAlert(title: String, message: String, actions: [UIAlertAction]) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alert.addAction(action)
        }

        self.present(alert, animated: true, completion: nil)
    }


    // MARK: viewDidLoad
    override func viewDidLoad() {

        super.viewDidLoad()

        // Initialize map view
        scheduleMap.mapType = .standard
        scheduleMap.delegate = self

        // Set DatePicker
        setDatePicker()

        // Handle current trail
        handleCurrentTrail()

        // Weather information on the scheduled date (TODO)
        scheduleWeather.text = ""

        // Get neighbour trail information
        getNeighbourInfo()

        // Center map to the trail
        centreToTrail()
        // Create polyline with the CLLocationCoordinate2D list
        makePolyline()
    }

    // Handle current trail
    func handleCurrentTrail() {

        // Append selected trail to scheduled trails list
        scheduledTrails.append(currentTrail)
        scheduledTrailIDs.append(currentTrail.id)
        totalLength += currentTrail.length
        totalTime += currentTrail.travelTime

        trailStreets.text = String(format: "Start @ %@, End @ %@", scheduledTrails[0].street, (scheduledTrails.last?.street)!)
        totalDuration.text = String(format: "Total length: %.2f m, %.2f minutes", totalLength, totalTime)
    }

    // MARK: MKMapViewDelegate
    // Get neighbour trail information
    func getNeighbourInfo() {

        // Unwrap neighbour IDs
        if let neighbours = currentTrail.neighbours {
            neighbourIDs = neighbours
        }

        // Fetch neighbour trails data
        for neighbour in neighbourIDs {
            let searched = TrailUtils.searchTrail(id: neighbour)
            let searchedTrail = Trail(trail: searched)
            neighbourTrails.append(searchedTrail)
        }

        // Handle nested neighbour trails
        for neighbourTrail in neighbourTrails {
            if let neighbourIDs = neighbourTrail.neighbours {
                // Collect nested neighbour IDs
                nestedIDs.append(contentsOf: neighbourIDs)
                // Fetch nested neighbour trails data
                for neighbourID in neighbourIDs {
                    let searched = TrailUtils.searchTrail(id: neighbourID)
                    let searchedTrail = Trail(trail: searched)
                    if searchedTrail != currentTrail {
                        nestedTrails.append(searchedTrail)
                    }
                }
            }
        }
    }

    // Centre map to the trail
    func centreToTrail() {

        // Get middle position of the coordinate list
        let middlePosition = Int(floorf(Float(currentTrail.coordinate2DList.count) / Float(2)))
        let middleTrailCoordinate = currentTrail.coordinate2DList[middlePosition]
        var mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.008, 0.008)
        if scheduledTrailIDs.count > 1 {
            mapSpan = scheduleMap.region.span
        }
        let mapRegion: MKCoordinateRegion = MKCoordinateRegionMake(middleTrailCoordinate, mapSpan)

        scheduleMap.setRegion(mapRegion, animated: true)
    }

    //  Create polyline with the CLLocationCoordinate2D list
    func makePolyline() {

        // Create SchedulePolyline objects for scheduled trails
        for scheduledTrail in scheduledTrails {
            let scheduledPolyline: SchedulePolyline = SchedulePolyline(coordinates: scheduledTrail.coordinate2DList, count: scheduledTrail.coordinate2DList.count)
            scheduledPolyline.isCurrent = true
            scheduledPolyline.trailID = scheduledTrail.id
            scheduleMap.add(scheduledPolyline)
        }

        // Create SchedulePolyline objects for neighbour trails
        for neighbourTrail in neighbourTrails {
            if !scheduledTrailIDs.contains(neighbourTrail.id) {
                let trailPolyline = SchedulePolyline(coordinates: neighbourTrail.coordinate2DList, count: neighbourTrail.coordinate2DList.count)
                scheduleMap.add(trailPolyline)

                let trailPin = ScheduleAnnotation()
                var coordinateRadian = TrailUtils.getBearing(p1: neighbourTrail.coordinate2DList[0], p2: neighbourTrail.coordinate2DList[1])

                // Find junction coordinate
                var junctionIndex = 1
                if currentTrail?.coordinate2DList.first == neighbourTrail.coordinate2DList.last ||
                   currentTrail?.coordinate2DList.last == neighbourTrail.coordinate2DList.last {
                    junctionIndex = neighbourTrail.coordinate2DList.count - 2
                    coordinateRadian += M_PI
                }

                trailPin.coordinate = neighbourTrail.coordinate2DList[junctionIndex]
                trailPin.trail = neighbourTrail
                trailPin.rotateRadian = CGFloat(coordinateRadian)

                scheduleMap.addAnnotation(trailPin)
            }
        }

        // Create SchedulePolyline objects for nested neighbour trails
        for nestedTrail in nestedTrails {
            if !scheduledTrailIDs.contains(nestedTrail.id) {
                let nestedPolyline = SchedulePolyline(coordinates: nestedTrail.coordinate2DList, count: nestedTrail.coordinate2DList.count)
                nestedPolyline.isNested = true
                scheduleMap.add(nestedPolyline)
            }
        }
    }
    // Ask the delegate for a renderer object to use when drawing the specified overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        // Initialize and return a new overlay view using the specified polyline overlay object
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        // Set stroke line width
        polylineRenderer.lineWidth = 1.3
        polylineRenderer.strokeColor = UIColor.cyan

        if overlay is SchedulePolyline {

            var strokeColour: UIColor

            let schedulePolyline = overlay as! SchedulePolyline
            if schedulePolyline.isCurrent {
                // Set stroke line width
                polylineRenderer.lineWidth = 2.6
                strokeColour = UIColor.blue()
            } else {
                // Set stroke line width
                polylineRenderer.lineWidth = 1.3
                strokeColour = UIColor.red
            }

            polylineRenderer.strokeColor = strokeColour
        }

        return polylineRenderer
    }

    // Customise annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        } else if annotation is ScheduleAnnotation {
            let scheduleAnnotation = annotation as! ScheduleAnnotation
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "ArrowNorth")?.image(withRotation: scheduleAnnotation.rotateRadian!)
            annotationView.canShowCallout = false

            return annotationView
        } else {
            return nil
        }
    }

    // Annotation touch event
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let mapAnnotation: ScheduleAnnotation = view.annotation as? ScheduleAnnotation {
            guard let trail = mapAnnotation.trail else {
                debugPrint("ScheduleAnnotation: No trail data")
                return
            }

            // Clear all elements on map view
            let overlays = scheduleMap.overlays
            scheduleMap.removeOverlays(overlays)
            let annotations = scheduleMap.annotations
            scheduleMap.removeAnnotations(annotations)
            // Clear neighbours
            neighbourIDs = []
            neighbourTrails = []
            nestedIDs = []
            nestedTrails = []

            // Make selected trail as current trail
            currentTrail = trail
            // Handle current trail
            handleCurrentTrail()
            // Get neighbour trail information
            getNeighbourInfo()
            // Center map to the trail
            centreToTrail()
            // Create polyline with the CLLocationCoordinate2D list
            makePolyline()
        } else {
            debugPrint("Not ScheduleAnnotation")
        }
    }

    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {

        let currentDate: Date = Date()
        datePicker.minimumDate = currentDate
        datePicker.minuteInterval = 10

        datePicker.datePickerMode = .dateAndTime
        textField.inputView = datePicker
    }

    // MARK: Database
    // Store new schedule
    func createSchedule(_ userID: String, _ scheduleID: String) {

        // Set data to database
        let scheduleReference = ref.child("walkingSchedules")
                                   .child(scheduleID)
        scheduleReference.child("groupId")
                         .setValue(self.groupID)
        scheduleReference.child("trailId")
                         .setValue(self.scheduledTrailIDs)
        scheduleReference.child("trail")
                         .setValue(self.scheduledTrails[0].street)
        scheduleReference.child("date")
                         .setValue(self.scheduleDate.text)
        scheduleReference.child("epochDate")
                         .setValue(self.scheduledDateEpoch)
        scheduleReference.child("attendees")
                         .child("0")
                         .setValue(userID)
    }

    // Add schedule to user
    func addScheduleIDToUser(_ userID: String, _ scheduleID: String) {

        let queryReturn = ref.child("users")
                             .queryOrderedByKey()
                             .queryEqual(toValue: userID)

        queryReturn.observe(.childAdded, with: {
            (snapshot) in

            let value = snapshot.value as? [String: AnyObject]

            if value != nil {

                var walkingSchedules = [String]()

                if value?["walkingSchedules"] != nil {

                    // get user's group list
                    walkingSchedules = (value?["walkingSchedules"] as? [String])!
                }

                // add hikingSchedule id to user's list
                walkingSchedules.insert(scheduleID, at: 0)
                //hikingSchedules.append(trailId)

                // add group to the user's group list
                self.ref.child("users")
                        .child(userID)
                        .child("walkingSchedules")
                        .setValue(walkingSchedules);
            }
        }) {
            (error) in
            print(error.localizedDescription)
        }
    }

    // Add schedule to group
    func addScheduleIDToGroup(_ userID: String, _ groupID: String, _ scheduleID: String) {

        ref.child("groups")
           .queryOrderedByKey()
           .queryEqual(toValue: groupID)
           .observe(.childAdded, with: {
               (snapshot) in

               let value = snapshot.value as? [String: AnyObject]
               print("\(groupID): empty nothing 1")

               if value != nil {

                   var walkingSchedules = [String]()
                   var memberIDs = [String]()

                   if value?["walkingSchedules"] != nil {

                       // get user's group list
                       walkingSchedules = (value?["walkingSchedules"] as? [String])!
                   }

                   // add hikingSchedule-id to group list
                   walkingSchedules.insert(scheduleID, at: 0)
                   //hikingSchedules.append(trailId)

                   // add schedule to the group's hiking list
                   self.ref.child("groups")
                           .child(groupID)
                           .child("walkingSchedules")
                           .setValue(walkingSchedules);

                   // invite group members
                   if value?["members"] != nil {

                       // get group members list
                       memberIDs = (value?["members"] as? [String])!

                       // invite group members
                       self.inviteGroupMembers(userID, memberIDs, scheduleID)
                   }
               }
           }) {
               (error) in
               print(error.localizedDescription)
           }
    }

    // Invite group members
    func inviteGroupMembers(_ userID: String, _ memberIDs: [String], _ scheduleID: String) {

        for memberID in memberIDs {
            if memberID != userID {
                ref.child("users")
                   .queryOrderedByKey()
                   .queryEqual(toValue: memberID)
                   .observe(.childAdded, with: {
                       (snapshot) in

                       let value = snapshot.value as? [String: AnyObject]

                       if value != nil {

                           var walkingInvitation = [String]()

                           if value?["walkingInvitation"] != nil {

                               // get user's group list
                               walkingInvitation = (value?["walkingInvitation"] as? [String])!
                           }

                           // add hikingSchedule id to user's invitation list
                           walkingInvitation.insert(scheduleID, at: 0)

                           // add group to the user's group list
                           self.ref.child("users")
                                   .child(memberID)
                                   .child("walkingInvitation")
                                   .setValue(walkingInvitation);
                       }
                   }) {
                       (error) in
                       print(error.localizedDescription)
                   }
            }
        }
    }
}


class SchedulePolyline: MKPolyline {

    var trailID: String!
    var isCurrent: Bool = false
    var isNested: Bool = false
}


class ScheduleAnnotation: MKPointAnnotation {

    var trail: Trail!
    var rotateRadian: CGFloat?
}


extension UIImage {
    func image(withRotation radians: CGFloat) -> UIImage {

        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width: Int(LARGEST_SIZE), height: Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!

        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5, y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!

        drawRect = drawRect.applying(tf)

        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        return resultImage
    }
}


extension CLLocationCoordinate2D: Equatable {

    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {

        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
}
