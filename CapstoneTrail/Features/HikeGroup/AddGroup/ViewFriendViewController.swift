//
//  viewFriendViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class ViewFriendViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var titleString: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.titleString
    
    
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
