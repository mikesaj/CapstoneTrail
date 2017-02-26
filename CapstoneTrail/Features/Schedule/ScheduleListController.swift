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
    
    // Database reference
    let ref = FIRDatabase.database().reference()
    
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
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")
        locationUid.add("WestMount Walks")

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
    
    // prepare to launch segue with data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "View2"){
            
            var coming: ScheduleProfileController = segue.destination as! ScheduleProfileController
            
            coming.scheduleTitle = ""
            coming.uid = ""
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
    
    

