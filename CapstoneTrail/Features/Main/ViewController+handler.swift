//
//  ViewController+handler.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-10.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func handleLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
            
            GIDSignIn.sharedInstance().signOut()
            
            FBSDKLoginManager().logOut()
            
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.viewController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func addFriends(){
        let peopleController = PeopleViewController()
        self.present(peopleController, animated: true, completion: nil)
    }
    
    func myFriends(){
        let friendController = FriendsViewController()
        self.present(friendController, animated: true, completion: nil)
    }
    
    func populateMyProfile(){
        friend_uid = nil
        populateUserInfo()
    }
    
    func populateWalkingSchedule(){
        let walkingScheduleController = WalkingScheduleViewController()
        self.present(walkingScheduleController, animated: true, completion: nil)
    }
    
    func setupEmailTextField(){
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -200).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupUpdateButton(){
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -50).isActive = true
        updateButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupPeopleButton(){
        peopleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        peopleButton.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -110).isActive = true
        peopleButton.widthAnchor.constraint(equalTo: updateButton.widthAnchor).isActive = true
        peopleButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupWalkingScheduleButton(){
        walkingScheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        walkingScheduleButton.topAnchor.constraint(equalTo: friendButton.bottomAnchor, constant: 15).isActive = true
        walkingScheduleButton.widthAnchor.constraint(equalTo: friendButton.widthAnchor).isActive = true
        walkingScheduleButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupDeleteButton(){
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupFriendButton(){
        friendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        friendButton.topAnchor.constraint(equalTo: peopleButton.bottomAnchor, constant: 20).isActive = true
        friendButton.widthAnchor.constraint(equalTo: updateButton.widthAnchor).isActive = true
        friendButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupLogoutButton(){
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 10).isActive = true
        logoutButton.widthAnchor.constraint(equalTo: updateButton.widthAnchor).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupMyProfileButton()
    {
        myProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myProfileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        myProfileButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        myProfileButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

}


