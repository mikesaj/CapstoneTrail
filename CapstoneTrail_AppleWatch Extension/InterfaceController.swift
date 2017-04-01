//
//  InterfaceController.swift
//  CapstoneTrail_AppleWatch Extension
//
//  Created by Alessandro Santos on 2017-03-26.
//  Copyright © 2017 MSD. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate{
    
    var session: WCSession!
    
    
    @IBOutlet var imgDirection: WKInterfaceImage!
    @IBOutlet var lblDistance: WKInterfaceLabel!
    
    @IBAction func btnStart_Click() {
        let messageToSend = ["Value":"Directions"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["directions"] as? String
            
            self.lblDistance.setText(value)
            
            }, errorHandler: {error in
                // catch any errors here
                print(error)
        })
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("completed")
    }    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let distance = message["distance"] as! String
        let instructions = message["instructions"] as! String
        
        self.lblDistance.setText(distance)
        
        //replyHandler (answer as [String : Any])
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    


}
