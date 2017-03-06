//
//  UpdateGroupViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class UpdateGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    // Firebase reference instance
    let ref = FIRDatabase.database().reference()

    // UI element reference
    @IBOutlet weak var groupTitleTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextView: UITextView!
    @IBOutlet weak var isPublicSegment: UISegmentedControl!
    
    
    // class variables
    var isPublic:         Bool   = true
    var groupName:        String = ""
    var Groupdescription: String = ""
    var groupId:          String = ""
    let initDescrptionText = "Group description"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.groupTitleTextField.delegate      = self
        self.groupDescriptionTextView.delegate = self
        
        // populate UI objects
        groupTitleTextField.text      = groupName
        groupDescriptionTextView.text = Groupdescription
        
        var index = 0
        if (isPublic == false) {
            index = 1
            print("its false")
        }
        
        isPublicSegment.selectedSegmentIndex = index
        
        groupDescriptionTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        groupDescriptionTextView.layer.borderWidth = 1.0
        groupDescriptionTextView.layer.cornerRadius = 5
    }
    
    //hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // textview is emtptied as user begins editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if groupDescriptionTextView.textColor == UIColor.lightGray {
            groupDescriptionTextView.text = nil
            groupDescriptionTextView.textColor = UIColor.black
        }
    }
    // check if textview is emtpty and replace with placeholder if empty
    func textViewDidEndEditing(_ textView: UITextView) {
        if groupDescriptionTextView.text.isEmpty {
            groupDescriptionTextView.text = initDescrptionText
            groupDescriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // onUpdateButton click
    @IBAction func UpdateGroupButton(_ sender: UIButton) {
        
        // get UI objects state
        groupName = groupTitleTextField.text!
        Groupdescription = groupDescriptionTextView.text!
        isPublic = true
                
        if isPublicSegment.selectedSegmentIndex == 1 { isPublic = false }

        // calls Update group information method
        self.updateGroupInfo(groupId: groupId, title: groupName, description: Groupdescription, isPublic: isPublic)
        
        // dismiss current modal
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        
        // dismiss current modal
        self.dismiss(animated: false, completion: nil)
    }
    
    // Update group information
    func updateGroupInfo(groupId: String, title:String, description: String, isPublic:Bool){
        
        _ = ref.child("groups")
            .queryOrderedByKey()
            .queryEqual(toValue: groupId)
            .observe(.childAdded, with: { (snapshot) in
                
                var value = snapshot.value as? [String: AnyObject]
                
                if value != nil{
                    
                    print("Namesszz")
                    print(value ?? "noooooo")
                    
                    if value?["name"] != nil {
                        
                        print("Name11111")
                        // get user's group list
                        value?["name"]        = title       as AnyObject?
                        value?["description"] = description as AnyObject?
                        value?["isPublic"]    = isPublic    as AnyObject?
                        
                        print( value?["name"] )
                        
                        // add group to the user's group list
                        self.ref.child("groups").child(groupId).setValue(value);

                    }
                    
                }
                
            }) { (error) in
                print(error.localizedDescription)
        }
        
    }

}
