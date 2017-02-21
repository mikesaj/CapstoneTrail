//
//  ViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 7..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class ViewController: UIViewController {
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.white
        tf.placeholder = "E-mail"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.red
        button.setTitle("Delete Account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        
        return button
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    
    lazy var updateButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(updateAccount), for: .touchUpInside)
        
        return button
    }()
    
    lazy var peopleButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("Add Friends", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(addFriends), for: .touchUpInside)
        
        return button
    }()
    
    lazy var friendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("My Friends", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(myFriends), for: .touchUpInside)
        
        return button
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("Log Out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        return button
    }()
    
    lazy var myProfileButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("My Profile", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(populateMyProfile), for: .touchUpInside)
        
        return button
    }()
    
    lazy var walkingScheduleButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor.blue
        button.setTitle("Walking Schedule", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(populateWalkingSchedule), for: .touchUpInside)
        
        return button
    }()
    
    var friend_uid: String! = nil

    override func viewDidLoad() {
    super.viewDidLoad()
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(profileImageView)
        view.addSubview(logoutButton)
        view.addSubview(peopleButton)
        view.addSubview(emailTextField)
        view.addSubview(updateButton)
        view.addSubview(deleteButton)
        view.addSubview(friendButton)
        view.addSubview(myProfileButton)
        view.addSubview(walkingScheduleButton)
        
        setupPeopleButton()
        setupLogoutButton()
        setupProfileImageView()
        setupEmailTextField()
        setupUpdateButton()
        setupDeleteButton()
        setupFriendButton()
        setupMyProfileButton()
        setupWalkingScheduleButton()
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            populateUserInfo();
        }
    }
    
    func checkUserGmail(uid: String){
        
            let userImage = UIImage(named: "user")
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(uid).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(userImage!, 0.1){
                
                storageRef.put(uploadData, metadata: nil, completion: { (metada, error) in
                    
                    if error != nil{
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metada?.downloadURL()?.absoluteString {
                        
                        let ref = FIRDatabase.database().reference(fromURL: "https://capstoneproject-54304.firebaseio.com/")
                        
                        let userReference = ref.child("users").child(uid)
                        
                        let email = GIDSignIn.sharedInstance().currentUser?.profile.email
                        let name = GIDSignIn.sharedInstance().currentUser?.profile.name
                        
                        userReference.child("name").setValue(name)
                        userReference.child("email").setValue(email)
                        userReference.child("profileImageUrl").setValue(profileImageUrl)
                        
                        self.navigationItem.title = name
                        self.emailTextField.text = email
                        
                        let url = profileImageUrl as! String?
                        
                        if let profileUrl = url {
                            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileUrl)
                        }
                        
                    }
                    
                })
        }
    }
    
    func populateUserInfo(){
        
        guard var uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        if friend_uid != nil {
            uid = friend_uid
            
            self.myProfileButton.isHidden = false
            
            self.updateButton.isHidden = true
            self.deleteButton.isHidden = true
            self.friendButton.isHidden = true
            self.peopleButton.isHidden = true
            self.walkingScheduleButton.isHidden = true
        }
        else{
            self.myProfileButton.isHidden = true
            
            self.updateButton.isHidden = false
            self.deleteButton.isHidden = false
            self.friendButton.isHidden = false
            self.peopleButton.isHidden = false
            self.walkingScheduleButton.isHidden = false
            
            self.checkFriendRequests(userID: uid)
        }
        
        if friend_uid == nil && GIDSignIn.sharedInstance().currentUser?.profile.email != nil{
            self.checkUserGmail(uid: uid)
        }
        else{
            
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
                if let dic = snapshot.value as? [String: AnyObject] {
                
                    self.navigationItem.title = dic["name"] as! String?
                    let value = dic["email"] as! String?
                    self.emailTextField.text = value!
                
                    let url = dic["profileImageUrl"] as! String?
                
                    if let profileImageUrl = url {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            
            })
        }
    }
    
    func updateAccount(){
        
        let user = FIRAuth.auth()?.currentUser
        
        user?.updateEmail(emailTextField.text!, completion: { (error) in
            if  error != nil {
                print("Erro to try to update account")
            }else{
            }
        })
        
        guard let uid = user?.uid else{
            return;
        }
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(uid).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
            
            storageRef.put(uploadData, metadata: nil, completion: { (metada, error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                if let profileImageUrl = metada?.downloadURL()?.absoluteString {
                    
                    let ref = FIRDatabase.database().reference()
                    let usersReference = ref.child("users").child(uid)
                    usersReference.child("profileImageUrl").setValue(profileImageUrl)
                    
                    let alert = UIAlertController(title: "Update account", message: "Account was updated succefully", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            })
        }
    }
    
    func deleteAccount(){
        
        let user = FIRAuth.auth()?.currentUser
        
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child((user?.uid)!)
        userReference.removeValue()
        
        user?.delete(completion: { (error) in
            
            if  error != nil {
                print("Erro to try to delete account")
            }else{
                
                GIDSignIn.sharedInstance().signOut()
                
                FBSDKLoginManager().logOut()
                
                let loginController = LoginController()
                self.present(loginController, animated: true, completion: nil)
                
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    func checkFriendRequests(userID: String){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                
                let isAccepted = value?["isAccepted"] as? Bool
                let isBlocked = value?["isBlocked"] as? Bool
                
                if isAccepted == false && isBlocked == false {
                    let alert = UIAlertController(title: "Warning", message: "You have new friend request(s)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                
                    return
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
