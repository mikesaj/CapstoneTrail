//
//  userSession.swift
//  capstone
//
//
//  Created by Michael Sajuyigbe on 2017-01-28.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
/*
 *
 *   This class manages the user login sessions
 *
 */

class UserLogin {
    
    // Declaring input class variables
    var username: String = ""
    var password: String = ""
    
    // Declaring user preference to store user login state
    let user_session = UserDefaults.standard
    
    // Constructor Method
    init(username: String, password: String){
        self.username = username
        self.password = password
    }
    
    // Constructor Method with no input parameter
    init(){}
    
    
    // This method checks if there is a logged-in user and returns a boolean value
    func isUserLoggedIn() -> Bool {
        self.username = self.user_session.string(forKey: "username")!
        
        // return false if username isnt found in preference
        if username.isEmpty { return false }
        
        // return true if username is found in preference
        return true
    }
    

    /* Method returns true if the login task was successful
        input parameters (loginType): "native" or "facebook" or "google"
        return type boolean
     */
    func userLogin(loginType: String) -> Bool {
        
        // check if login form labels are empty
        if self.username.isEmpty || self.password.isEmpty { return false }
        
        var currUser: String
        
        // Switch staement to determine the service used to log-in to the app
        switch loginType {
            
            case "native" :
                currUser = nativeLogin()
            case "facebook" :
                currUser = faceBookLogin()
            case "google" :
                currUser = googleLogin()
            default:
                return false
        }
        
        if currUser.isEmpty{
            return false
        }
        
        // logged-in user data is stored in the userdefault (prefence store) as the user session values
        // The current data is a dummy
        user_session.set("email", forKey: "email")
        user_session.set("name",  forKey: "name")
        user_session.set("token", forKey: "token")
    
        return true
    }
    
    // Account created directly from our signup database
    // returns username
    func nativeLogin() -> String {
        
        print(username)
        print(password)
        
        //<#function body#>
        return username
    }
    
    // Account created through "Facebook Login API"
    // returns username
    func faceBookLogin() -> String {
        //<#function body#>
        return username
    }
    
    // Account created through "Google Login API"
    // returns username
    func googleLogin() -> String {
        //<#function body#>
        return username
    }
    


    
}
