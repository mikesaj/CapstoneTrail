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

    override func viewDidLoad() {
    super.viewDidLoad()
    
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(updateButton)
        view.addSubview(deleteButton)
        view.addSubview(emailTextField)
        view.addSubview(peopleButton)
        view.addSubview(profileImageView)
        
        setupUpdateButton()
        setupDeleteButton()
        setupEmailTextField()
        setupPeopleButton()
        setupProfileImageView()
        
        //gghandleLogout()
        
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
    
    func populateUserInfo(){
        
        let email = GIDSignIn.sharedInstance().currentUser?.profile.email
        
        if email != nil{
            self.emailTextField.text = email;
            self.navigationItem.title = email
            return;
        }
        
        if(FBSDKAccessToken.current() != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    self.emailTextField.text = (data["email"] as! String?)
                    self.navigationItem.title = (data["name"] as! String?)
                }
            })
            
            return;
        }
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dic = snapshot.value as? [String: AnyObject] {
                
                self.navigationItem.title = dic["name"] as! String?
                let value = dic["email"] as! String?
                self.emailTextField.text = value!
            }
            
        })
    }
    
    func updateAccount(){
        
        let user = FIRAuth.auth()?.currentUser
        
        user?.updateEmail(emailTextField.text!, completion: { (error) in
            if  error != nil {
                print("Erro to try to update account")
            }else{
                let alert = UIAlertController(title: "Update account", message: "Account was updated succefully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
        
    }
    
    func deleteAccount(){
        
        let user = FIRAuth.auth()?.currentUser
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
        
        //if animated {
        populateUserInfo()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //}
        
    }

}
