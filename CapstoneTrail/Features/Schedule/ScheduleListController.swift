//
//  ScheduleViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class ScheduleListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var newHikeButton: UIButton!
    @IBOutlet weak var hikeScheduleListTableView: UITableView!
    
    var hikeId   =     [String]()
    var trailId  =     [String]()
    var trail    =     [String]()
    var hikeDate =     [String]()
    
    var invites = Set<String>()
    
    let scheduleDB =  ScheduleDBController()
    var groupId:      String = ""
    var groupOwnerId: String = ""

    
    // Database reference
    let ref = FIRDatabase.database().reference()

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

        
        // checks if to display group hikes or personal hikes
        if (groupId.characters.count) > 0 {
            populateHikeListCollection(collection: "groups", id: self.groupId)
        }
        else {
            
            // populates hike invites
            populateHikeInviteList()
            
            // populates user hikeList with DB records
            populateHikeListCollection(collection: "users", id: self.uid!)
        }
        
        // check if group owner
        if ( (groupId.characters.count > 1) && (groupOwnerId != uid) ) {
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
        
        if invites.contains( inviteid ) {
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
        
        let trail_1    = self.trail[indexPath.row]
        let trailid_1  = self.trailId[indexPath.row]
        let hikeid_1   = self.hikeId[indexPath.row]
        let HikeDate_1 = self.hikeDate[indexPath.row]
        
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
    @IBAction func logAction(sender: UIButton){
        
        let index = trail[sender.tag];
        
        // self.trail.removeObject(at: sender.tag)
        // self.trailId.removeObject (at: sender.tag)
        
        self.hikeScheduleListTableView.reloadData()
        
        print("indexis = \(index)")
    }
    
    // reject hike invitation
    @IBAction func rejectButton(sender: UIButton){
        
        let hikeEvent = self.trailId[sender.tag]
        
        self.trail   .remove(at: sender.tag)
        self.trailId .remove(at: sender.tag)
        self.hikeId  .remove(at: sender.tag)
        self.hikeDate.remove(at: sender.tag)
        
        //remove the hike invite from user
        scheduleDB.removeHikeInvite(hikeEventid:hikeEvent, userId:uid!)
        
        self.hikeScheduleListTableView.reloadData()
    }
    
    // accept hike invitation
    @IBAction func acceptButton(sender: UIButton){
        
        let hikeEventid = self.hikeId[sender.tag]
        
        scheduleDB.removeHikeInvite(hikeEventid:hikeEventid, userId:uid!)
        scheduleDB.addHikeEventtoUser(hikeEventid:hikeEventid, userId:uid!)
        
        let index = trail[sender.tag];
        print("indexis = \(index) user = \(uid!) eventid = \(hikeEventid)")
        
        self.trail   .removeAll()
        self.trailId .removeAll()
        self.hikeId  .removeAll()
        self.hikeDate.removeAll()

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
        
        if(segue.identifier == "View2"){
            let scheduleProfile: ScheduleProfileController = segue.destination as! ScheduleProfileController
            scheduleProfile.scheduleTitle = ""
            scheduleProfile.uid = ""
        }
        
        // create a hike schedule in group
        if(segue.identifier == "newSchedule") {
            let trailList: TrailListTableViewController = segue.destination as! TrailListTableViewController
            trailList.groupId = groupId
        }
    }
    
    
    //populating hike inviations
    func populateHikeInviteList(){
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: self.uid)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    var hikeInvites = [String]()
                    
                    if value?["hikeInvites"] != nil {
                        
                        // get hike invites
                        hikeInvites = (value?["hikeInvites"] as? [String])!
                    }
                    
                    for hikeInviteId in hikeInvites {
                        
                        _ = self.ref.child("hikingSchedules")
                            .queryOrderedByKey()
                            .queryEqual(toValue: hikeInviteId)
                            .observe(.childAdded, with: { (snapshot) in
                                
                                let value = snapshot.value as? [String: AnyObject]
                                
                                if value != nil{
                                    
                                    self.hikeId     .append(snapshot.key)
                                    self.trail      .append(value?["trail"]      as! String)
                                    
                                    let vare = value?["trailId"]
                                    self.trailId    .append( String(describing: vare) )

                                    self.hikeDate   .append(value?["date"]       as! String)
                                    
                                    // insert into invite id's
                                    self.invites.insert(snapshot.key)
                                    
                                    self.hikeScheduleListTableView.reloadData()
                                    
                                }
                                
                            }) { (error) in
                                print(error.localizedDescription)
                        }
                        
                        
                        
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
    }


    //populating group members data
    func populateHikeListCollection(collection:String, id:String){
        
        _ = ref.child( collection )
            .queryOrderedByKey()
            .queryEqual(toValue: id )
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    var hikeInvites = [String]()
                    
                    if value?["hikingSchedules"] != nil {
                        
                        // get hike invites
                        hikeInvites = (value?["hikingSchedules"] as? [AnyObject])! as! [String]
                    }
                    
                    
                    // gets user hike schedules
                    for hikeInviteId in hikeInvites {
                        
                        
                        _ = self.ref.child("hikingSchedules")
                            .queryOrderedByKey()
                            .queryEqual(toValue: hikeInviteId)
                            .observe(.childAdded, with: { (snapshot) in
                                
                                let value = snapshot.value as? [String: AnyObject]
                                
                                if value != nil{
                                    
                                    self.hikeId     .append(snapshot.key)
                                    self.trail      .append((value?["trail"])! as! String)
                                    
                                    let vare = value?["trailId"]
                                    
                                    self.trailId    .append( String(describing: vare) )
                                    self.hikeDate   .append(value?["date"] as! String)
                                    
                                    self.hikeScheduleListTableView.reloadData()
                                }
                                
                            }) { (error) in
                                print(error.localizedDescription)
                        }
                        
                        
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
    }

}
    
    

