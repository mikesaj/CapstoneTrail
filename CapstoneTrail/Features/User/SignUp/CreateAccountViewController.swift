//
//  SignUpViewController.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-02-03.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

import Firebase
import FBSDKLoginKit
import GoogleSignIn

/**
 This class performs the task to create a user account
 
 */
class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func CreateAccount(_ sender: UIButton) {
    
        guard let email = userEmail.text, let password = password.text, let name = personName.text, let userName = userName.text
            else{
                let alert = UIAlertController(title: "Warning", message: "All fields are required", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return;
        }
        
        if email == "" || name == "" || password == "" || userName == "" {
            self.displayMessage(ttl: "Error", msg: "All fields are required")
            return
        }
        
        if email.contains("@") == false || email.contains(".") == false {
            self.displayMessage(ttl: "Error", msg: "Inform a valid e-mail account")
            return
        }
        
        if password.characters.count < 6 {
            self.displayMessage(ttl: "Error", msg: "Password must have at least 6 characters")
            return
        }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.displayMessage(ttl: "Error to create your account", msg: error.debugDescription)
                return
            }else{
                
                guard let uid = user?.uid else{
                    return;
                }
                
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(uid).jpg")
                
                if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.1){
                    
                    storageRef.put(uploadData, metadata: nil, completion: { (metada, error) in
                        
                        if error != nil{
                            print(error)
                            return
                        }
                        
                        if let profileImageUrl = metada?.downloadURL()?.absoluteString {
                            
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl] as [String : Any]
                            
                            self.registerUserIntoDatababase(uid: uid, values: values as [String : AnyObject])
                            
                        }
                        
                    })
                    
                }
            }
        })
        
    }

    private func registerUserIntoDatababase(uid: String, values: [String: AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://capstoneproject-54304.firebaseio.com/")
        
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err)
                return
            }else{
                
                let profileController = DashBoardViewController()
                self.present(profileController, animated: true, completion: nil)
            }
        })
        
        
    }
    
    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImage.layer.cornerRadius = 100
        self.profileImage.layer.masksToBounds = true
        self.profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
    }

    @IBAction func btnCancelar_Click(_ sender: AnyObject) {
        let LoginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let loginController = LoginStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginController, animated: true, completion: nil)
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
            profileImage.image = imagePicked
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
