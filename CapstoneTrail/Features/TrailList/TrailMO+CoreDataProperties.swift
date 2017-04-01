//
//  TrailMO+CoreDataProperties.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 18..
//  Copyright © 2017년 MSD. All rights reserved.
//

import Foundation
import CoreData


extension TrailMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrailMO> {
        return NSFetchRequest<TrailMO>(entityName: "Trail");
    }

    @NSManaged public var area: String?
    @NSManaged public var coordinates: NSObject?
    @NSManaged public var houseNumber: String?
    @NSManaged public var id: String?
    @NSManaged public var length: Double
    @NSManaged public var neighbours: NSObject?
    @NSManaged public var owner: String?
    @NSManaged public var pathType: String?
    @NSManaged public var status: String?
    @NSManaged public var street: String?
    @NSManaged public var surface: String?

}
