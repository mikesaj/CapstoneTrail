//
//  TrailUtils.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 26..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON


class TrailUtils {

    // Calculate metre to minute by average human walking speed
    class func metre2minute(lengthIn metre: Double) -> Double {

        return metre * 0.012
    }


    // Search trail from Core Data
    class func searchTrail(id: String) -> NSManagedObject {

        var trails: [NSManagedObject] = []

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trail")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate

        do {
            trails = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }

        if trails.count == 1 {
            return trails[0]
        } else {
            fatalError("Trail identities are conflicted")
        }
    }

    // Create CLLocationCoordinate2D list from double type coordinates
    class func makeCoordinate2D(coordinates: [[Double]]) -> [CLLocationCoordinate2D] {

        // CLLocationCoordinate2D container
        var coordinates2DList: [CLLocationCoordinate2D] = []
        for coordinate in coordinates {
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate[1], coordinate[0])
            coordinates2DList.append(point)
        }

        return coordinates2DList
    }


    class func getBearing(p1: CLLocationCoordinate2D, p2: CLLocationCoordinate2D) -> Double {

        func degToRad(degrees: Double) -> Double {

            return degrees * M_PI / 180.0 }


        let p1Lat = degToRad(degrees: p1.latitude)
        let p1Lon = degToRad(degrees: p1.longitude)
        let p2Lat = degToRad(degrees: p2.latitude)
        let p2Lon = degToRad(degrees: p2.longitude)

        let radDistance = acos(sin(p1Lat) * sin(p2Lat) + cos(p1Lat) * cos(p2Lat) * cos(p1Lon - p2Lon))
        let radBearing = 2 * M_PI - acos((sin(p2Lat) - sin(p1Lat) * cos(radDistance)) / (cos(p1Lat) * sin(radDistance)))

        if sin(p2Lon - p1Lon) < 0 {
            return 2 * M_PI - radBearing
        }

        return radBearing
    }
}
