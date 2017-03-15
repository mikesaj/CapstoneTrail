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


    //var startdate  = Date()
    //var enddate    = Date()
    var data       = NSMutableArray()
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
    func startHealthShit(startDate: Date, endDate: Date, steps: Int) {
        //startHealthShit(startDate: self.startDate, endtDate: Date(), steps: StepsData)
        
        let stepCountQuantityType = HKCharacteristicType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let dataTypesToWrite = NSSet(object: stepCountQuantityType)
        let dataTypesToRead  = NSSet(object: stepCountQuantityType)

        healthStore?.requestAuthorization(toShare: dataTypesToWrite as? Set<HKObjectType> as! Set<HKSampleType>?, read: dataTypesToRead as? Set<HKObjectType>,completion: { (success, error) -> Void in
            if success {
                // Method Writes to HealthStore
                self.writeToHealthStore(startDate: startDate, endDate: endDate, steps: steps)
                
                // Method Reads from HealthStore
                //self.readFromHealthStore()
            } else {
                print(error.debugDescription)
            }
        })
    }
    
    // Method Writes to HealthStore
    func writeToHealthStore(startDate: Date, endDate: Date, steps: Int) {
        // change date to yesterday
        
        //yesterday = self.today.addingTimeInterval(-24 * 60 * 60)
        //var start = Date().addingTimeInterval(-2 * 60 * 60)
        //var end   = Date().addingTimeInterval(2 * 60 * 60)
        
        
        //yesterday = dateToLocalDate(date: start)
        //today = dateToLocalDate(date: end)

        
        let stepsQuantityType = HKQuantityType.quantityType( forIdentifier: HKQuantityTypeIdentifier.stepCount )
        
        let stepsUnit = HKUnit.count()
        let stepsQuantity = HKQuantity(unit: stepsUnit, doubleValue: Double(steps))
        
        let stepsQuantitySample = HKQuantitySample(
            type: stepsQuantityType!,
            quantity: stepsQuantity,
            start: startDate as Date,
            end: endDate as Date)
        
        
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
                        print("\(steps) Saved steps!!")
                        print("Start Date: \(startDate)")
                        print("End Date:   \(endDate)")
                    } else {
                        // handle error
                    }
                })

            }
        }
    }
    
    
    func dateToLocalDate(date: Date) -> Date{
        
        //let date = NSDate();
        // "Apr 1, 2015, 8:53 AM" <-- local without seconds
        
        var formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
        let defaultTimeZoneStr = formatter.string(from: date as Date);
        // "2015-04-01 08:52:00 -0400" <-- same date, local, but with seconds
        formatter.timeZone = NSTimeZone(abbreviation: "EST") as TimeZone!;
        let utcTimeZoneStr = formatter.string(from: date as Date);
        // "2015-04-01 12:52:00 +0000" <-- same date, now in UTC
        
        
        // convert string into date
        let dateValue = formatter.date(from: utcTimeZoneStr) as NSDate!

        print(utcTimeZoneStr)
        
        return dateValue as! Date
    }
    
    /*
    // Method Reads from HealthStore
    func readFromHealthStore() {
        
        // change date
        //var startdate = Date().addingTimeInterval(-2 * 60 * 60)
        //var enddate   = Date().addingTimeInterval(2 * 60 * 60)
        
        
        //startdate = dateToLocalDate(date: startdate)
        //enddate   = dateToLocalDate(date: enddate)
        
    
        let stepCountQuantityType = HKCharacteristicType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: startdate as Date, end: enddate as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let stepsSampleQuery = HKStatisticsCollectionQuery(quantityType: stepCountQuantityType!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startdate as Date, intervalComponents:interval as DateComponents)
        print("Result")
        stepsSampleQuery.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print("Result is\n")
                print(results)
                print(error)
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: self.startdate as Date, to: self.enddate as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        var steps1 = Int(steps)
                        
                        print("Steps = \(steps1)")
                        //self.stepsLabel.text = "Steps: \(steps)"
                        
                        self.data.add("\(steps1) Walking Steps")
                        
                        var dating = " \(String(describing: self.startdate)) to \(String(describing: self.enddate)) "

                        self.data.add("\(dating)")
                        print(dating)

                        //self.activityDetailTable.reloadData()
                        
                        //completion(stepRetrieved: stepsSampleQuery)
                        
                    }
                }
            }
            
            
        }
        
        /*
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

        }*/

        // execute the healthstore query
        healthStore?.execute(stepsSampleQuery)
    }
    */
    
    
    /*
     
     FUNCTION TO BE TESTED ON A REAL iPHONE DEVICE
     
     */
    /*
    func testhealthCode() {
        // Do any additional setup after loading the view, typically from a nib.
//        var endDate   = Date()//.addingTimeInterval(2 * 60 * 60)
//        var startDate = Date().addingTimeInterval(-24 * 60 * 60)
        
        
        let weightSampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startdate as Date, end: enddate as Date, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: weightSampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            
            DispatchQueue.main.async {
                
                var dailyAVG:Double = 0
                for steps in results as! [HKQuantitySample]
                {
                    // add values to dailyAVG
                    dailyAVG += steps.quantity.doubleValue(for: HKUnit.count())
                    print(dailyAVG)
                    print(steps)
                    
                    self.data.add("Daily Average: \(dailyAVG)")
                    //self.activityDetailTable.reloadData()
                }
            }
        })
        
        // execute the healthstore query
        healthStore?.execute(query)
    }
    */
    
    
    
    
    
    
    
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

        
        
        //startdate = Date()-(24*60*60)//.addingTimeInterval(-24 * 60 * 60)
        //enddate   = Date()//.addingTimeInterval(-3 * 60 * 60)
        
        
        //startdate = dateToLocalDate(date: start)
        //enddate   = dateToLocalDate(date: end)

        
        //self.startHealthShit()
        
        //test
        //self.testhealthCode()
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


