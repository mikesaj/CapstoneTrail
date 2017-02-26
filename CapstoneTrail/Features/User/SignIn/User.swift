//
//  User.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-01-28.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation

class User {
    
    var username: String? = nil
    var firstname: String? = nil
    var city: String? = nil
    var country: String? = nil
    var LatestGpsCordinate: [String: Float32] = [:]
    var fitnestGroupsId: [Int : Int] = [:]
    
    var uid: String?
    var email: String?
    var name: String?
    var profileImageUrl: String?
    var friendship_uid: String?
    var isFriendRequested: Bool?

    
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

