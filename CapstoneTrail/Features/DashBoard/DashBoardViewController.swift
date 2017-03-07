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
        
        let profileTab = (SignInStoryboard.instantiateViewController(withIdentifier: "Profile")) as! SettingsController
        
        if friend_uid != nil {
            profileTab.friend_uid = friend_uid
        }
        
        let tabOneBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        let uprofileTab = profileTab as! UIViewController

        uprofileTab.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        // Tab Bar Item: Groups
        let HikeGroupStoryboard = UIStoryboard(name: "HikeGroup", bundle: nil)
        let HikeGroupTab : AnyObject! = HikeGroupStoryboard.instantiateViewController(withIdentifier: "GroupsNavController")
        let tabtwoBarItem = UITabBarItem(title: "Groups", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        let GroupTab = HikeGroupTab as! UIViewController
        GroupTab.tabBarItem = tabtwoBarItem
        
        
        // Create Tab one
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

        
        
        /*
        // Create Tab three
        // Tab Bar Item: bookmarks (demo)
        let tab3 = TabTwoViewController()
        let tabTwoBarItem2 = UITabBarItem(title: "Schedule", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        //UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        //let tabTwoBarItem2 = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        tab3.tabBarItem = tabTwoBarItem2
        */

        // Create Tab People
        // Tab Bar Item: People
        let PeopleStoryboard = UIStoryboard(name: "People", bundle: nil)
        let peolpeTab : AnyObject! = PeopleStoryboard.instantiateViewController(withIdentifier: "People")
        let tabThreeBarItem1 = UITabBarItem(title: "Add Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uPeopleTab = peolpeTab as! UIViewController
        uPeopleTab.tabBarItem = tabThreeBarItem1
        
        //Friend Tab
        let FriendStoryboard = UIStoryboard(name: "Friend", bundle: nil)
        let friendTab : AnyObject! = FriendStoryboard.instantiateViewController(withIdentifier: "Friend")
        let tabFourBarItem = UITabBarItem(title: "My Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uFriendTab = friendTab as! UIViewController
        uFriendTab.tabBarItem = tabFourBarItem
        
        //Unblocking Friend Tab
        let UnblockingFriendStoryboard = UIStoryboard(name: "UnblockFriend", bundle: nil)
        let UnblockingfriendTab : AnyObject! = UnblockingFriendStoryboard.instantiateViewController(withIdentifier: "UnblockFriend")
        let tabUnblockingBarItem = UITabBarItem(title: "Unblock Friends", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uUnblockingFriendTab = UnblockingfriendTab as! UIViewController
        uUnblockingFriendTab.tabBarItem = tabUnblockingBarItem
        
        //WalkingSchedule Tab
        let walkingScheduleTboard = UIStoryboard(name: "WalkingSchedule", bundle: nil)
        let walkingScheduleTab : AnyObject! = walkingScheduleTboard.instantiateViewController(withIdentifier: "WalkingSchedule")
        let tabFiveBarItem = UITabBarItem(title: "Walking Schedules", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIcon"))
        
        let uWalkingScheduleTab = walkingScheduleTab as! UIViewController
        uWalkingScheduleTab.tabBarItem = tabFiveBarItem
        
        // Main DashBoard Tabs
        //Add to tabBarController bottom menu
        //self.viewControllers =
           //[uprofileTab, GroupTab, SchedulTab, uFriendTab, uPeopleTab, uUnblockingFriendTab, invitationTab, SchedulTab, uWalkingScheduleTab]// invitationTab,
        
        self.viewControllers =
            [uprofileTab, uFriendTab, uPeopleTab, uUnblockingFriendTab,]
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

