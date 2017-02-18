//
//  FriendsViewController.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-18.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UITableViewController, UISearchBarDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var usersSearched = [User]()
    
    func createSearchbar(){
        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String)
    {
        if textSearched == ""{
            usersSearched = users
        }
        else {
            
            usersSearched.removeAll()
            
            for u in users {
                
                if u.name?.startsWith(string: textSearched) == true {
                    self.usersSearched.append(u)
                    continue
                }
                
                if u.email?.startsWith(string: textSearched) == true {
                    self.usersSearched.append(u)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        usersSearched = users
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        createSearchbar()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    func fetchUsers(){
        
        let ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        var friends = [Friend]()
        
        ref.child("friends").queryOrdered(byChild: "sender_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                
                let friend = Friend()
                
                friend.uid = snapshot.key
                friend.sender_uid = value?["sender_uid"] as? String
                friend.receiver_uid = value?["receiver_uid"] as? String
                friend.isAccepted = value?["isAccepted"] as? Bool
                friend.isBlocked = value?["isBlocked"] as? Bool
                
                friends.append(friend)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                
                let friend = Friend()
                
                friend.uid = snapshot.key
                friend.sender_uid = value?["sender_uid"] as? String
                friend.receiver_uid = value?["receiver_uid"] as? String
                friend.isAccepted = value?["isAccepted"] as? Bool
                friend.isBlocked = value?["isBlocked"] as? Bool
                
                friends.append(friend)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                var isFriend: Bool = false
                var friendship_uid: String = ""
                
                if friends.count > 0 {
                    
                    var i = 0
                    
                    for t in stride(from: 0, through: friends.count - 1, by: 1) {
                        
                        if((friends[i].receiver_uid == snapshot.key || friends[i].sender_uid == snapshot.key) &&
                            friends[i].isAccepted == true && friends[i].isBlocked == false){
                            
                            friendship_uid = friends[i].uid!
                            isFriend = true
                            break
                        }
                        
                        i += 1
                    }
                    
                }
                
                if isFriend == true{
                    
                    let user = User()
                    
                    user.uid = snapshot.key
                    user.email = dictionary["email"] as? String
                    user.name = dictionary["name"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    user.friendship_uid = friendship_uid
                    
                    let emailCurrentUser = FIRAuth.auth()?.currentUser?.email
                    
                    if user.email?.lowercased() != emailCurrentUser?.lowercased() {
                        
                        self.users.append(user)
                        self.usersSearched.append(user)
                        
                        self.usersSearched = self.usersSearched.sorted { $0.0.isFriendRequested == true }
                        self.tableView.reloadData()
                    }
                }
            }
            
            }, withCancel: nil)
        
    }
    
    func handleCancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSearched.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = usersSearched[indexPath.row]
        
        cell.addFriendButton.isHidden = true
        cell.acceptButton.isHidden = true
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        cell.rejectButton.setTitle(user.uid!, for: .normal)
        cell.rejectButton.addTarget(self, action: #selector(rejectFriend), for: .touchUpInside)
        
        cell.blockButton.setTitle(user.uid!, for: .normal)
        cell.blockButton.addTarget(self, action: #selector(blockFriend), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewProfileFriend(tapGestureRecognizer:)))
        tapGestureRecognizer.accessibilityHint = user.uid
        cell.profileImageView.isUserInteractionEnabled = true
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if user.profileImageUrl == nil {
            cell.profileImageView.image = UIImage(named: "user")
            return cell;
        }
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    func rejectFriend(sender:UIButton){
        let friend_uid = sender.titleLabel?.text
        
        var friendship_uid = ""
        
        var i = 0
        
        for t in stride(from: 0, through: self.users.count, by: 1) {
            
            if(self.users[i].uid == friend_uid){
                friendship_uid = self.users[i].friendship_uid!
                self.users.remove(at: i)
                break
            }
            
            i += 1
        }
        
        i = 0
        
        for _ in stride(from: 0, through: self.usersSearched.count, by: 1) {
            
            if(self.usersSearched[i].uid == friend_uid){
                
                self.usersSearched.remove(at: i)
                self.tableView.reloadData()
                break
            }
            
            i += 1
        }
        
        let ref = FIRDatabase.database().reference()
        
        let friendsReference = ref.child("friends").child(friendship_uid)
        
        friendsReference.removeValue()
    }

    
    func viewProfileFriend(tapGestureRecognizer: UITapGestureRecognizer){
        let friend_uid = tapGestureRecognizer.accessibilityHint
        let profileController = ViewController()
        self.present(profileController, animated: true, completion: nil)
    }
    
    func blockFriend(sender:UIButton){
        
        let friend_uid = sender.titleLabel?.text
        
        var friendship_uid = ""
        
        var i = 0
        
        for t in stride(from: 0, through: self.users.count, by: 1) {
            
            if(self.users[i].uid == friend_uid){
                friendship_uid = self.users[i].friendship_uid!
                self.users.remove(at: i)
                break
            }
            
            i += 1
        }
        
        i = 0
        
        for _ in stride(from: 0, through: self.usersSearched.count, by: 1) {
            
            if(self.usersSearched[i].uid == friend_uid){
                
                self.usersSearched.remove(at: i)
                self.tableView.reloadData()
                break
            }
            
            i += 1
        }
        
        
        let ref = FIRDatabase.database().reference()
        
        let friendsReference = ref.child("friends").child(friendship_uid)
        friendsReference.child("isBlocked").setValue(true)
    }

}
