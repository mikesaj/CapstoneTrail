//
//  FriendsViewController.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-18.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //declaring tableView
    var tableView: UITableView = UITableView()
    
    //search bar for being added to table view
    let searchController = UISearchController(searchResultsController: nil)
    
    //identifier for each cell in the table
    let cellId = "cellId"
    
    //collection of all users in the table
    var users = [User]()
    
    //collection of all searched users
    var usersSearched = [User]()
    
    //collection of logged user's friendships
    var friends = [Friend]()
    
    // Database reference
    let ref = FIRDatabase.database().reference()
    
    func createSearchbar(){        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    //method responsible for handling searches
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String)
    {
        //if there is no search, table gets the initial data
        if textSearched == ""{
            usersSearched = users
        }
        else {
            
            usersSearched.removeAll()
            
            for u in users {
                
                //search for first name
                if u.name?.startsWith(string: textSearched) == true {
                    self.usersSearched.append(u)
                    continue
                }
                
                //search for last name
                let fullName = u.name?.components(separatedBy: " ")
                if (fullName?.count)! > 1{
                    var lastName: String = fullName![1]
                    
                    if lastName.startsWith(string: textSearched) == true {
                        self.usersSearched.append(u)
                        continue
                    }
                }
                
                //search for email
                if u.email?.startsWith(string: textSearched) == true {
                    self.usersSearched.append(u)
                }
            }
        }
        
        //order by friend situation
        self.usersSearched = self.usersSearched.sorted { $0.0.isFriendRequested == true }
        //refresh the table
        self.tableView.reloadData()
    }
    
    
    //method responsible for canceling searches
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //table turns to the initial data
        self.usersSearched = self.users
        //order by friend situation
        self.usersSearched = self.usersSearched.sorted { $0.0.isFriendRequested == true }
        //refresh the table
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        //TableView Settings
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        tableView.frame = CGRect(x: 0, y: 30, width: screenWidth, height: screenHeight)
        tableView.dataSource = self
        tableView.delegate = self
        
        //populating table with friendships data
        fetchUsers()
        
        //registering table with our custom UITableViewCell
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //adding searchbar to table view
        createSearchbar()
        
        //Adding tableView object to the View
        self.view.addSubview(tableView)
        
        //creating a cancel button on the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
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
                    
                        //Appending user object to collections
                        self.users.append(user)
                        self.usersSearched.append(user)
                        
                        //order by friend situation
                        self.usersSearched = self.usersSearched.sorted { $0.0.isFriendRequested == true }
                        
                        //refreshing table after populating collection
                        self.tableView.reloadData()
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
    func populateFriends(){
        
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
    
    //method for resizing cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    //method to close the controller
    func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    //setting table size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSearched.count
    }
    
    //setting values from the collection to table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //retreiving current cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        //getting collection item from current row index
        let user = usersSearched[indexPath.row]
        
        //setting button visibility 
        cell.addFriendButton.isHidden = true
        cell.acceptButton.isHidden = true
        
        //setting value to the cell
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        //Adding targets(methods when the user clicks on the object) for each object in the cell
        //Passing the friend_uid through the method setTitle()
        cell.rejectButton.setTitle(user.uid!, for: .normal)
        cell.rejectButton.addTarget(self, action: #selector(rejectFriend), for: .touchUpInside)
        
        cell.blockButton.setTitle(user.uid!, for: .normal)
        cell.blockButton.addTarget(self, action: #selector(blockFriend), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewProfileFriend(tapGestureRecognizer:)))
        tapGestureRecognizer.accessibilityHint = user.uid
        cell.profileImageView.isUserInteractionEnabled = true
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)
        //END --> Adding targets(methods when the user clicks on the object) for each object in the cell
        
        //Displaying user profile image
        //if the user does not have image, then set to him the default image
        if user.profileImageUrl == nil {
            cell.profileImageView.image = UIImage(named: "user")
            return cell;
        }
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        //END --> Displaying user profile image
        
        return cell
    }
    
    //calling profile controller to view the friend profile page
    func viewProfileFriend(tapGestureRecognizer: UITapGestureRecognizer){
        
        //dispose searchController, otherwise get error
        self.searchController.dismiss(animated: true, completion: nil)
        
        //getting friend uid for passing to profile page
        let friend_uid = tapGestureRecognizer.accessibilityHint
        
        //creating profile controller object
        let profileController = ViewController()
        
        //passing friend uid to profile page
        profileController.friend_uid = friend_uid
        
        //calling profile page
        self.present(profileController, animated: true, completion: nil)
    }
    
    func rejectFriend(sender:UIButton){
        
        self.updateFriend(friend_uid: (sender.titleLabel?.text!)!, isToblock: false)
    }
    
    func blockFriend(sender:UIButton){
        
        self.updateFriend(friend_uid: (sender.titleLabel?.text!)!, isToblock: true)
    }
    
    //method for handling user actions for friends
    func updateFriend(friend_uid: String, isToblock: Bool){
        
        var friendship_uid = ""
        
        var i = 0
        
        //getting in the user collection the friendship_uid value
        //removing friend from user collection
        for t in stride(from: 0, through: self.users.count, by: 1) {
            
            if(self.users[i].uid == friend_uid){
                friendship_uid = self.users[i].friendship_uid!
                self.users.remove(at: i)
                break
            }
            
            i += 1
        }
        
        i = 0
        
        //removing friend from usersSearched collection
        //refreshing table after updating collections
        for _ in stride(from: 0, through: self.usersSearched.count, by: 1) {
            
            if(self.usersSearched[i].uid == friend_uid){
                
                self.usersSearched.remove(at: i)
                self.tableView.reloadData()
                break
            }
            
            i += 1
        }
        
        //getting collection reference from database
        let friendsReference = ref.child("friends").child(friendship_uid)
        
        //blocking friend
        if isToblock == true {
            friendsReference.child("isBlocked").setValue(true)
        }
        else{
            //remove friendship
            friendsReference.removeValue()
        }
    }

}
