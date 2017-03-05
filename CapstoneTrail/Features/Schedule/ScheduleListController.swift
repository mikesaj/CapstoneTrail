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
    
    @IBOutlet weak var hikeScheduleListTableView: UITableView!
    
    var locationName: NSMutableArray! = NSMutableArray()
    var locationUid:  NSMutableArray! = NSMutableArray()
    var hikeDate:     NSMutableArray! = NSMutableArray()

    // Database reference
    let ref = FIRDatabase.database().reference()
    
    var groupId: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Demo data
        
        //trail name
        locationName.add("Waterloo Trail")
        locationName.add("Kitchener Trail")
        locationName.add("Apple Groove Trails")
        locationName.add("Uptown Trails")
        locationName.add("Westmount Trails")
        locationName.add("Fairway Walks")
        locationName.add("Kings Trails")
        locationName.add("Laurie Trails")
        locationName.add("Kids Trails")
        locationName.add("Baby Trails")
        
        // trail id
        locationUid.add("12345243")
        locationUid.add("56545543")
        locationUid.add("6576u798")
        locationUid.add("87653434")
        locationUid.add("57865433")
        locationUid.add("08976545")
        locationUid.add("87654434")
        locationUid.add("45366573")
        locationUid.add("74664334")
        locationUid.add("973487t6")

        // hike date
        hikeDate.add("12/03/2016")
        hikeDate.add("12/03/2016")
        hikeDate.add("12/03/2016")
        hikeDate.add("14/03/2016")
        hikeDate.add("12/04/2016")
        hikeDate.add("12/07/2016")
        hikeDate.add("12/01/2016")
        hikeDate.add("12/09/2016")
        hikeDate.add("12/02/2016")
        hikeDate.add("12/01/2016")

        //ScheduleInviteCell

        self.hikeScheduleListTableView.reloadData()
        //self.navigationController?.popToRootViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Controller Table View
    // Getting the number of rows in locationName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationName.count
    }
    
    // populates and sets the custom cell element
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleViewCell
        cell.scheduleTitle.text = self.locationName.object(at: indexPath.row) as? String
        cell.scheduleTime.text = self.hikeDate.object(at: indexPath.row) as? String
        
        cell.viewScheduleButton.tag = indexPath.row
        cell.viewScheduleButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)
        return cell
    }
    
    // specifies the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let name = self.locationName.object(at: indexPath.row) as? String
        let ui = self.locationUid.object(at: indexPath.row) as? String

        
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
        
        let index = locationName[sender.tag];
        
       // self.locationName.removeObject(at: sender.tag)
       // self.locationUid.removeObject (at: sender.tag)
        
        self.hikeScheduleListTableView.reloadData()
        
        print("indexis = \(index)")
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
    
    //Appending schedule to object collection
    func poplateSingleSchedule(key: String, value: [String: AnyObject]){
        
        let name = value["name"] as? String ?? ""
        
            locationName.add(name)
            locationUid.add(key)
        
        //refreshing table after populating collection
        self.hikeScheduleListTableView.reloadData()
    }
    
    //populating schedule
    func populateList(){
        
        //getting logged schedule's uid
        let hikeScheduleId = "DPpwfIDhAGXpFjFqI3BytLMrAA73"
        
        //getting schedule
        self.ref.child("walkingSchedules")
            .queryOrderedByKey()
            .queryEqual(toValue: hikeScheduleId)
            .observe(
                .childAdded, with: { (snapshot) in
                    
                    let value = snapshot.value as? [String: AnyObject]

                    if value != nil{
                        
                        self.poplateSingleSchedule(key: snapshot.key, value: value!)
                    }
                    
            }) { (error) in
                print(error.localizedDescription)
        }
    }

}
    
    

