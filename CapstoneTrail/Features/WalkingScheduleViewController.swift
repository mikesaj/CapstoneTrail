//
//  WalkingScheduleViewController.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class WalkingScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //declaring tableView
    var tableView: UITableView = UITableView()
    
    //identifier for each cell in the table
    let cellId = "cellId"
    
    // Database reference
    let ref = FIRDatabase.database().reference()
    
    //id of the user logged in
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    //collection of walking schedule
    var schedules = [WalkingShedule]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        //creating a cancel button on the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        //TableView Settings
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        tableView.frame = CGRect(x: 0, y: 15, width: screenWidth, height: screenHeight)
        tableView.dataSource = self
        tableView.delegate = self
        
        //populating table with walking schedule data
        fetchShecules()
        
        //registering table with our custom UITableViewCell
        tableView.register(WalkingSheduleCell.self, forCellReuseIdentifier: cellId)
        
        //Adding tableView object to the View
        self.view.addSubview(tableView)
    }
    
    func fetchShecules(){
        
        //retreiving data from database
        ref.child("walkingSchedules").child(userID!).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let schedule = WalkingShedule()
                
                //Assigning retrieved values to the schedule object
                schedule.trail_id = snapshot.key
                schedule.trail = dictionary["trail"] as? String
                schedule.date = dictionary["date"] as? String
                
                //Appending shedule object to collection
                self.schedules.append(schedule)
                
                //refreshing table after populating collection
                self.tableView.reloadData()
            }
            
            }, withCancel: nil)
        
    }
    
    //method to close the controller
    func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    //setting table size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    
    //setting values from the collection to table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //retreiving current cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WalkingSheduleCell
        
        //getting collection item from current row index
        let schedule = schedules[indexPath.row]
        
        //setting value to the cell
        cell.textLabel?.text = schedule.trail
        cell.detailTextLabel?.text = "Date: " + schedule.date!
        
        return cell
    }
    
    //method for resizing cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}

//custom  UITableViewCell class
class WalkingSheduleCell: UITableViewCell{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //setting layout for text and detail fields
        textLabel?.frame = CGRect(x: 20, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 20, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

