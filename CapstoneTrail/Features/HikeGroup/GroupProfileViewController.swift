//
//  GroupProfileViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class GroupProfileViewController: UIViewController {

    public var GroupName    : String = ""
    public var locationName : String = ""
    public var memberCount  : Int    = 0
    public var groupid      : String = "random"
    public var GroupDescrip : String = "description"
    
    // group member number
    @IBOutlet weak var memberNum: UILabel!

    // group location
    @IBOutlet weak var groupLocation: UILabel!
    
    // group description
    @IBOutlet weak var groupDescrirption: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populates UI elements
        populateUI()
    }
    
    // methods populates UI elements
    func populateUI(){
        
        self.title = self.GroupName

        var memberS = "Member"
        if memberCount > 1 {
            memberS += "s"
        }
        
        memberNum.text = String(memberCount) + " " +  memberS
        groupLocation.text = locationName;
        groupDescrirption.text = GroupDescrip
    }
    
    
    @IBAction func inviteUsertoGroup(_ sender: UIButton) {
        performSegue(withIdentifier: "inviteUsertoGroup", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "inviteUsertoGroup"){
            
            let invitationController: inviteFriendsController = segue.destination as! inviteFriendsController
            
            // Passing parameters to the inviteFriendsController class
            invitationController.groupid = self.groupid
        }
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
