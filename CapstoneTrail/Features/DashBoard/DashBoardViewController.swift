//
//  TabbedDashBoardViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-18.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class DashBoardViewController: UITabBarController, UITabBarControllerDelegate {
    
    var friend_uid: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        // Tab Bar Item: Profile
        
        //var profileTab = SignInStoryboard.instantiateViewController(withIdentifier: "Profile") as! SettingsController
        
        
        let SignInStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
        
        let profileTab = SignInStoryboard.instantiateViewController(withIdentifier: "Profile") as! SettingsController
        
        if friend_uid != nil {
            profileTab.friend_uid = friend_uid
        }
        
        let tabOneBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uprofileTab = profileTab
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
        let PeopleStoryboard = UIStoryboard(name: "People", bundle: nil)
        let peolpeTab : AnyObject! = PeopleStoryboard.instantiateViewController(withIdentifier: "People")
        let tabThreeBarItem = UITabBarItem(title: "Add Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uPeopleTab = peolpeTab as! UIViewController
        uPeopleTab.tabBarItem = tabThreeBarItem
        
        //Friend Tab
        let FriendStoryboard = UIStoryboard(name: "Friend", bundle: nil)
        let friendTab : AnyObject! = FriendStoryboard.instantiateViewController(withIdentifier: "Friend")
        let tabFourBarItem = UITabBarItem(title: "My Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uFriendTab = friendTab as! UIViewController
        uFriendTab.tabBarItem = tabFourBarItem
        
        //WalkingSchedule Tab
        let walkingScheduleTboard = UIStoryboard(name: "WalkingSchedule", bundle: nil)
        let walkingScheduleTab : AnyObject! = walkingScheduleTboard.instantiateViewController(withIdentifier: "WalkingSchedule")
        let tabFiveBarItem = UITabBarItem(title: "Walking Schedules", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uWalkingScheduleTab = walkingScheduleTab as! UIViewController
        uWalkingScheduleTab.tabBarItem = tabFiveBarItem
        
        
        //Add to tabBarController bottom menu
        self.viewControllers = [uprofileTab, GroupTab, uPeopleTab, uFriendTab, uWalkingScheduleTab]
        
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
            
        let tabBarIndex = tabBarController.selectedIndex
        
        switch tabBarIndex {
            
            case 0:
                if self.friend_uid != nil{
                    //setting profile to logged user profile
                    let profile = viewController as! SettingsController
                    profile.friend_uid = nil
                    profile.populateUserInfo()
                    self.friend_uid = nil
                }
                break
                
                
            default:
                break
        }
    }
    
}

