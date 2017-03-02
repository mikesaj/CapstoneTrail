//
//  viewFriendViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class ViewFriendViewController: UIViewController {

    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var removeUserButton: UIButton!
    
    var titleString: String = ""
    var memberId:    String = ""
    var groupid:     String = ""
    var owneruid:    String = ""
    
    
    var groupDAL = GroupDBController()
    
    // Database reference
    let ref = FIRDatabase.database().reference()

    // Get's logged user's uid
    let userID = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.title = self.titleString
        self.memberNameLabel.text = self.titleString
        self.getProfileImageUrl()
        
        if ((userID != owneruid) || (memberId == owneruid)) {
            print("inside")
            print(owneruid)
            removeUserButton.removeFromSuperview()
        }
        super.viewWillAppear(animated) // No need for semicolon
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func removeUserfromGroup(_ sender: Any) {
        removeGroupMember()
    }
    func removeGroupMember(){
        
        let alert = UIAlertController(title: "Remove Member", message: "Are you sure you want to remove  \(titleString) from the group?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
            // remove group member
            self.groupDAL.removeMemberFromGroup(groupUid: self.groupid, userId: self.memberId)

        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (alert: UIAlertAction!) -> Void in
            print("You pressed No")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
    }


    // get user's profile image
    func getProfileImageUrl(){
        
        ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: memberId)
            .observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                if value?["profileImageUrl"] != nil {
                    let imageUrl = value?["profileImageUrl"] as! String
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }


}
