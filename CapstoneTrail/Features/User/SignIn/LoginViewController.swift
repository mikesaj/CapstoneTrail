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


class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var window: UIWindow?
    
    lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "userEmoji")
        return imageView
    }()
    
    // Declaring input class variables
    var username: String = ""
    var password: String = ""

    // Login status
    var status = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        FBSDKLoginManager().logOut()
        
        setupFacebookButtons()
        setupGoogleButtons()
    }
    
    //hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        return true
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
                self.switchToDashBoardView()

            }
            
        })
        
    }
    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Switch to DashBoard Storyboard
    func switchToDashBoardView(){
         //let storyboard = UIStoryboard(name: "DashBoard", bundle: nil)
         //let vc : AnyObject! = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController")
         //self.show(vc as! UIViewController, sender: vc)
        
        /*
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = UINavigationController(rootViewController: DashBoardViewController())
         */
        
        var dashhh = DashBoardViewController()

        // for slide view, without navigation
        self.present(dashhh, animated: true, completion: nil)
        
        //allows navigation appear
        //navigationController?.pushViewController(dashhh, animated: true)
        
        //navigationController?.present(dashhh, animated: true)
        
        print("Switched to DashBoard View!!")
    }
    
    fileprivate func setupGoogleButtons(){
        let loginGoogleButton = GIDSignInButton()
        loginGoogleButton.frame = CGRect(x: 50, y: 570, width: view.frame.width - 100, height: 40)
        view.addSubview(loginGoogleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    fileprivate func setupFacebookButtons(){
        let loginFacebookButton = FBSDKLoginButton()
        view.addSubview(loginFacebookButton)
        loginFacebookButton.frame = CGRect(x: 50, y: 510, width: view.frame.width - 100, height: 40)
        loginFacebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginFacebookButton.delegate = self
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logout")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            self.getEmailFromFB()
        }
    }
    
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
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, name, gender, id"]).start { (connection, result, err) in
                
                if err != nil{
                    print("Failed to start graph request:", err)
                    return
                }
                
                let uid = user?.uid
                
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(uid).jpg")
                
                if let uploadData = UIImageJPEGRepresentation(self.userImageView.image!, 0.1){
                    
                    storageRef.put(uploadData, metadata: nil, completion: { (metada, error) in
                        
                        if error != nil{
                            print(error)
                            return
                        }
                        
                        let data:[String:AnyObject] = result as! [String : AnyObject]
                        let name = (data["name"] as! String?)
                        let email = (data["email"] as! String?)
                        
                        if let profileImageUrl = metada?.downloadURL()?.absoluteString {
                            
                            let ref = FIRDatabase.database().reference(fromURL: "https://capstoneproject-54304.firebaseio.com/")
                            
                            let userReference = ref.child("users").child(uid!)
                            
                            userReference.child("name").setValue(name)
                            userReference.child("email").setValue(email)
                            userReference.child("profileImageUrl").setValue(profileImageUrl)
                            
                            self.switchToDashBoardView()
                            
                        }
                        
                    })
                    
                }
            }
            
        })
    }
    
}

