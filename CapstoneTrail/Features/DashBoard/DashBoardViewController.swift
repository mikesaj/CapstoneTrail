//
//  TabbedDashBoardViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-18.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class DashBoardViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        // Tab Bar Item: Profile
        
        let SignInStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        let profileTab : AnyObject! = SignInStoryboard.instantiateViewController(withIdentifier: "Profile")        
        let tabOneBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uprofileTab = profileTab as! UIViewController
        uprofileTab.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        // Tab Bar Item: Groups
        let HikeGroupStoryboard = UIStoryboard(name: "HikeGroup", bundle: nil)
        let HikeGroupTab : AnyObject! = HikeGroupStoryboard.instantiateViewController(withIdentifier: "HikeGroup")
        let tabtwoBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        let GroupTab = HikeGroupTab as! UIViewController
        GroupTab.tabBarItem = tabtwoBarItem
        
        
        // Create Tab three
        // Tab Bar Item: bookmarks (demo)
        let tab3 = TabTwoViewController()
        let tabTwoBarItem2 = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        tab3.tabBarItem = tabTwoBarItem2
        
        //Add to tabBarController bottom menu
        self.viewControllers = [uprofileTab, GroupTab, tab3]
        
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //print("Selected \(viewController.title!)")
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

class TabOneViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blue
        self.title = "Tab 1"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class TabTwoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.red
        self.title = "Tab 2"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
