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
    var timer = Timer()
    var index:Int = 0
    var isRunning: Bool = false
    
    @IBOutlet var imgDirection: WKInterfaceImage!
    @IBOutlet var lblDistance: WKInterfaceLabel!
    @IBOutlet var lblInstruction: WKInterfaceLabel!
    @IBOutlet var btnStart: WKInterfaceButton!
    
    @IBAction func btnStart_Click() {
        
        if self.isRunning == false{
            self.lblInstruction.setText("Establishing connection...")
            index = 0
            self.isRunning = true
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
                _ in self.onTick()
            }
        }
        else
        {
            self.lblInstruction.setText("Closing connection...")
            self.sendInfoToPhone(i: 0)
            self.isRunning = false
            self.timer.invalidate()
        }
    }

    func onTick(){
        self.sendInfoToPhone(i: index)
        index = index + 1
    }
    
    func sendInfoToPhone(i:Int){
        let messageToSend = ["index":i]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            print("OK")
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
        
        self.lblInstruction.setText("Let's Walk")
        
        let theImage = UIImage(named: "crossroads")
        self.imgDirection.setImage(theImage)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("completed")
    }    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let distance = message["distance"] as! String
        let instructions = message["instructions"] as! String
        let isDone = message["isDone"] as! Bool
        
        let imageName = message["imageName"] as! String
        var theImage = UIImage(named: imageName)

        self.lblDistance.setText(distance)
        self.lblInstruction.setText(instructions)
        self.imgDirection.setImage(theImage)
        
        if isDone == false{
            self.btnStart.setTitle("Stop")
            self.isRunning = true
        }
        else{
            self.btnStart.setTitle("Start")
            self.isRunning = false
            self.timer.invalidate()
            
            let isStopped = message["isStopped"] as! Bool
            
            if isStopped == true{
                self.lblInstruction.setText("Let's Walk")
                theImage = UIImage(named: "crossroads")
                self.imgDirection.setImage(theImage)
            }
            else{
                let h0 = { print("OK")}
                let action = WKAlertAction(title: "OK!", style: .default, handler: h0)
                presentAlert(withTitle: "Congratulations!", message: "You have completed the trail", preferredStyle: .alert, actions: [action])
            }
        }
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
