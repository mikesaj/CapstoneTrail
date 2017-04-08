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
        
        groupReference.child("owneruid").setValue(uid)
        groupReference.child("name").setValue(group.name)
        groupReference.child("locationName").setValue(group.locationName)
        groupReference.child("description").setValue(group.groupDescription)
        groupReference.child("longitude").setValue(group.longitude)
        groupReference.child("latitude").setValue(group.latitude)
        groupReference.child("members").setValue([uid])
        groupReference.child("isPublic").setValue(group.isPublic)
        
        //add group to user's groups
        self.addGrouptoUser(userId: uid!, groupId: groupUid)
        
        return groupUid
    }
    
    // method get's group information
    func getGroup(groupUid:String) -> GroupModel {
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupUid)
            .observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                //let group = GroupModel()
                
                self.group.uid               = snapshot.key
                self.group.name              = value?["name"]               as? String
                self.group.locationName      = value?["locationName"]       as? String
                self.group.groupDescription  = value?["groupDescription"]   as? String
                self.group.members           = (value?["members"]           as? [String])!
                self.group.owneruid          = value?["owneruid"]           as? String
                self.group.isPublic          = value?["isPublic"]           as? Bool
                self.group.latitude          = value?["latitude"]           as? String
                self.group.longitude         = value?["longitude"]          as? String
                

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
    
    // delete user id from group's document
    func removeMemberFromGroup(groupUid:String, userId:String) {
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupUid)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    var n = 0
                    
                    var members = (value?["members"] as? [String])!
                    for member in members {
                        
                        if member == userId {
                            members.remove(at: n)
                            
                            // remove member from group list
                            self.ref.child("groups").child(groupUid).child("members").setValue(members);
                            
                            // remove group from user's list
                            self.removeGroupFromMember(groupUid: groupUid, userId: userId)
                        }
                        n = n+1
                    }
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    // delete a hike group
    func deleteGroup(groupUid:String) {
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupUid)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    let members = (value?["members"] as? [String])!
                    for memberId in members {

                        // remove group from user's list
                        print("\(memberId) removed!!")
                        self.removeGroupFromMember(groupUid: groupUid, userId: memberId)
                    }
                    
                 // delete group structure
                 self.ref.child("groups").child(groupUid).removeValue()
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }
    
    
    // delete group id from user's document
    func removeGroupFromMember(groupUid:String, userId:String) {
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: userId)
            .observe(.childAdded, with: { (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if  ((value?["groups"]?.count)!) > 0 {
                    
                    //self.ref.child("users").child(userId).child("groups").child(groupUid).removeValue()
                    
                    var n = 0
                    
                    var groups = (value?["groups"] as? [String])!
                    for group in groups {
                        
                        if group == groupUid {
                            groups.remove(at: n)
                            
                            // remove member from group list
                            self.ref.child("users").child(userId).child("groups").setValue(groups);
                            
                        }
                        n = n+1
                    }
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }

    
    
    // gets object's type
    func getClassName(obj : AnyObject) -> String
    {
        let objectClass : AnyClass! = object_getClass(obj)
        let className = objectClass.description()
        
        return className
    }
    
    func convertoStrArray(obj : AnyObject) -> [String] {
        
        var strObj = [String]()
        let resultType = self.getClassName(obj: obj)
        print("Type: \(resultType)")
        
        if resultType == "__NSDictionaryM" {
            let grpids = obj as! NSDictionary
            for (key, value) in grpids {
                print("Value: \(value) for key: \(key)")
                strObj.append(value as! String)
            }
        }else{
            
            print("sdfg: \(obj)")
            let arr = obj as! NSArray
            
            for i in arr {
                
                if !(i is NSNull) {
                    
                    print("values: \(i)")
                    strObj.append(i as! String)
                }
                
            }
            
            
            //strObj = (obj as! NSArray) as! [String]
        }
        
        return strObj
    }

}
