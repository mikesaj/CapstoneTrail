//
//  ActivityViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-10.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import HealthKit

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    let today     = NSDate()
    var yesterday = NSDate()
    var data = NSMutableArray()
    @IBOutlet weak var activityDetailTable: UITableView!
    
    // HeathStore instantiation with a Singleton Design Pattern
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()

    // Get permission from the user to read HealthStore
    func startHealthShit() {
        
        let stepCountQuantityType = HKCharacteristicType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let dataTypesToWrite = NSSet(object: stepCountQuantityType)
        let dataTypesToRead  = NSSet(object: stepCountQuantityType)

        healthStore?.requestAuthorization(toShare: dataTypesToWrite as? Set<HKObjectType> as! Set<HKSampleType>?, read: dataTypesToRead as? Set<HKObjectType>,completion: { (success, error) -> Void in
            if success {
                // Method Writes to HealthStore
                self.writeToHealthStrore()
                
                // Method Reads from HealthStore
                self.readFromHealthStore()
            } else {
                print(error.debugDescription)
            }
        })
    }
    
    // Method Writes to HealthStore
    func writeToHealthStrore() {
        // change date to yesterday
        yesterday = self.today.addingTimeInterval(-24 * 60 * 60)
        
        let stepsQuantityType = HKQuantityType.quantityType( forIdentifier: HKQuantityTypeIdentifier.stepCount )
        
        let stepsUnit = HKUnit.count()
        let stepsQuantity = HKQuantity(unit: stepsUnit, doubleValue: 31200)
        
        let stepsQuantitySample = HKQuantitySample(
            type: stepsQuantityType!,
            quantity: stepsQuantity,
            start: yesterday as Date,
            end: today as Date)
        
        
        // Check authorization before read operation is performed
        if let authorizationStatus = healthStore?.authorizationStatus(for: stepsQuantityType!) {
            
            switch authorizationStatus {
                
            case .notDetermined:
                //requestHealthKitAuthorization()
                print("notDetermined")
                break
            case .sharingDenied:
                //showSharingDeniedAlert()
                print("sharingDenied")
                break
            case .sharingAuthorized:
                print("sharingAuthorized")
                healthStore?.save(stepsQuantitySample, withCompletion: { (success, error) -> Void in
                    if success {
                        // handle success
                        print("Saved steps")
                    } else {
                        // handle error
                    }
                })

            }
        }
    }
    
    // Method Reads from HealthStore
    func readFromHealthStore() {
        
        // change date to yesterday
        yesterday = self.today.addingTimeInterval(-24 * 60 * 60)
    
        let stepCountQuantityType = HKCharacteristicType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        /*
        //   Get the start of the day
        let date = NSDate()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepCountQuantityType!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval as DateComponents)
        print("Result")
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print("Result is\n")
                print(results)
                print(error)
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: self.yesterday as Date, to: self.today as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        print("Steps = \(steps)")
                        self.stepsLabel.text = "Steps: \(steps)"
                        //completion(stepRetrieved: steps)
                        
                    }
                }
            }
            
            
        }*/
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepCountQuantityType!,
                                             predicate: nil,
                                             limit: 100,
                                             sortDescriptors: nil)
        { [unowned self] (query, results, error) in
            print(results)
            
            if let results = results as? [HKQuantitySample] {

                //set viewController label to step counts
                
                let stepsCount = String(describing: results[0].quantity)
                var parts      = stepsCount.components(separatedBy: " ")// ... Split on comma chars.

                // dateFrom
                let dateFrom = String(describing: results[0].startDate)
                var parts2   = dateFrom.components(separatedBy: " ") // ... Split on comma chars.
                
                // dateTo
                let dateTo   = String(describing: results[0].endDate)
                var parts3   = dateTo.components(separatedBy: " ")   // ... Split on comma chars.

                // Result has 3 strings.
                self.data.add("\(parts[0]) Walking Steps")
                self.data.add("Date From: \(parts2[0])")
                self.data.add("Date To: \(parts3[0])")
                
                self.activityDetailTable.reloadData()
            }

        }
        
        // execute the healthstore query
        healthStore?.execute(stepsSampleQuery)
    }
    
    // MARK: - Controller Table View
    // Getting the number of rows in firendName collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = self.data[indexPath.row] as? String
        cell.textLabel?.textColor = UIColor.darkGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // deselect the selected cell background view.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startHealthShit()
        // Do any additional setup after loading the view.
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


