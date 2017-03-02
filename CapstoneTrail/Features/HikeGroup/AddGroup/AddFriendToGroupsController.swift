//
//  inviteFriendsController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class AddFriendToGroupsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var friendListTableView: UITableView!
    
    var firendName: NSMutableArray! = NSMutableArray()
    var firenduid:  NSMutableArray! = NSMutableArray()
    
    var groupid      = "default"
    var groupOwnerid = ""
    var GroupMembers : [String] = []
    
    // Database reference
    let ref = FIRDatabase.database().reference()
    
    // Get's logged user's uid
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    //collection of accepted user's friendships
    var friends = [Friend]()
    var friendHash = Set<String>()
    
    // instantiating group db data model
    let groupdDb = GroupDBController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUsers()
        super.viewWillAppear(animated) // No need for semicolon
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Controller Table View
    // Getting the number of rows in firendName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firendName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let idOfFriend   = self.firenduid.object(at: indexPath.row) as? String
        let nameOfFriend = self.firendName.object(at: indexPath.row) as? String
        
        cell.friendName.text = nameOfFriend
        cell.addToGroupButton.tag = indexPath.row
        
        /* Generates friends list */
        // highlights users already in group
        if GroupMembers.contains(idOfFriend!) {
            
            cell.addToGroupButton.setTitle("Added", for: UIControlState.normal)
            cell.addToGroupButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
            cell.addToGroupButton.isEnabled = false
        }
        else {
            // highlights users not yet in group
            cell.addToGroupButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        let titleString  = self.firendName.object(at: indexPath.row) as? String
        let idOfFriend   = self.firenduid.object(at: indexPath.row) as? String
        
        // redirect to storyboard
        let myVC = storyboard?.instantiateViewController(withIdentifier: "showView") as! ViewFriendViewController
        myVC.titleString = titleString!
        myVC.memberId    = idOfFriend!
        myVC.groupid     = self.groupid
        myVC.owneruid    = self.groupOwnerid

        // allows navigation appear
        navigationController?.pushViewController(myVC, animated: true)

        // deselect the selected cell background view.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // performSegue(withIdentifier: "showView", sender: self)
    }
    
    @IBAction func logAction(sender: UIButton){
        
        //let index = firendName[sender.tag] as! String
        let userId = firenduid[sender.tag] as! String
        
        // add user to group method
        groupdDb.addUsertoGroup(groupId: self.groupid, userId: userId)
        
        // new user added to group
        GroupMembers.append(userId)
        
        // reload tableview
        self.friendListTableView.reloadData()
    }
    
    
    
    func fetchUsers(){
        
        //populating existing friendships
         self.populateFriends1()
        
        //getting the logged user's email
        let emailLoggedUser = FIRAuth.auth()?.currentUser?.email
        
        //getting all users from database
        //**** TODO: we need to define criteria for seaching users from database
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                var isFriend: Bool = false
                var friendship_uid: String = ""
                
                if self.friends.count > 0 {
                    
                    var i = 0
                    
                    for t in stride(from: 0, through: self.friends.count - 1, by: 1) {
                        
                        //checking if the user made any friendhip request AND it has been accepted AND it has NOT been blocked
                        if((self.friends[i].receiver_uid == snapshot.key || self.friends[i].sender_uid == snapshot.key) &&
                            self.friends[i].isAccepted == true && self.friends[i].isBlocked == false){
                            
                            friendship_uid = self.friends[i].uid!
                            isFriend = true
                            break
                        }
                        
                        i += 1
                    }
                    
                }
                
                if isFriend == true{
                    
                    let email = dictionary["email"] as? String
                    
                    //checking is the user logged is the current user
                    if email?.lowercased() != emailLoggedUser?.lowercased() {
                        
                        let user = User()
                        
                        //Assigning retrieved values to the user object
                        user.uid = snapshot.key
                        user.email = dictionary["email"] as? String
                        user.name = dictionary["name"] as? String
                        user.profileImageUrl = dictionary["profileImageUrl"] as? String
                        user.friendship_uid = friendship_uid
                        
                        // get list of user's friends and append object's to collection
                        if self.friendHash.contains(user.uid!) == false{
                            self.friendHash.insert(user.uid!)
                            
                            self.firendName.add(user.name!)
                            self.firenduid.add(user.uid!)
                        
                        //refreshing table after populating collection
                            self.friendListTableView.reloadData()
                        }
                    }
                }
            }
            
        }, withCancel: nil)
        
    }
    
    
    //Appending friendship to friend collection
    func poplateSingleFriend(key: String, value: [String: AnyObject]){
        
        let friend = Friend()
        
        friend.uid = key
        friend.sender_uid = value["sender_uid"] as? String
        friend.receiver_uid = value["receiver_uid"] as? String
        friend.isAccepted = value["isAccepted"] as? Bool
        friend.isBlocked = value["isBlocked"] as? Bool
        
        self.friends.append(friend)
        
    }
    
    
    //populating logged is user's friendships
    func populateFriends1(){
        
        //getting logged user's uid
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //getting friendships where the logged user was the sender
        ref.child("friends").queryOrdered(byChild: "sender_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                
                self.poplateSingleFriend(key: snapshot.key, value: value!)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //getting friendships where the logged user was the receiver
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{

                self.poplateSingleFriend(key: snapshot.key, value: value!)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }


    
}


