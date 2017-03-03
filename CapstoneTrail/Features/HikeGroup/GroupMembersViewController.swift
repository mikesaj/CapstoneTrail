//
//  GroupMembersViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class GroupMembersViewController: UITableViewController {

    // Database reference
    let ref = FIRDatabase.database().reference()
    
    var friendName: NSMutableArray! = NSMutableArray()
    var friendId:   NSMutableArray! = NSMutableArray()
    var owneruid: String = ""
    var groupUid: String = ""
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.populateMembers(groupUid: groupUid)
        super.viewWillAppear(animated) // No need for semicolon
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = UITableViewCell()
        cell.textLabel?.text = friendName.object(at: indexPath.row) as? String
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         index = indexPath.row

        // deselect the selected cell background view.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // launch segue
        performSegue(withIdentifier: "member", sender: self)
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // ViewFriendViewController
        if(segue.identifier == "member"){
            
            let viewFriendController: ViewFriendViewController = segue.destination as! ViewFriendViewController
            
            // Passing parameters to the inviteFriendsController class
            viewFriendController.groupid     = self.groupUid             // id of the group
            viewFriendController.owneruid    = self.owneruid             // id of the owneruid
            viewFriendController.memberId    = (self.friendId.object(at: index) as? String)!// ids of member
            viewFriendController.titleString = (self.friendName.object(at: index) as? String)!// ids of member
        }

    }
 
    
    //populating group members data
    func populateMembers(groupUid: String){
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupUid)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    // gets group owner id
                    self.owneruid = (value?["owneruid"] as? String)!
                    print("\(self.owneruid) iwnerid")
                    let members = (value?["members"] as? [String])!
                    for memberId in members {
                        
                        
                        _ = self.ref.child("users")
                            .queryOrderedByKey()
                            .queryEqual(toValue: memberId)
                            .observe(.childAdded, with: { (snapshot) in
                                
                                let value = snapshot.value as? [String: AnyObject]
                                
                                if value != nil{
                                    
                                    self.friendName.add(value?["name"])
                                    self.friendId.add(snapshot.key)
                                    
                                    self.tableView.reloadData()

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
