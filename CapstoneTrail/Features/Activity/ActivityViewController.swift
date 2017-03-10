//
//  ActivityViewController.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-10.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit
import HealthKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var stepsLabel: UILabel!

    let today = NSDate()
    var yesterday = NSDate()
    
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
        //let dataTypesToWrite = NSSet(object: stepCountQuantityType)
        let dataTypesToRead  = NSSet(object: stepCountQuantityType)

        healthStore?.requestAuthorization(toShare: nil, read: dataTypesToRead as? Set<HKObjectType>,completion: { (success, error) -> Void in
            if success {
                print("success")
            } else {
                print(error.debugDescription)
            }
        })
    }
    
    
    func readFromHealthStore() {
        
        // Get permission from the user to read HealthStore
        self.startHealthShit()
        
        // change date to yesterday
        yesterday = self.today.addingTimeInterval(-24 * 60 * 60)
    
        let stepCountQuantityType = HKCharacteristicType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
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
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
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
            
            
        }
        
        healthStore?.execute(query)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.readFromHealthStore()
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






