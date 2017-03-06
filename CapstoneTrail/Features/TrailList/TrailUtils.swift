//
//  TrailUtils.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 26..
//  Copyright © 2017년 MSD. All rights reserved.
//

import UIKit
import CoreData


class TrailUtils {

    class func metre2minute(lengthIn metre: Double) -> Double {

        return metre * 0.012
    }


    class func searchTrail(id: Int32, area: String) -> NSManagedObject {

        var trails: [NSManagedObject] = []

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trail")
        let predicateId = NSPredicate(format: "id == %d", id)
        let predicateArea = NSPredicate(format: "area == %@", area)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateId, predicateArea])
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
}
