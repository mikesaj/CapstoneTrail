//
//  ScheduleViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import SwiftyJSON


class ScheduleListController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newHikeButton: UIButton!
    @IBOutlet weak var hikeScheduleListTableView: UITableView!

    var hikeId = [String]()
    var trailId = [String]()
    var trail = [String]()
    var hikeDate = [String]()

    var area = [String]()
    var epochDate = [UInt32]()
    var trailData = [[Trail]]()

    var invites = Set<String>()

    let scheduleDB = ScheduleDBController()
    var groupId: String = ""
    var groupOwnerId: String = ""


    // Database reference
    let ref = FIRDatabase.database()
                         .reference()

    // Current user id
    let uid = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {

        super.viewDidLoad()
    }


    override func viewWillAppear(_ animated: Bool) {

        hikeId.removeAll()
        trailId.removeAll()
        trail.removeAll()
        hikeDate.removeAll()
        area.removeAll()
        epochDate.removeAll()
        trailData.removeAll()


        // checks if to display group hikes or personal hikes
        if (groupId.characters.count) > 0 {
            populateHikeListCollection(collection: "groups", id: self.groupId)
        } else {

            // populates hike invites
            populateHikeInviteList()

            // populates user hikeList with DB records
            populateHikeListCollection(collection: "users", id: self.uid!)
        }

        // check if group owner
        if((groupId.characters.count > 1) && (groupOwnerId != uid)) {
            newHikeButton.isHidden = true//.removeFromSuperview()
        }

        self.hikeScheduleListTableView.reloadData()
        super.viewWillAppear(animated) // No need for semicolon
    }


    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
    }


    // MARK: - Controller Table View
    // Getting the number of rows in trail collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.trail.count
    }

    // populates and sets the custom cell element
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let inviteid = self.hikeId[indexPath.row]

        if invites.contains(inviteid) {
            //print("I got up on the good foot.")
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleInviteCell", for: indexPath) as! ScheduleInviteCell

            //labels
            cell.scheduleTitle.text = self.trail[indexPath.row]
            cell.scheduleTime.text = self.hikeDate[indexPath.row]

            //accept button
            cell.acceptButton.tag = indexPath.row
            cell.acceptButton.addTarget(self, action: #selector(acceptButton), for: .touchUpInside)

            //reject button
            cell.rejectButton.tag = indexPath.row
            cell.rejectButton.addTarget(self, action: #selector(rejectButton), for: .touchUpInside)

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleViewCell

        //labels
        cell.scheduleTitle.text = self.trail[indexPath.row]
        cell.scheduleTime.text = self.hikeDate[indexPath.row]

        //button
        cell.viewScheduleButton.tag = indexPath.row
        cell.viewScheduleButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)

        return cell
    }

    // specifies the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //let trail_1 = self.trail[indexPath.row]
        //let trailid_1 = self.trailId[indexPath.row]
        //let hikeid_1 = self.hikeId[indexPath.row]
        //let HikeDate_1 = self.hikeDate[indexPath.row]

        // redirect to storyboard
        /*let myVC = storyboard?.instantiateViewController(withIdentifier: "ScheduleProfile") as! ScheduleProfileController
        myVC.scheduleTitle = name!
        myVC.uid           = ui!
        
        // for slide view, without navigation
        //self.present(myVC, animated: true, completion: nil)
        
        //allows navigation appear
        //navigationController?.pushViewController(myVC, animated: true)
        
        navigationController?.present(myVC, animated: true)*/
        performSegue(withIdentifier: "View2", sender: self)

        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // invite button selected
    @IBAction func logAction(sender: UIButton) {

        let index = trail[sender.tag];

        // self.trail.removeObject(at: sender.tag)
        // self.trailId.removeObject (at: sender.tag)

        self.hikeScheduleListTableView.reloadData()

        print("indices = \(index)")
    }

    // reject hike invitation
    @IBAction func rejectButton(sender: UIButton) {

        let hikeEvent = self.trailId[sender.tag]

        self.trail.remove(at: sender.tag)
        self.trailId.remove(at: sender.tag)
        self.hikeId.remove(at: sender.tag)
        self.hikeDate.remove(at: sender.tag)
        self.area.remove(at: sender.tag)
        self.epochDate.remove(at: sender.tag)
        self.trailData.remove(at: sender.tag)

        //remove the hike invite from user
        scheduleDB.removeHikeInvite(hikeEventid: hikeEvent, userId: uid!)

        self.hikeScheduleListTableView.reloadData()
    }

    // accept hike invitation
    @IBAction func acceptButton(sender: UIButton) {

        let hikeEventid = self.hikeId[sender.tag]

        scheduleDB.removeHikeInvite(hikeEventid: hikeEventid, userId: uid!)
        scheduleDB.addHikeEventtoUser(hikeEventid: hikeEventid, userId: uid!)

        let index = trail[sender.tag];
        print("indices = \(index) user = \(uid!) eventid = \(hikeEventid)")

        self.trail.removeAll()
        self.trailId.removeAll()
        self.hikeId.removeAll()
        self.hikeDate.removeAll()
        self.area.removeAll()
        self.epochDate.removeAll()
        self.trailData.removeAll()

        self.hikeScheduleListTableView.reloadData()

        //populating group members data
        populateHikeListCollection(collection: "users", id: self.uid!)
    }

    // new Hike Schedule Button
    @IBAction func newHikeScheduleButton(_ sender: Any) {

        performSegue(withIdentifier: "newSchedule", sender: self)
    }


    // prepare to launch segue with data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "View2") {
            guard let scheduleProfile: ScheduleProfileController = segue.destination as? ScheduleProfileController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let indexPath = hikeScheduleListTableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let _trail: [Trail] = trailData[indexPath.row]
            let _date: UInt32 = epochDate[indexPath.row]

            scheduleProfile.scheduleTitle = ""
            scheduleProfile.uid = ""
            scheduleProfile.trailData = _trail
            scheduleProfile.epochDate = _date

            // Fetch weather only within 10 days
            if WeatherUtils.isWithin10Days(scheduleEpoch: _date) {
                // Fetch weather data
                WeatherUtils.getWeather(coordinate: _trail[0].coordinates[0], success: {
                    data in

                    let hourForecast: JSON = WeatherUtils.findForecast(scheduleEpoch: _date, weatherData: data)
                    let weatherIndex: Int = WeatherUtils.calcWeatherIndex(hourWeather: hourForecast)

                    // Internationalized label string
                    let indexMessageString = NSLocalizedString("Index_Message", comment: "String")
                    var indexTextString: String!
                    if weatherIndex == 10 {
                        indexTextString = NSLocalizedString("Excellent", comment: "")
                    } else if (8 ... 9).contains(weatherIndex) {
                        indexTextString = NSLocalizedString("Good", comment: "")
                    } else if (6 ... 7).contains(weatherIndex) {
                        indexTextString = NSLocalizedString("Moderate", comment: "")
                    } else if (4 ... 5).contains(weatherIndex) {
                        indexTextString = NSLocalizedString("Bad", comment: "")
                    } else {
                        indexTextString = NSLocalizedString("Horrible", comment: "")
                    }
                    let indexPointString = NSLocalizedString("Index_Point", comment: "Int")

                    let tempValueString = NSLocalizedString("Temp_Value", comment: "Double")
                    let feelsLikeValueString = NSLocalizedString("FeelsLike_Value", comment: "Double")
                    let windValueString = NSLocalizedString("Wind_Value", comment: "Double")
                    let cloudValueString = NSLocalizedString("Cloud_Value", comment: "Int")
                    let precipValueString = NSLocalizedString("Precip_Value", comment: "Double")
                    let humidityValueString = NSLocalizedString("Humidity_Value", comment: "Int")
                    let scheduleTimeString = NSLocalizedString("Schedule_Time", comment: "String")

                    let indexImageName = String(format: "WI_%d", weatherIndex)

                    // Send data to profile page
                    //scheduleProfile.indexIcon.image = UIImage(named: indexImageName)
                    scheduleProfile.indexMessage.text = String(format: indexMessageString, indexTextString)
                    scheduleProfile.indexPoint.text = String(format: indexPointString, weatherIndex)

                    //scheduleProfile.conditionText.text = hourForecast["condition"]["text"].stringValue
                    //scheduleProfile.temperatureText.text = NSLocalizedString("Temp_Text", comment: "")
                    //scheduleProfile.temperatureValue.text = String(format: tempValueString, hourForecast["temp_c"].doubleValue)
                    //scheduleProfile.feelsLikeText.text = NSLocalizedString("FeelsLike_Text", comment: "")
                    //scheduleProfile.feelsLikeValue.text = String(format: feelsLikeValueString, hourForecast["feelslike_c"].doubleValue)
                    //scheduleProfile.windText.text = NSLocalizedString("Wind_Text", comment: "")
                    //scheduleProfile.windValue.text = String(format: windValueString, hourForecast["wind_kph"].doubleValue)
                    //scheduleProfile.cloudText.text = NSLocalizedString("Cloud_Text", comment: "")
                    //scheduleProfile.cloudValue.text = String(format: cloudValueString, hourForecast["cloud"].intValue)
                    //scheduleProfile.precipitationText.text = NSLocalizedString("Precip_Text", comment: "")
                    //scheduleProfile.precipitationValue.text = String(format: precipValueString, hourForecast["precip_mm"].doubleValue)
                    //scheduleProfile.humidityText.text = NSLocalizedString("Humidity_Text", comment: "")
                    //scheduleProfile.humidityValue.text = String(format: humidityValueString, hourForecast["humidity"].intValue)
                    //scheduleProfile.scheduleTime.text = String(format: scheduleTimeString, scheduleProfile.epochToTimeString(hourForecast["time_epoch"].uInt32Value))
                })
            } else {
                print("Not fetch weather")
            }
        }

        // create a hike schedule in group
        if(segue.identifier == "newSchedule") {
            //            let trailList: TrailListTableViewController = segue.destination as! TrailListTableViewController
            //            trailList.groupId = groupId

            guard let trailMap: TrailMapViewController = segue.destination as? TrailMapViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            trailMap.groupID = groupId
        }
    }


    //populating hike inviations
    func populateHikeInviteList() {

        _ = ref.child("users")
               .queryOrderedByKey()
               .queryEqual(toValue: self.uid)
               .observe(.childAdded, with: {
                   (snapshot) in

                   let value = snapshot.value as? [String: AnyObject]

                   if value != nil {

                       var walkingInvitations = [String]()

                       if value?["walkingInvitation"] != nil {

                           // get hike invites
                           walkingInvitations = (value?["walkingInvitation"] as? [String])!
                       }

                       for walkingInvitation in walkingInvitations {

                           _ = self.ref.child("walkingSchedules")
                                       .queryOrderedByKey()
                                       .queryEqual(toValue: walkingInvitation)
                                       .observe(.childAdded, with: {
                                           (snapshot) in

                                           let value = snapshot.value as? [String: AnyObject]

                                           if value != nil {

                                               self.hikeId.append(snapshot.key)
                                               self.trail.append(value?["trail"] as! String)

                                               let vare = value?["trailId"]
                                               // FIXME: "trailId" is an array of string
                                               self.trailId.append(String(describing: vare))

                                               self.hikeDate.append(value?["date"] as! String)

                                               // Add area and epoch time
                                               let _IDs = value?["trailId"] as! [String]
                                               var _trails: [Trail] = []
                                               for _ID in _IDs {
                                                   let _trailMO = TrailUtils.searchTrail(id: _ID)
                                                   _trails.append(Trail(trail: _trailMO))
                                               }

                                               self.epochDate.append(value?["epochDate"] as! UInt32)
                                               self.trailData.append(_trails)

                                               // insert into invite id's
                                               self.invites.insert(snapshot.key)

                                               self.hikeScheduleListTableView.reloadData()
                                           }
                                       }) {
                                           (error) in
                                           print(error.localizedDescription)
                                       }
                       }
                   }
               }) {
                   (error) in
                   print(error.localizedDescription)
               }
    }


    //populating group members data
    func populateHikeListCollection(collection: String, id: String) {

        _ = ref.child(collection)
               .queryOrderedByKey()
               .queryEqual(toValue: id)
               .observe(.childAdded, with: {
                   (snapshot) in

                   let value = snapshot.value as? [String: AnyObject]

                   if value != nil {

                       var hikeInvites = [String]()

                       if value?["walkingSchedules"] != nil {

                           // get hike invites
                           hikeInvites = (value?["walkingSchedules"] as? [AnyObject])! as! [String]
                       }


                       // gets user hike schedules
                       for hikeInviteId in hikeInvites {


                           _ = self.ref.child("walkingSchedules")
                                       .queryOrderedByKey()
                                       .queryEqual(toValue: hikeInviteId)
                                       .observe(.childAdded, with: {
                                           (snapshot) in

                                           let value = snapshot.value as? [String: AnyObject]

                                           if value != nil {

                                               self.hikeId.append(snapshot.key)
                                               self.trail.append((value?["trail"])! as! String)

                                               let vare = value?["trailId"]
                                               // FIXME: "trailId" is an array of string
                                               self.trailId.append(String(describing: vare))
                                               self.hikeDate.append(value?["date"] as! String)

                                               // Add area and epoch time
                                               let _IDs = value?["trailId"] as! [String]
                                               var _trails: [Trail] = []
                                               for _ID in _IDs {
                                                   let _trailMO = TrailUtils.searchTrail(id: _ID)
                                                   _trails.append(Trail(trail: _trailMO))
                                               }

                                               let eDate = value?["epochDate"] as! NSNumber
                                               self.epochDate.append(eDate.uint32Value)
                                               self.trailData.append(_trails)

                                               self.hikeScheduleListTableView.reloadData()
                                           }
                                       }) {
                                           (error) in
                                           print(error.localizedDescription)
                                       }
                       }
                   }
               }) {
                   (error) in
                   print(error.localizedDescription)
               }
    }
}
    
    

