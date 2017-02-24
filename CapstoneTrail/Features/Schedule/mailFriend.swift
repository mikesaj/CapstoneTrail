//
//  inviteFriendsController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase
import MessageUI


class mailFriend: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var friendListTableView: UITableView!
    
    var firendName: NSMutableArray! = NSMutableArray()
    var firendEmail:NSMutableArray! = NSMutableArray()
    var firenduid:  NSMutableArray! = NSMutableArray()
    
    var MessageRecipients = ""
    var subject = ""
    var messageBody = ""
    
    // Database reference
    let ref = FIRDatabase.database().reference()
    
    //collection of logged user's friendships
    var friends = [Friend]()
    
    var friendHash = Set<String>()
    
    
    override func viewDidLoad() {
        fetchUsers()
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Controller Table View
    // Getting the number of rows in firendName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firendName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! friendIvCell
        cell.Title.text = self.firendName.object(at: indexPath.row) as? String
        //cell.inviteButton.addTarget(self, action: #selector(logAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let meil = firendEmail.object(at: (indexPath.row)) as! String
        
        self.MessageRecipients = meil
        self.subject = "tyghujik"
        self.messageBody = firendName.object(at: (indexPath.row)) as! String
        
        sendEmailButton()
        
        friendListTableView.deselectRow(at: indexPath, animated: true)
        /*
        
        let titleString = self.firendName.object(at: indexPath.row) as? String
        
        performSegue(withIdentifier: "view3", sender: self)
         */
        
        //print(titleString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "view3"){
            
            /*var coming: ScheduleProfileController = segue.destination as! ScheduleProfileController
            
            let indexPath = friendListTableView.indexPathForSelectedRow
            
            coming.name = firendEmail.object(at: (indexPath?.row)!) as! String
            coming.email= firendEmail.object(at: (indexPath?.row)!) as! String*/
            
            //friendListTableView.deselectRow(at: indexPath, animated: true)
        }
    }
 
    
    func fetchUsers(){
        
        //populating existing friendships
        self.populateFriends()
        
        //getting the logged user's email
        let emailLoggedUser = FIRAuth.auth()?.currentUser?.email
        
        //getting all users from database
        //**** TODO: we need to define criteria for seaching users from database
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                var isFriend: Bool = false
                var friendship_uid: String = ""
                
                if self.friends.count > 0 {
                    
                    var i = 0
                    
                    for t in stride(from: 0, through: self.friends.count - 1, by: 1) {
                        
                        //checking if the user made any friendhip request AND it has been accepted AND it has NOT been blocked
                        if((self.friends[i].receiver_uid == snapshot.key || self.friends[i].sender_uid == snapshot.key) &&
                            self.friends[i].isAccepted == true && self.friends[i].isBlocked == false){
                            
                            friendship_uid = self.friends[i].uid!
                            isFriend = true
                            break
                        }
                        
                        i += 1
                    }
                    
                }
                
                if isFriend == true{
                    
                    let email = dictionary["email"] as? String
                    
                    //checking is the user logged is the current user
                    if email?.lowercased() != emailLoggedUser?.lowercased() {
                        
                        let user = User()
                        
                        //Assigning retrieved values to the user object
                        user.uid = snapshot.key
                        user.email = dictionary["email"] as? String
                        user.name = dictionary["name"] as? String
                        user.profileImageUrl = dictionary["profileImageUrl"] as? String
                        user.friendship_uid = friendship_uid
                        
                        //refreshing table after populating collection
                        self.firendName.add(user.name!)
                        self.firendEmail.add(user.email!)
                        self.firenduid.add(user.uid!)
                        
                        //Appending user object to collections
                        self.friendListTableView.reloadData()
                        //self.tableView.reloadData()
                    }
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func processdata(){
        
        print(friendHash)
        
        //refreshing table after populating collection
        self.friendListTableView.reloadData()
        
    }
    
    //Appending friendship to friend collection
    func poplateSingleFriend(key: String, value: [String: AnyObject]){
        
        let name = value["name"] as? String ?? ""
        let email = value["email"] as? String ?? ""
        
        // if friendship is accepted
        if !friendHash.contains(name) {
            
            friendHash.insert(name)
            
            firendName.add(name)
            firendEmail.add(email)
            firenduid.add(key)
            
            
            self.processdata()
        }
    }
    
    //populating logged is user's friendships
    func populateFriends(){
        
        //getting logged user's uid
        let userID = "DPpwfIDhAGXpFjFqI3BytLMrAA73" //"FIRAuth.auth()?.currentUser?.uid
        
        //getting friendships where the logged user was the sender
        ref.child("friends").queryOrdered(byChild: "sender_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                //self.poplateSingleFriend(key: snapshot.key, value: value!)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        //getting friendships where the logged user was the receiver
        ref.child("friends").queryOrdered(byChild: "receiver_uid").queryEqual(toValue: userID).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? [String: AnyObject]
            
            if value != nil{
                
                
                //getting friendships where the logged user was the sender
                self.ref.child("users").queryOrderedByKey()
                    .queryEqual(toValue: value?["sender_uid"])
                    .observe(.childAdded, with: { (snapshot1) in
                        
                        
                        let value1 = snapshot1.value as? [String: AnyObject]
                        
                        if value1 != nil{
                            
                            //print( value1!["name"] as? String ?? "" )
                            self.poplateSingleFriend(key: snapshot1.key, value: value1!)
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                }
                
                
                
                
                
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
   
    // Email message invite action
    @IBAction func sendEmailButton() {
        
        // Instantiate compose view controller
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        
        mailComposerVC.setToRecipients( [self.MessageRecipients] )
        mailComposerVC.setSubject( self.subject)
        mailComposerVC.setMessageBody( self.messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    
}


