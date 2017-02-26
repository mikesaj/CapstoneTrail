//
//  TrailListTableViewController.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 22..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit
import CoreData


class TrailListTableViewController: UITableViewController {

    // MARK: Variables
    var trails: [NSManagedObject] = []

    override func viewDidLoad() {

        super.viewDidLoad()
    }


    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // Setup for fetch
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trail")

        do {
            trails = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return trails.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Prepare for table cell data
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrailTableViewCell", for: indexPath) as? TrailTableViewCell else {
            fatalError("The dequeued cell is not an instance of TrailTableViewCell")
        }
        let trail = trails[indexPath.row]

        // Shorten strings
        let areaName = trail.value(forKey: "area") as! String
        let streetNameString = NSLocalizedString("StreetName", comment: "Street name near the trail")
        let trailBriefString = NSLocalizedString("TrailBrief", comment: "Brief data of the trail")
        let streetName = trail.value(forKey: "street") as! String
        let length = trail.value(forKey: "length") as! Double
        let trailType = trail.value(forKey: "pathType") as! String

        // Assign values
        cell.areaLogoImage.image = UIImage(named: "Area\(areaName)")
        cell.streetNameLabel.text = String(format: streetNameString, streetName)
        cell.trailBriefLabel.text = String(format: trailBriefString, length, trailType.capitalized)

        return cell
    }

    //MARK: - Navigation
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        switch (segue.identifier ?? "") {
            case "CheckTrailDetail":
                // Create destination
                guard let trailDetailViewController = segue.destination as? TrailDetailViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let selectedTrailCell = sender as? TrailTableViewCell else {
                    fatalError("Unexpected sender: \(sender)")
                }
                guard let indexPath = tableView.indexPath(for: selectedTrailCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }

                let selectedTrail = trails[indexPath.row]
                trailDetailViewController.trail = selectedTrail

            default:
                fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}
