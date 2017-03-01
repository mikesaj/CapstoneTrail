//
//  SettingsController.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-02-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

import Firebase
import FBSDKLoginKit
import GoogleSignIn

class SettingsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var friend_uid: String! = nil
    // Declares a table view in the update profile layout-view
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnUpdateProfile: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtName.isHidden = true
        self.btnSave.isHidden = true
        self.btnCancel.isHidden = true
        
        self.profileImageView.layer.cornerRadius = 68
        self.profileImageView.layer.masksToBounds = true
        
        setupNavagationBar()
    
        populateUserInfo()
    }
    
    @IBAction func btnUpdateProfile_Click(_ sender: AnyObject) {
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
        self.txtName.isHidden = false
        self.btnSave.isHidden = false
        self.btnCancel.isHidden = false
    }
    
    @IBAction func btnCancel_Click(_ sender: AnyObject) {
        self.profileImageView.gestureRecognizers?.removeAll()
        
        self.txtName.isHidden = true
        self.btnSave.isHidden = true
        self.btnCancel.isHidden = true
    }
    
    @IBAction func btnSave_Click(_ sender: AnyObject) {
        updateAccount()
    }
    func setupNavagationBar()
    {
        self.navBar.items?.removeAll()
        
        let navItem = UINavigationItem(title: "");
        
        let logOutItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navItem.rightBarButtonItem = logOutItem
        
        let deleteItem = UIBarButtonItem(title: "Delete Account", style: .plain, target: self, action: #selector(deleteAccount))
        navItem.leftBarButtonItem = deleteItem
        
        self.navBar.setItems([navItem], animated: false);
    }
    
    func handleLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
            
            GIDSignIn.sharedInstance().signOut()
            
            FBSDKLoginManager().logOut()
            
        } catch let logoutError {
            print(logoutError)
        }
        
        let LoginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let loginController = LoginStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginController, animated: true, completion: nil)
    }
    
    func checkUserGmail(uid: String){
        
        let userImage = UIImage(named: "userEmoji")
        
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
                    
                    self.setUserInfo(userName: name, email: email)
                    
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
            
            btnUpdateProfile.isHidden = true
        }
        else{
            self.checkFriendRequests(userID: uid)
            
            btnUpdateProfile.isHidden = false
        }
        
        if friend_uid == nil && GIDSignIn.sharedInstance().currentUser?.profile.email != nil{
            self.checkUserGmail(uid: uid)
        }
        else{
            
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dic = snapshot.value as? [String: AnyObject] {
                    
                    self.setUserInfo(userName: dic["name"] as! String?, email: dic["email"] as! String?)
                    
                    let url = dic["profileImageUrl"] as! String?
                    
                    if let profileImageUrl = url {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
                
            })
        }
    }
    
    func setUserInfo(userName: String?, email: String?){
        self.lblName.text = userName
        self.lblEmail.text = email
        self.txtName.text = userName
    }
    
    func updateAccount(){
        let user = FIRAuth.auth()?.currentUser
        
        /*user?.updateEmail(emailTextField.text!, completion: { (error) in
         if  error != nil {
         print("Erro to try to update account")
         }else{
         }
         })*/
        
        guard let uid = user?.uid else{
            return;
        }
        
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.child("name").setValue(self.txtName.text)
        self.lblName.text = self.txtName.text
        
        let alert = UIAlertController(title: "Update account", message: "Account was updated succefully", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteAccount(){
        
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
            self.deleteUserReferences()
            
            let user = FIRAuth.auth()?.currentUser
            
            user?.delete(completion: { (error) in
                if  error != nil {
                    print("Erro to try to delete account")
                }else{
                    
                    GIDSignIn.sharedInstance().signOut()
                    
                    FBSDKLoginManager().logOut()
                    
                    let LoginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
                    let loginController = LoginStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(loginController, animated: true, completion: nil)
                    
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (alert: UIAlertAction!) -> Void in
            print("You pressed No")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
    }
    
    func deleteUserReferences(){
        
        let ref = FIRDatabase.database().reference()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //Friends
        ref.child("friends").queryOrdered(byChild: "sender_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let friendsReference = ref.child("friends").child(snapshot.key)
            friendsReference.removeValue()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let friendsReference = ref.child("friends").child(snapshot.key)
            friendsReference.removeValue()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //User
        let userReference = ref.child("users").child(userID!)
        userReference.removeValue()
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
    
    func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        var selectedImage: UIImage?
        
        if let editImgae = info["UIImagePickerControllerEditedImage"]  {
            
            selectedImage = editImgae as? UIImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]  {
            
            selectedImage = originalImage as? UIImage
        }
        
        if let imagePicked = selectedImage{
            profileImageView.image = imagePicked
            
            let user = FIRAuth.auth()?.currentUser
            
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
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
