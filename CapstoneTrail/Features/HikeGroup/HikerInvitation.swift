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

let messageBody = "Sending Message through in Swift"


// This class is for composing text & email message invitations
class HikerInvitation: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var textMessage: UITextField!
    @IBOutlet weak var emailRecipient: UITextField!
    
    // for pre-populating the recipients list
    var MessageRecipients = [""]
    let subject = "Subject of the mail"
    
    // Create a MessageComposer
    let messageComposer = MessageComposer()
    
    // Text message invite action
    @IBAction func sendTextMessageButtonTapped(_ sender: UIButton) {
        
        // Initializing text message body
        guard let Recipients = textMessage.text else { return }
        
        // get recipient from textfield
        self.MessageRecipients = [Recipients]

        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    // Email message invite action
    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
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
        
        
        let Recipients = emailRecipient.text
        self.MessageRecipients = [Recipients!]

        mailComposerVC.setToRecipients( self.MessageRecipients )
        mailComposerVC.setSubject( self.subject)
        mailComposerVC.setMessageBody( messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        messageComposeVC.recipients = HikerInvitation().MessageRecipients
        messageComposeVC.body =  messageBody
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
