//
//  HikeGroupViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-16.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class HikeGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Current user id
    let uid = FIRAuth.auth()?.currentUser?.uid
    var usergroups = [GroupModel]()
    var groupData = GroupModel()

    @IBOutlet weak var groupsTableView: UITableView!
    
    // demo data
    var GroupName    = "Pinky Baby's Team"
    var locationName = "Waterloo Ontario"
    var memberCount  = 3
    var groupid      = "235467890-98765434-3234u73434-2432342"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserGroups(userId: uid!)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Controller Table View
    // Getting the number of rows in firendName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.usergroups.count)
        return self.usergroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupListCell", for: indexPath) as! GroupListViewCell
        
        cell.groupName.text = self.usergroups[indexPath.row].name
        cell.groupLocation.text = self.usergroups[indexPath.row].locationName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //get selected row data
        groupData = usergroups[indexPath.row]
        
        // launch segue for row
        performSegue(withIdentifier: "groupProfile", sender: self)
        
        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Saj's here2")
        if(segue.identifier == "groupProfile"){
            
            let coming: GroupProfileViewController = segue.destination as! GroupProfileViewController
            
            coming.GroupName    = groupData.name!
            coming.GroupDescrip = groupData.groupDescription!
            coming.locationName = groupData.locationName!
            coming.memberCount  = groupData.members.count
            coming.groupid      = groupData.uid!
        }

    }
     
    // Firebase reference instance
    let ref = FIRDatabase.database().reference()
    
    // get user's group list
    func getUserGroups(userId: String){
        
        var userGroupIds = [String]()
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    
                    if value?["groups"] != nil {
                        
                        // get user's group list
                        userGroupIds = (value?["groups"]        as? [String])!
                        
                        
                        for gid in userGroupIds {

                            _ = self.ref.child("groups")
                                .queryOrderedByKey()
                                .queryEqual(toValue: gid)
                                .observe(.childAdded, with: { (snapshot) in
                                
                                let value = snapshot.value as? [String: AnyObject]
                                
                                if value != nil{
                                    let group = GroupModel()
                                    
                                    group.uid               = snapshot.key
                                    group.name              = value?["name"]            as? String
                                    group.locationName      = value?["locationName"]    as? String
                                    group.groupDescription  = value?["description"]as? String
                                    group.members           = (value?["members"]        as? [String])!
                                    group.owneruid          = value?["owneruid"]        as? String
                                    group.isPublic          = value?["isPublic"]        as? Bool
                                    group.latitude          = value?["latitude"]        as? String
                                    group.longitude         = value?["longitude"]       as? String
                                    
                                    print(group.groupDescription ?? "--")
                                    self.usergroups.append(group)
                                    self.groupsTableView.reloadData()
                                }
                                
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                            
                            
                        }
                        
                    }// if [groups]
                    
                    
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    

    
}
