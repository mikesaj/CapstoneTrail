//
//  ScheduleDBController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-05.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ScheduleDBController{
    
    // Group array
    var groups = [GroupModel]()
    
    // Firebase reference instance
    let ref = FIRDatabase.database().reference()
    
    // add hikeid to user's list
    func addHikeEventtoUser(hikeEventid:String, userId:String) {
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                var hikeEventinvites = [String]()
                
                if value?["hikingSchedules"] != nil {
                    
                    // get hike invites
                    hikeEventinvites = (value?["hikingSchedules"] as? [String])!
                }
                
                if  (hikeEventinvites.count) > 0 {
                    
                    hikeEventinvites = (value?["hikingSchedules"] as? [String])!
                    hikeEventinvites.append(hikeEventid)
                    
                    // update user's hike event's list
                    self.ref.child("users").child(userId).child("hikingSchedules").setValue(hikeEventinvites);
                    // add hikeid to user's list
                    self.addUserToHikingGroupList(hikeEventid:hikeEventid, userId:userId)
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }

    // add hikeid to user's list
    func addUserToHikingGroupList(hikeEventid:String, userId:String) {
        
        _ = ref.child("hikingSchedules")
            .queryOrderedByKey()
            .queryEqual(toValue: hikeEventid)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                
                var hikeEventinvites = [String]()
                
                if value?["attendees"] != nil {
                    
                    // get hike invites
                    hikeEventinvites = (value?["attendees"] as? [String])!
                }
                
                if  (hikeEventinvites.count) > 0 {
                    
                    hikeEventinvites = (value?["attendees"] as? [String])!
                    hikeEventinvites.append(userId)
                    
                    // update hike attender's list
                    self.ref.child("users").child(userId).child("attendees").setValue(hikeEventinvites);
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    
    
    
    // delete hikeid from user's list
    func removeHikeInvite(hikeEventid:String, userId:String) {
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                var hikeEventinvites = [String]()
                
                if value?["hikeInvites"] != nil {
                    
                    // get hike invites
                    hikeEventinvites = (value?["hikeInvites"] as? [String])!
                }
                
                if  (hikeEventinvites.count) > 0 {
                    
                    var n = 0
                    
                    var hikeEventinvites = (value?["hikeInvites"] as? [String])!
                    for inviteId in hikeEventinvites {
                        
                        if inviteId == hikeEventid {
                            hikeEventinvites.remove(at: n)
                            
                            // remove hikeid from user's list
                            self.ref.child("users").child(userId).child("hikeInvites").setValue(hikeEventinvites);
                        }
                        n = n+1
                    }
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }


}