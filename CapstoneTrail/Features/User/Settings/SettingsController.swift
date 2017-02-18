//
//  SettingsController.swift
//  capstone
//
//  Created by Michael Sajuyigbe on 2017-02-01.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    // Declares a table view in the update profile layout-view
    @IBOutlet weak var tableView: UITableView!
    
    // table elemets
    var settingsTitle = ["Update Profile", "Change Avatar", "Delete my account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.dataSource = self
        //tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The method determines the amount of rows in a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsTitle.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        // get table cell title by row id
        cell.textLabel?.text = settingsTitle[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SettingCellController", sender: nil)
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
