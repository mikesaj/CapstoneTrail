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
        let HikeGroupTab : AnyObject! = HikeGroupStoryboard.instantiateViewController(withIdentifier: "GroupsNavController")
        let tabtwoBarItem = UITabBarItem(title: "Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        let GroupTab = HikeGroupTab as! UIViewController
        GroupTab.tabBarItem = tabtwoBarItem
        
        
        // Create Tab two
        // Tab Bar Item: Groups
        let JoinAppTab : AnyObject! = HikeGroupStoryboard.instantiateViewController(withIdentifier: "HikerInvitation")
        let invitationBarItem = UITabBarItem(title: "Invite", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        let invitationTab = JoinAppTab as! UIViewController
        invitationTab.tabBarItem = invitationBarItem

        
        // Create Tab three
        // Tab Bar Item: Schedule
        let ScheduleStoryboard = UIStoryboard(name: "Schedule", bundle: nil)
        let ScheduleTab : AnyObject! = ScheduleStoryboard.instantiateViewController(withIdentifier: "ScheduleNavController") // "ScheduleList"
        let tabThreeBarItem = UITabBarItem(title: "Schedule", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        let SchedulTab = ScheduleTab as! UIViewController
        SchedulTab.tabBarItem = tabThreeBarItem

        
        
        
        // Create Tab three
        // Tab Bar Item: bookmarks (demo)
        let tab3 = TabTwoViewController()
        let tabTwoBarItem2 = UITabBarItem(title: "Schedule", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        //UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        //let tabTwoBarItem2 = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        tab3.tabBarItem = tabTwoBarItem2
        
        
        
        
        
        //Add to tabBarController bottom menu
        self.viewControllers = [uprofileTab, GroupTab, invitationTab, SchedulTab] // , tab3
        
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
        self.title = "Friend"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
