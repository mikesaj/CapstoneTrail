//
//  GroupProfileViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class GroupProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Current user id
    let uid = FIRAuth.auth()?.currentUser?.uid

    // initializing with demo data (testing purpose)
    public var GroupName    : String = ""
    public var locationName : String = ""
    public var memberCount  : Int    = 1
    public var groupid      : String = "random"
    public var groupOwnerid : String = "6723890-23"
    public var GroupDescrip : String = "description"
    public var isPublic     : Bool   = true
    public var GroupMembers : [String] = []
    
    // group member number
    @IBOutlet weak var memberNum: UILabel!

    // group location
    @IBOutlet weak var groupLocation: UILabel!
    
    // group description
    @IBOutlet weak var groupDescrirption: UITextView!
    
    // group options
    @IBOutlet weak var groupOptionsTableView: UITableView!
    
    // label for group visibility
    @IBOutlet weak var isPulicLabel: UILabel!
    
    // group options list
    var groupOptions: NSMutableArray! = NSMutableArray()
    
    // Data class for group objects
    var groupDAL = GroupDBController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set group name as ViewController title
        self.title = self.GroupName
        
        // populates UI elements
        populateUI()

        // populates group options list
        populateGroupOptions()
    }
    
    // populates group options list
    func populateGroupOptions(){
        
        // sets the text on the isPublic label
        if isPublic == true {
            isPulicLabel.text = "Public"
        }
        
        // list of group options
        self.groupOptions = ["Hiking Schedules", "Members", "Update Group Information", "Delete Group", "Exit Group"]
        
        // remove options if the current user isnt the owner of the group
        if self.groupOwnerid != uid {
            groupOptions.removeObjects(in: ["Update Group Information", "Delete Group"])
        }
        else {
            // This remove's the option of a group to exit the group
            groupOptions.removeObjects(in: ["Exit Group"])
        }
        
        
    }
    
    // methods populates UI elements
    func populateUI(){
        
        // get number of group members
        memberCount = self.GroupMembers.count
        
        var memberS = "Member"
        if memberCount > 1 {
            memberS += "s"
        }
        
        memberNum.text = String(memberCount) + " " +  memberS
        groupLocation.text = locationName;
        groupDescrirption.text = GroupDescrip

    }
    
    // add friends button navigates to segue showing user's friends
    @IBAction func inviteUsertoGroup(_ sender: UIButton) {
        performSegue(withIdentifier: "addFriendstoGroup", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "addFriendstoGroup"){
            
            let addFriendController: AddFriendToGroupsController = segue.destination as! AddFriendToGroupsController
            
            // Passing parameters to the inviteFriendsController class
            addFriendController.groupid      = self.groupid             // id of the group
            addFriendController.GroupMembers = self.GroupMembers // ids of group's current members [String]
            addFriendController.groupOwnerid = self.groupOwnerid
        }
        
        if(segue.identifier == "updateGroup"){
            
            // instantiating a reference to the UpdateGroupViewController
            let updateGroup: UpdateGroupViewController = segue.destination as! UpdateGroupViewController
            
            // passing data through the reference
            updateGroup.groupId          = groupid
            updateGroup.groupName        = GroupName
            updateGroup.Groupdescription = GroupDescrip
            updateGroup.isPublic         = isPublic
        }
        
        if(segue.identifier == "groupMembers") {
            
            // instantiating a reference to the UpdateGroupViewController
            let updateGroup: GroupMembersViewController = segue.destination as! GroupMembersViewController
            updateGroup.groupUid = self.groupid
        }
        
        if (segue.identifier == "ScheduleList") {
            // instantiating a reference to the TrailDetailViewController
            let groupHikes: ScheduleListController = segue.destination as! ScheduleListController
            groupHikes.groupId = self.groupid
            groupHikes.groupOwnerId = self.groupOwnerid
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Controller Table View
    // Getting the number of rows in firendName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = self.groupOptions.object(at: indexPath.row) as? String
        
        //cell.friendName.text = self.firendName.object(at: indexPath.row) as? String
        //cell.addToGroupButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)
        return cell
    }
    
    func logAction(){}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // gets the selected option in the table
        let OptionSelected = self.groupOptions.object(at: indexPath.row) as? String
        
        switch OptionSelected! {
            
            case "Hiking Schedules"  :
                // Schedule option selected
                GroupScheduleController()
                break
            
            case "Members"  :
                // Member option selected
                GroupMemberController()
                break
   
            case "Update Group Information" :
                // Update Group Info. option selected
                UpdateGroupInfoController()
                break
            
            case "Delete Group":
            
                // Delete Group option selected
                DeleteGroupController()
                break
            
            case "Exit Group" :
                
                // Exit Group option selected
                ExitGroupController()
                break
            
            default :
                print( "error: Wrong option!")
        }
        
        //deselect the selected cell background view.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // lauches the groups schedule controller
    func GroupScheduleController() {
        print("GroupScheduleController")
        performSegue(withIdentifier: "ScheduleList", sender: self)
    }
    
    // method displays group members list controller
    func GroupMemberController() {
        print("GroupMemberController")
        performSegue(withIdentifier: "groupMembers", sender: self)
    }

    // method displays a modal to update a group's info
    func UpdateGroupInfoController() {
        print("UpdateGroupInfoController")
        performSegue(withIdentifier: "updateGroup", sender: self)
    }
    
    // Group owner deletes a group
    func DeleteGroupController() {
        
        print("DeleteGroupController")
        
        // Alert dialogue to exit group
        let alert = UIAlertController(title: "Delete Group Warning", message: "Are you sure you want to delete \(self.GroupName) group?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
            // Delete group
            self.groupDAL.deleteGroup(groupUid: self.groupid)
            
            // go back to previous navigation controller stack
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (alert: UIAlertAction!) -> Void in
            print("You pressed No")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
    }
    
    // Hiker exit's a group
    func ExitGroupController() {
        
        print("ExitGroupController")
        
        // Alert dialogue to exit group
        let alert = UIAlertController(title: "Member Exit", message: "Are you sure you want to exit this group?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
            // Remove group member
            print(self.uid!)
            self.groupDAL.removeMemberFromGroup(groupUid: self.groupid, userId: self.uid!)

            // go back to previous navigation controller stack
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (alert: UIAlertAction!) -> Void in
            print("You pressed No")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)

    }
    
}
