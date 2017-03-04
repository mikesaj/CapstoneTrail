//
//  TrailMapViewControllerTests.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 4..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import XCTest
@testable import CapstoneTrail


class TrailMapViewControllerTests: XCTestCase {

    // MARK: Variables
    var testBed: TrailMapViewController!

    override func setUp() {

        super.setUp()

        let storyboard = UIStoryboard(name: "TrailMap", bundle: nil)
        testBed = storyboard.instantiateViewController(withIdentifier: "TrailMap") as! TrailMapViewController
        _ = testBed.view
    }


    override func tearDown() {

        super.tearDown()
    }

    // MARK: MapView tests
    func testMapView_IsNotNil() {

        XCTAssertNotNil(testBed.trailMapView, "MKMapView must be instantiated")
    }

    // Mark: User location
    func testLocationManager_IsNotNilAfterViewDidLoad() {

        XCTAssertNotNil(testBed.locationManager, "CLLocationManager must be instantiated in viewDidLoad")
    }


    func testCLAuthorizationStatus_IsNotNil() {

        XCTAssertNotNil(testBed.locationAuthStatus, "CLAuthorizationStatus must be instantiated")
    }
    
    func testInfoPlist_HasLocationAuthPrivacyProperty() {
        
        guard let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist") else { return }
        let infoPlist = NSDictionary(contentsOfFile: infoPlistPath)
        let hasProperty = (infoPlist?["NSLocationWhenInUseUsageDescription"] != nil)
        
        XCTAssertTrue(hasProperty, "Must have NSLocationWhenInUse property")
    }
}
