//
//  ViewController.swift
//  capstone
//
//  Created by Joohyung Ryu on 2017. 1. 24..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit

import Firebase
import FBSDKLoginKit
import GoogleSignIn


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // Declaring input class variables
    var username: String = ""
    var password: String = ""

    // Login status
    var status = false

    // FaceBook Button
    @IBOutlet weak var fbButton: UIButton!
    
    
    //FaceBook
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logout")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            // Get FaceBook User Information
            self.getEmailFromFB()
            
            // Navigate to dashboard view, if logged-in
            self.checkIfUserIsLoggedIn()
            //self.switchToDashBoardView()
        }
    }
    
    
    // Get user email from FaceBook account
    func getEmailFromFB(){
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            
            if error != nil {
                print("Erro login with Facebook :", error)
                
                return
            }
            
            print("Successfully logged in with our user: ", user)
            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, name, gender, id"]).start { (connection, result, err) in
            
            if err != nil{
                print("Failed to start graph request:", err)
                return
            }
            
        }
    }
    
    // FaceBook Button
    @IBAction func loginFacebookAction(_ sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            
            if error != nil {
                NSLog("Process error")
            }
            else if (result?.isCancelled)! {
                NSLog("Cancelled")
            }
            else {
                NSLog("Logged in")
                self.getEmailFromFB()
                
                // Navigate to dashboard view, if logged-in
                //self.switchToDashBoardView()
                self.checkIfUserIsLoggedIn()
            }
            
        }
    }

    
    
    
    
    /// Native Login Button action

    @IBAction func loginAction(_ sender: UIButton) {
        
        guard let usernameData:String = usernameTextField.text else {
            //show("No name to submit")
            self.displayMessage(ttl: "Error", msg: "Please fill username label")
            return
        }
        
        guard let passowrdData:String = passwordTextField.text else {
            //show("No name to submit")
            self.displayMessage(ttl: "Error", msg: "Please fill password label")
            return
        }
        
        if (usernameData.isEmpty) || (passowrdData.isEmpty) {
            self.displayMessage(ttl: "Error", msg: "Please fill empty labels")
            return
        }
        
        username = usernameData
        password = passowrdData
        
        //Handles Native Login operations
        self.handleLogin()
        
    }
    
    /// Native Login Handle
    func handleLogin() -> Void {
        
        var message = "invalid username or password"
        
        FIRAuth.auth()?.signIn(withEmail: self.username, password: self.password, completion: { (user, error) in

            if error != nil{
                print(message)
                self.displayMessage(ttl: "Error", msg: message)
            } else{
                
                message = "Username logged-in"
                self.status = true

                print(message)
                //self.dismiss(animated: true, completion: nil)
                
                // Navigate to dashboard view, if logged-in
                //self.switchToDashBoardView()
                self.checkIfUserIsLoggedIn()

            }
            
        })
        
    }

    
    // Google Button
    @IBAction func loginGoogleAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        // Check if user is loggedIn
        checkIfUserIsLoggedIn()
        
        
        // GIDSignIn.sharedInstance().signOut()
        // GIDSignIn.sharedInstance().disconnect()
        // GIDSignIn.sharedInstance().signIn()
    }

    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Switch to DashBoard Storyboard
    func switchToDashBoardView(){
        let storyboard = UIStoryboard(name: "DashBoard", bundle: nil)
        let vc : AnyObject! = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController")
        self.show(vc as! UIViewController, sender: vc)
        
        print("Switched to DashBoard View!!")
    }
    
    
    // Check if user is loggedIn
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogin), with: nil, afterDelay: 0)
        }
        else {
            
        // Switch to DashBoard Storyboard
        self.switchToDashBoardView()
        
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
}

