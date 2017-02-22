//
//  AppDelegate.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 7..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import CoreData
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FIRApp.configure()

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        FBSDKApplicationDelegate.sharedInstance()
                                .application(application, didFinishLaunchingWithOptions: launchOptions)

        // Customize navigation bar
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.blue()
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        // MARK: Populate trail data on CoreData
        // User defaults for map version
        let userDefaults = UserDefaults.standard
        // Fetch trail data from JSON files
        let supportingArea = ["Kitchener", "Waterloo"]
        var areaData = [String: JSON]()
        for area in supportingArea {
            let startTime = DispatchTime.now()
            areaData[area] = getJSON(nameOf: area)
            let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
            debugPrint("\(area) map file fetched in \(elapsedTime) seconds")
        }

        // Check map data exists
        if let mapVersion = userDefaults.value(forKey: "mapVersion") as? Int {
            debugPrint("Current Version:\(mapVersion)")
            if mapVersion == areaData[supportingArea[0]]!["MAP_INFO"]["DATA_VERSION"].intValue {
                debugPrint("Versions are identical")
            } else {
                debugPrint("Versions are not identical")
            }
        } else {
            debugPrint("No map data exists")
            for area in supportingArea {
                // Set current map version to UserDefaults
                userDefaults.setValue(areaData[area]!["MAP_INFO"]["DATA_VERSION"].intValue, forKey: "mapVersion")
                // Store single data to CoreData with Trail object
                let startTime = DispatchTime.now()
                for (_, trail) in areaData[area]!["TRAILS"] { storeOnCoreData(dataOf: trail, nameOf: area) }
                let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
                debugPrint("\(area) map data created in \(elapsedTime) seconds")
            }
        }

        return true
    }

    // MARK: Populate trail data on CoreData
    // Get JSON data from file
    private func getJSON(nameOf area: String) -> JSON {

        guard let path = Bundle.main.path(forResource: area, ofType: "json") else {
            debugPrint("No such file")

            return JSON.null
        }

        let fileData = NSData(contentsOfFile: path)
        let trailJSON = JSON(data: fileData as! Data)

        return trailJSON
    }

    // Store single data to CoreData
    func storeOnCoreData(dataOf trail: JSON, nameOf area: String) {

        // Setup for storing
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let trailEntity = NSEntityDescription.entity(forEntityName: "Trail", in: managedContext)
        let trailMO = NSManagedObject(entity: trailEntity!, insertInto: managedContext) as! TrailMO

        // Assign data
        trailMO.id = trail["ID"].int32Value
        trailMO.area = area
        trailMO.street = trail["STREET"].stringValue
        trailMO.status = trail["STATUS"].stringValue
        trailMO.surface = trail["SURFACE"].stringValue
        trailMO.owner = trail["OWNER"].stringValue
        trailMO.pathType = trail["PATH_TYPE"].stringValue
        trailMO.length = trail["LENGTH"].doubleValue
        trailMO.coordinates = trail["COORDINATES"].arrayObject as NSObject?

        do {
            // Saving data
            try managedContext.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }


    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        let handled = FBSDKApplicationDelegate.sharedInstance()
                                              .application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])

        GIDSignIn.sharedInstance()
                 .handle(url,
                         sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
                         annotation: options[UIApplicationOpenURLOptionsKey.annotation])

        return handled;
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if let err = error {
            print("Error to log into Google: ", err)
            return
        }

        print("Successfully logged into Google", user)

        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }

        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        FIRAuth.auth()?.signIn(with: credentials, completion: {
            (user, error) in

            if let err = error {
                print("Error to create a Firebase User with Google account: ", err)
                return
            }

            guard let uid = user?.uid else { return }              // For client-side use only!


            print("Successfully logged into Firebase with Google", uid)

            // guard let idToken = user?.refreshToken else { return } // Safe to send to the server
            guard let name = user?.displayName else { return }
            guard let email = user?.email else { return }

            print("Welcome: \n \(uid) \n \(name) \n \(email)")

            // self.window = UIWindow(frame: UIScreen.main.bounds)
            // self.window?.makeKeyAndVisible()
            // self.window?.rootViewController = UINavigationController(rootViewController: ViewController())


            //switch view to DashBoard Storyboard
            let dashboard = LoginViewController()
            dashboard.switchToDashBoardView()
        })
    }


    func applicationWillResignActive(_ application: UIApplication) {

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }


    func applicationDidEnterBackground(_ application: UIApplication) {

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }


    func applicationWillEnterForeground(_ application: UIApplication) {

        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }


    func applicationDidBecomeActive(_ application: UIApplication) {

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


    func applicationWillTerminate(_ application: UIApplication) {

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Trails")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {

        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension UIColor {
    static func blue() -> UIColor {

        return UIColor(red: (0.0/255.0), green: (118.0/255.0), blue: (255.0/255.0), alpha: 1.0)
    }
}
