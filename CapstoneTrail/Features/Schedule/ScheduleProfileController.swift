//
//  ScheduleProfileController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class ScheduleProfileController: UIViewController {

    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var members: UILabel!
    
    var uid:String = ""
    var scheduleTitle:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.routeName.text = scheduleTitle
        print(self.uid)        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
