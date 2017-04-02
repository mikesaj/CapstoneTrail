//
//  HistoryTableViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-04-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import Firebase

class HistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // Firebase reference instance
    let ref = FIRDatabase.database().reference()
    
    // Current user id
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    var hikeIds = [String]()
    var trailIds = [String]()
    var trailNames = [String]()
    var hikeDate = [String]()
    var trailData = [[Trail]]()
    var tid: Int = 0
    
    @IBOutlet weak var historyTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.populateHikeInviteList()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hikeIds.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "hikeCell", for: indexPath) as! HistoryTableViewCell
        
        //print(" name:\(self.trailNames[indexPath.row])  Date:\(self.hikeDate  [indexPath.row])")
        
        //labels
        cell.trailName.text     = self.trailNames[indexPath.row]
        cell.completedDate.text = self.hikeDate  [indexPath.row]
        
        tid = indexPath.row
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // launch segue for row
        performSegue(withIdentifier: "hikeProfile", sender: self)
        
        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // ViewFriendViewController

        if(segue.identifier == "hikeProfile"){
            
            let HistoryProfile: HistoryProfileViewController = segue.destination as! HistoryProfileViewController
            
            // Passing parameters to the inviteFriendsController class
            //print("Hikesx:  \(self.trailIds[tid] )  \( tid)")
            HistoryProfile.trailData    = self.trailData[tid]           // id of the group
            HistoryProfile.currdate     = self.hikeDate[tid]
            //let _trail: [Trail] = trailData[indexPath.row]

        }
    }    

    
    //populating hike inviations
    func populateHikeInviteList() {
        
        _ = ref.child("users")
            .queryOrderedByKey()
            .queryEqual(toValue: self.uid)
            .observe(.childAdded, with: {
                (snapshot) in
                
                let value = snapshot.value as? [String: AnyObject]
                
                if value != nil {
                    
                    var hikingHistory = [String]()
                    
                    if value?["hikingHistory"] != nil {
                        
                        // get hike invites
                        hikingHistory = (value?["hikingHistory"] as? [String])!
                        
                    }
                    
                    for hike in hikingHistory {
                        
                        _ = self.ref.child("walkingSchedules")
                            .queryOrderedByKey()
                            .queryEqual(toValue: hike)
                            .observe(.childAdded, with: {
                                (snapshot) in
                                
                                let value = snapshot.value as? [String: AnyObject]

                                if value != nil {

                                    self.hikeIds.append(snapshot.key)
                                    self.trailNames.append(value?["trail"] as! String)
                                    
                                    let _date = value?["epochDate"] as! NSNumber
                                    let _dateStr = self.dateconverter(epochTime:_date)
                                    
                                    self.hikeDate.append( _dateStr )
                                    
                                    print("Hikes:  \(value?["trail"] )  \(_date )")
                                    
                                    
                                    let vare = value?["trailId"]
                                    // FIXME: "trailId" is an array of string
                                    self.trailIds.append(String(describing: vare))
                                    
                                    
                                    // Add area and epoch time
                                    let _IDs = value?["trailId"] as! [String]
                                    var _trails: [Trail] = []
                                    for _ID in _IDs {
                                        let _trailMO = TrailUtils.searchTrail(id: _ID)
                                        _trails.append(Trail(trail: _trailMO))
                                    }

                                    
                                    
                                    self.trailData.append(_trails)

                                    //refresh the table
                                    self.historyTableView.reloadData()

                                }
                            }) {
                                (error) in
                                print(error.localizedDescription)
                        }
                    }
                }
            }) {
                (error) in
                print(error.localizedDescription)
        }
    }
    
    
    
    func dateconverter(epochTime:NSNumber) -> String{
        print(epochTime)
        let unixTimestamp = Double(epochTime)//1480134638.0
        //let date = Date(timeIntervalSince1970: unixTimestamp)
        
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM/dd/yyyy" //Specify your format that you want
        return dateFormatter.string(from: date)
    
    }
}
