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
class CreateAccountViewController: UIViewController {

    
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var password: UITextField!
    
    //var personNameData:String, userEmailData:String, userNameData:String, passwordData:String, DescriptionData:String
    
    
    //let loginView = LoginViewController();
    
    
    @IBAction func CreateAccount(_ sender: UIButton) {
    
        guard let personNameData:String = personName.text else {
            //loginView.emptyLabels()
            return
        }
        
        guard let userEmailData:String = userEmail.text else {
            //loginView.emptyLabels()
            return
        }
        
        guard let userNameData:String = userName.text else {
            //loginView.emptyLabels()
            return
        }
        
        guard let passwordData:String = password.text else {
            //loginView.emptyLabels()
            return
        }
        
        guard let DescriptionData:String = Description.text else {
            //loginView.emptyLabels()
            return
        }
        
        if (personNameData.isEmpty) || (userEmailData.isEmpty) || (userNameData.isEmpty) || (passwordData.isEmpty) || (DescriptionData.isEmpty){
            //loginView.emptyLabels()
            return
        }
        
        // Calls the method that creates a user account
        //self.CreateAccount(username: userNameData, password: passwordData, name: personNameData, email: userEmailData, description: DescriptionData)
        
        //user registration
        self.handleRegister(name: personNameData, email: userEmailData, password: passwordData)
        
    }
    
    // User Registration
    func handleRegister(name: String, email: String, password: String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.displayMessage(ttl: "Error", msg: error.debugDescription)
                return
            }else{
                
                let ref = FIRDatabase.database().reference(fromURL: "https://capstoneproject-54304.firebaseio.com/")
                
                let usersReference = ref.child("users").child(user!.uid)
                
                let values = ["name": name, "email": email]
                
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil{
                        print(err)
                        return
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
                print("Login Successful")
                return
            }
        })
    }

    
    
    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // Creates account and returns a boolean feedback
    //func CreateAccount(username: String, password: String, name: String, email: String, description: String) -> Bool{
    
    //    return false
    //}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
