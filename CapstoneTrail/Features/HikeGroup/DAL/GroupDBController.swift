//
//  GroupDBController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupDBController{

    // Group array
    var groups = [GroupModel]()
    
    // Firebase reference instance
    let ref = FIRDatabase.database().reference()
    
    // Current user id
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    let group = GroupModel()
    
    // Creates a hike group
    func CreateGroup(group: GroupModel) -> String {
        
        // generating a groupd id
        let groupUid = UUID().uuidString
        

        let groupReference = ref.child("groups").child(groupUid)
        
        groupReference.child("name").setValue(group.name)
        groupReference.child("owneruid").setValue(uid)
        groupReference.child("locationName").setValue(group.locationName)
        groupReference.child("longitude").setValue(group.longitude)
        groupReference.child("latitude").setValue(group.latitude)
        groupReference.child("members").setValue([uid])
        groupReference.child("isPublic").setValue(group.isPublic)
        
        return groupUid
    }
    
    // method get's group information
    func getGroup(groupUid:String) -> GroupModel {
        
        _ = ref.child("groups").child(groupUid).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                //let group = GroupModel()
                
                self.group.uid            = snapshot.key
                self.group.name           = value?["name"]            as? String
                self.group.locationName   = value?["locationName"]    as? String
                self.group.members        = (value?["members"]        as? [String])!
                self.group.owneruid       = value?["owneruid"]        as? String
                self.group.isPublic       = value?["isPublic"]        as? Bool
                self.group.latitude       = value?["latitude"]        as? String
                self.group.longitude      = value?["longitude"]       as? String
                
                //print(self.group.locationName)
                //self.poplateSingleFriend(key: snapshot.key, value: value!)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    
        return group
    }
    
    // method adds a user to a group
    func addUsertoGroup(groupId: String, userId: String) {
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupId)
            .observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            print("\(groupId): empty nothing 1")
            
            if value != nil{

                // get members list
                self.group.members        = (value?["members"]        as? [String])!
                
                // add user id to group list
                self.group.members.append(userId)
                
                // add user to the group's member list
                self.ref.child("groups").child(groupId).child("members").setValue(self.group.members);

                // add group to the user's list
                self.addGrouptoUser(userId: userId, groupId: groupId)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // add group to the users's group list
    func addGrouptoUser(userId: String, groupId: String){
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{

                    var userGroups = [String]()
                    
                    if value?["groups"] != nil {

                        // get user's group list
                        userGroups = (value?["groups"]        as? [String])!
                    }
                    
                    // add group id to user's list
                    userGroups.append(groupId)
                    
                    // add group to the user's group list
                    self.ref.child("users").child(userId).child("groups").setValue(userGroups);
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
    
    }

}
