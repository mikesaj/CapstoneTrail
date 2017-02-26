//
//  TrailMO+CoreDataProperties.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 2. 22..
//  Copyright © 2017년 MSD. All rights reserved.
//

import Foundation
import CoreData


extension TrailMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrailMO> {
        return NSFetchRequest<TrailMO>(entityName: "Trail");
    }

    @NSManaged public var id: Int32
    @NSManaged public var area: String?
    @NSManaged public var coordinates: NSObject?
    @NSManaged public var length: Double
    @NSManaged public var owner: String?
    @NSManaged public var pathType: String?
    @NSManaged public var status: String?
    @NSManaged public var street: String?
    @NSManaged public var surface: String?

}
