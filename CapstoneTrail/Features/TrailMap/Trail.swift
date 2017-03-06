//
// Created by Joohyung Ryu on 2017. 3. 5..
// Copyright (c) 2017 MSD. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit


class Trail {
    var id: Int32
    var area: String
    var street: String
    var status: String
    var surface: String
    var pathType: String
    var owner: String
    var length: Double
    var coordinates: [[Double]]

    var travelTime: Double
    var coordinate2DList: [CLLocationCoordinate2D] = []

    init(trail: NSManagedObject) {
        self.id = trail.value(forKey: "id") as! Int32
        self.area = trail.value(forKey: "area") as! String
        self.street = trail.value(forKey: "street") as! String
        self.status = trail.value(forKey: "status") as! String
        self.surface = trail.value(forKey: "surface") as! String
        self.pathType = trail.value(forKey: "pathType") as! String
        self.owner = trail.value(forKey: "owner") as! String
        self.length = trail.value(forKey: "length") as! Double
        self.coordinates = trail.value(forKey: "coordinates") as! [[Double]]

        self.travelTime = TrailUtils.metre2minute(lengthIn: self.length)
        self.coordinate2DList = makeCoordinate2D()
    }


    func makeCoordinate2D() -> [CLLocationCoordinate2D] {

        var coordinate2DList: [CLLocationCoordinate2D] = []

        for coordinate in coordinates {
            let coordinate2D = CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0])
            coordinate2DList.append(coordinate2D)
        }

        return coordinate2DList
    }
}
