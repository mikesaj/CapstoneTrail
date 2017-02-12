//
//  dashBoardController.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-01-30.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class DashBoardViewController: UIViewController {
    
    @IBOutlet weak var dashBoardScrollView: UIScrollView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sliderView()
    }
    
    // This method enables view sliding (LEFT <--> RIGHT)
    func sliderView(){
    
        // View 1
        let V1 = self.storyboard?.instantiateViewController(withIdentifier: "V1") as UIViewController!
        self.addChildViewController(V1!)
        self.dashBoardScrollView.addSubview(V1!.view)
        V1?.didMove(toParentViewController: self)
        V1?.view.frame = dashBoardScrollView.bounds
        
        // View 2
        let V2 = self.storyboard?.instantiateViewController(withIdentifier: "V2") as UIViewController!
        self.addChildViewController(V2!)
        self.dashBoardScrollView.addSubview(V2!.view)
        V2?.didMove(toParentViewController: self)
        V2?.view.frame = dashBoardScrollView.bounds
        
        var V2Frame: CGRect = V2!.view.frame
        V2Frame.origin.x = self.view.frame.width
        V2!.view.frame = V2Frame
        
        // View 3
        let V3 = self.storyboard?.instantiateViewController(withIdentifier: "V3") as UIViewController!
        self.addChildViewController(V3!)
        self.dashBoardScrollView.addSubview(V3!.view)
        V3?.didMove(toParentViewController: self)
        V3?.view.frame = dashBoardScrollView.bounds
        
        var V3Frame: CGRect = V3!.view.frame
        V3Frame.origin.x = 2 * self.view.frame.width
        V3!.view.frame = V3Frame
        
        
        // Set initial Controller View
        self.dashBoardScrollView.contentSize   = CGSize(width: (self.view.frame.width) * 3, height: (self.view.frame.height))
        //self.dashBoardScrollView.contentOffset = CGPoint(x:(self.view.frame.width) * 1, y: (self.view.frame.height)) // * 1: means skip one view and start from the second view
    
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
