//
//  WalkingScheduleViewController.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class WalkingScheduleViewController: UITableViewController {
    
    let cellId = "cellId"
    
    let ref = FIRDatabase.database().reference()
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    var schedules = [WalkingShedule]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchShecules()
        
        tableView.register(WalkingSheduleCell.self, forCellReuseIdentifier: cellId)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
    }
    
    func fetchShecules(){
        
        ref.child("walkingSchedules").child(userID!).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let schedule = WalkingShedule()
                    
                schedule.trail_id = snapshot.key
                schedule.trail = dictionary["trail"] as? String
                schedule.date = dictionary["date"] as? String
                        
                self.schedules.append(schedule)
                self.tableView.reloadData()
            }
            
            }, withCancel: nil)
        
    }
    
    func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WalkingSheduleCell
        
        let schedule = schedules[indexPath.row]
        
        cell.textLabel?.text = schedule.trail
        cell.detailTextLabel?.text = "Date: " + schedule.date!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}

class WalkingSheduleCell: UITableViewCell{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
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

