//
//  HikerInvitation.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-13.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

let subject = "Invitation to hiking App"
let messageBody = "Join our fast growing hiking App today"
var MessageRecipients = [""]

// This class is for composing text & email message invitations
public class JoinAppInvitation: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    //@IBOutlet weak var textRecipient: UITextField!
    @IBOutlet weak var emailRecipient: UITextField!
    
    public var locationName : String = ""
    
    // for pre-populating the recipients list
    // var MessageRecipients = [""]
    // let subject = "Subject of the mail"
    
    // Instantiate a MessageComposer
    let messageComposer = MessageComposer()
    
    // Text message invite action
    //@IBAction func sendTextMessageButtonTapped(_ sender: UIButton) {
    func sendTextMessage() {
        
        // Initializing text message body
        guard let Recipients = emailRecipient.text else { return }
        
        // get recipient from textfield
        MessageRecipients = [Recipients]

        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            /*let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()*/
            
            displayMessage(ttl: "Cannot Send Text Message", msg: "Your device is not able to send text messages.")
        }
    }
    
    // Send E-mail
    func sendMail(){

        // Instantiate compose view controller
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
   
    }
    
    // Alert (Pop up) method
    func displayMessage(ttl: String, msg: String){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    // Email message invite action
    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
        
        // Validate E-mail
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        guard let mailtelNumber = emailRecipient.text else { return }

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if (emailTest.evaluate(with: mailtelNumber) == true){

            print("Send mail")
            self.sendMail()
        }
        else{
            print("invalid email")

            self.validate(phoneNumber: mailtelNumber)
        }
    }
    
    private func validate(phoneNumber: String) {
        
        let PHONE_REGEX = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phoneNumber)
        if (result == true){
            print("valid Phone number")
            self.sendTextMessage()
        }
        else {
            print("Invalid entry")
            displayMessage(ttl: "Cannot Invite Friend", msg: "Your input is invalid.")
        }
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        
        let Recipients = emailRecipient.text
        MessageRecipients = [Recipients!]

        mailComposerVC.setToRecipients( MessageRecipients )
        mailComposerVC.setSubject( subject)
        mailComposerVC.setMessageBody( messageBody, isHTML: false)
        
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        super.title = "Invite Friends"
        
        //textRecipient .delegate = self
        emailRecipient.delegate = self
    }
    
    //hide keyboard
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textRecipient.resignFirstResponder()
        emailRecipient.resignFirstResponder()
        return true
    }
}



class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {

    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = MessageRecipients
        messageComposeVC.body =  messageBody
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
