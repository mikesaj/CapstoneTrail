//
//  inviteFriendsController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class inviteFriendsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var friendListTableView: UITableView!
    
    var firendName: NSMutableArray! = NSMutableArray()
    var firenduid:  NSMutableArray! = NSMutableArray()
    
    var groupid = "default"
    
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
        fetchUsers()
        
        super.viewDidLoad()
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

        cell.friendName.text = self.firendName.object(at: indexPath.row) as? String
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        let titleString = self.firendName.object(at: indexPath.row) as? String
        
        // redirect to storyboard
        let myVC = storyboard?.instantiateViewController(withIdentifier: "showView") as! ViewFriendViewController
        myVC.titleString = titleString

        //allows navigation appear
        navigationController?.pushViewController(myVC, animated: true)

        
        //performSegue(withIdentifier: "showView", sender: self)
    }
    
    @IBAction func logAction(sender: UIButton){
        
        //let index = firendName[sender.tag] as! String
        let userId = firenduid[sender.tag] as! String
        
        self.firendName.removeObject(at: sender.tag)
        self.firenduid.removeObject (at: sender.tag)
        
        // add user to group method
        groupdDb.addUsertoGroup(groupId: self.groupid, userId: userId)
        
        // reload tableview
        self.friendListTableView.reloadData()
    }
    
    
    
    func fetchUsers(){
        
        //populating existing friendships
        self.populateFriends()
        
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
                        
                        //refreshing table after populating collection
                        self.firendName.add(user.name!)
                        //self.firendemail.add(user.email!)
                        self.firenduid.add(user.uid!)

                        //Appending user object to collections
                        self.friendListTableView.reloadData()
                        //self.tableView.reloadData()
                    }
                }
            }
            
        }, withCancel: nil)
        
    }
    
    
    //Appending friendship to friend collection
    func poplateSingleFriend(key: String, value: [String: AnyObject]){
        
        let name = value["name"] as? String ?? ""
        
        // if friendship is accepted
        if !friendHash.contains(name) {
            
            friendHash.insert(name)
            
            firendName.add(name)
            firenduid.add(key)
        
            //refreshing table after populating collection
            self.friendListTableView.reloadData()
        }
    }
    
    //populating logged is user's friendships
    func populateFriends(){
        
        //getting friendships where the logged user was the sender
        ref.child("friends").queryOrdered(byChild: "sender_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                //self.poplateSingleFriend(key: snapshot.key, value: value!)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        //getting friendships where the logged user was the receiver
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                

                //getting friendships where the logged user was the sender
                self.ref.child("users").queryOrderedByKey()
                    .queryEqual(toValue: value?["sender_uid"])
                    .observe(.childAdded, with: { (snapshot1) in
                    

                    let value1 = snapshot1.value as? [String: AnyObject]
                    
                    if value1 != nil{
                        
                        //print( value1!["name"] as? String ?? "" )
                        self.poplateSingleFriend(key: snapshot1.key, value: value1!)
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }

            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    

    
}


//Represents the friends collection of the database
class Friend: NSObject {
    
    var uid: String?
    var sender_uid: String?
    var receiver_uid: String?
    var isAccepted: Bool?
    var isBlocked: Bool?
}

