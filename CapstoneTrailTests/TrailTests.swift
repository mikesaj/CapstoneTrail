//
//  TrailTests.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 5..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import XCTest
@testable import CapstoneTrail
import CoreData
import CoreLocation


class TrailTests: XCTestCase {

    // MARK: Variables
    var testBed: TrailMapViewController!
    var testObject: NSManagedObject!
    var trail: Trail!

    override func setUp() {

        super.setUp()

        let storyboard = UIStoryboard(name: "TrailMap", bundle: nil)
        testBed = storyboard.instantiateViewController(withIdentifier: "TrailMap") as! TrailMapViewController

        XCTAssertNotNil(testBed.view, "Instantiated view must not be nil")
        XCTAssertNotNil(testBed.viewWillAppear(false), "ViewWillAppear must be executable")

        testObject = testBed.trailList[0]
        trail = Trail(trail: testObject)
    }


    override func tearDown() {

        super.tearDown()
    }


    // Mark: initialize tests
    func testInit_ShouldSetPropertiesFromTrailMO() {

        XCTAssertEqual(trail.id, testObject.value(forKey: "id") as! Int, "Initializer should set id")
        XCTAssertEqual(trail.area, testObject.value(forKey: "area") as! String, "Initializer should set area")
        XCTAssertEqual(trail.street, testObject.value(forKey: "street") as! String, "Initializer should set Street")
        XCTAssertEqual(trail.status, testObject.value(forKey: "status") as! String, "Initializer should set status")
        XCTAssertEqual(trail.surface, testObject.value(forKey: "surface") as! String, "Initializer should set surface")
        XCTAssertEqual(trail.pathType, testObject.value(forKey: "pathType") as! String, "Initializer should set pathType")
        XCTAssertEqual(trail.owner, testObject.value(forKey: "owner") as! String, "Initializer should set owner")
        XCTAssertEqual(trail.length, testObject.value(forKey: "length") as! Double, "Initializer should set length")
        // Test for not nil, because cannot compare with nested array of coordinate
        XCTAssertNotNil(trail.coordinates, "Initializer should set coordinates")
    }


    func testCoordinate2DList_AreNotNil() {

        XCTAssertNotNil(trail.coordinate2DList, "Coordinates can transform to CLLocationCoordinate2D")
        XCTAssertNotEqual(trail.coordinate2DList.count, 0, "A coordinate must have more than 1 coordinate")
    }


    func testCoordinate2D_HasNotEmptyValue() {

        for coordinate2D in trail.coordinate2DList {
            XCTAssertNotEqual(coordinate2D, CLLocationCoordinate2D())
        }
    }

    // MARK: function makeCoordinate2D tests
    func testMakeCoordinate2D_ReturnsCLLocationCoordinate2D() {

        let testCoordinate2Ds = trail.makeCoordinate2D()

        for (index, element) in trail.coordinates.enumerated() {
            let latitude = element[1]
            let longitude = element[0]

            XCTAssertEqual(testCoordinate2Ds[index].latitude, latitude, "Both latitude must be same")
            XCTAssertEqual(testCoordinate2Ds[index].longitude, longitude, "Both longitude must be same")
        }
    }


    func testCoordinate2DList_HasSameValueWithCoordinates() {

        for (index, element) in trail.coordinates.enumerated() {
            let latitude = element[1]
            let longitude = element[0]

            XCTAssertEqual(trail.coordinate2DList[index].latitude, latitude, "Both latitude must be same")
            XCTAssertEqual(trail.coordinate2DList[index].longitude, longitude, "Both longitude must be same")
        }
    }
    
    // MARK: travel time tests
    func testTravelTime_IsNotNil() {
        
        XCTAssertNotNil(trail.travelTime, "Travel time must be not nil")
    }
    
    func testTravelTime_IsCalculatedFromLength() {
        
        XCTAssertEqual(trail.travelTime, TrailUtils.metre2minute(lengthIn: trail.length), "Travel time must be same as calculated value")
    }
}
