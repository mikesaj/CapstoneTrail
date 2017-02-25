//
//  User.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-01-28.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation

class User {
    
    var uid: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var isFriendRequested: Bool?
    var friendship_uid: String?

    
    // User preference to store user login state
    let userSessionData = UserDefaults.standard
    
    // get logged-in user
    func getCurrtUser() {
        
        let userLogin2 = UserLogin()
        let loginStatus = userLogin2.isUserLoggedIn()
        
        if loginStatus == false {
            
            // open new layout view
            getCurrtUser()
            return
        }
    }

}

