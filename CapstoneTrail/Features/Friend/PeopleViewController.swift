//
//  PeopleViewController.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-09.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class PeopleViewController: UITableViewController, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var usersSearched = [User]()
    
    func createSearchbar(){
        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        //searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
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
                var isFriendRequested: Bool = false
                var friendship_uid: String = ""
                
                if friends.count > 0 {
                    
                    var i = 0
                    
                    for t in stride(from: 0, through: friends.count - 1, by: 1) {
                        
                        if(friends[i].receiver_uid == snapshot.key){
                            isFriend = true
                            break
                        }
                        
                        if(friends[i].sender_uid == snapshot.key){
                            
                            if(friends[i].isBlocked == true){
                                isFriend = true
                                break
                            }
                            
                            if friends[i].isAccepted == false {
                                friendship_uid = friends[i].uid!
                                isFriendRequested = true
                            }
                            else{
                                isFriend = true
                            }
                            
                            break
                        }
                        
                        i += 1
                    }
                    
                }
                
                if isFriend == false{
                    
                    let user = User()
                
                    user.uid = snapshot.key
                    user.email = dictionary["email"] as? String
                    user.name = dictionary["name"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    user.isFriendRequested = isFriendRequested
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSearched.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = usersSearched[indexPath.row]
        
        cell.addFriendButton.isHidden = false
        cell.acceptButton.isHidden = true
        cell.rejectButton.isHidden = true
        cell.blockButton.isHidden = true
        
        if user.isFriendRequested == true{
            cell.acceptButton.isHidden = false
            cell.rejectButton.isHidden = false
            cell.blockButton.isHidden = false
            cell.addFriendButton.isHidden = true
        }
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        cell.addFriendButton.setTitle(user.uid!, for: .normal)
        cell.addFriendButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        
        cell.acceptButton.setTitle(user.uid!, for: .normal)
        cell.acceptButton.addTarget(self, action: #selector(acceptFriend), for: .touchUpInside)
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func viewProfileFriend(tapGestureRecognizer: UITapGestureRecognizer){
        
        self.searchController.dismiss(animated: true, completion: nil)
        
        let friend_uid = tapGestureRecognizer.accessibilityHint
        
        let profileController = ViewController()
        profileController.friend_uid = friend_uid
        
        self.present(profileController, animated: true, completion: nil)
    }
    
    func acceptFriend(sender:UIButton){
        
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
        friendsReference.child("isAccepted").setValue(true)
        
        //let usersReference = ref.child("users").child(uid)
        //usersReference.child("friends").child(friendship_uid).child("uid").setValue(friend_uid)
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
    
    func addFriend(sender:UIButton){
        
        guard let user = FIRAuth.auth()?.currentUser else { return }
        let uid = user.uid
        
        let friend_uid = sender.titleLabel?.text
        
        let ref = FIRDatabase.database().reference()
        
        let friendship_uid = UUID().uuidString
        
        let friendsReference = ref.child("friends").child(friendship_uid)
        
        friendsReference.child("sender_uid").setValue(uid)
        friendsReference.child("receiver_uid").setValue(friend_uid)
        friendsReference.child("isAccepted").setValue(false)
        friendsReference.child("isBlocked").setValue(false)
                
        var i = 0
                
        for t in stride(from: 0, through: self.users.count, by: 1) {
                    
            if(self.users[i].uid == friend_uid){
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
                return
            }
                    
            i += 1
        }
        
    }
}

class UserCell: UITableViewCell{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let addFriendImage = UIImage(named: "addFriend")! as UIImage
    
    let addFriendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return button
    }()
    
    let acceptImage = UIImage(named: "accept.ico")! as UIImage
    
    let acceptButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return button
    }()
    
    let rejectImage = UIImage(named: "reject.ico")! as UIImage
    
    let rejectButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return button
    }()
    
    let blockImage = UIImage(named: "block.ico")! as UIImage
    
    let blockButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addFriendButton.setImage(addFriendImage, for: .normal)
        acceptButton.setImage(acceptImage, for: .normal)
        rejectButton.setImage(rejectImage, for: .normal)
        blockButton.setImage(blockImage, for: .normal)
        
        addSubview(profileImageView)
        addSubview(addFriendButton)
        addSubview(acceptButton)
        addSubview(rejectButton)
        addSubview(blockButton)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addFriendButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        addFriendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addFriendButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        acceptButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -90).isActive = true
        acceptButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        acceptButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        rejectButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -50).isActive = true
        rejectButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        rejectButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rejectButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        blockButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        //blockButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        blockButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -4).isActive = true
        blockButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        blockButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



