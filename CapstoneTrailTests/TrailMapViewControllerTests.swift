//
//  TrailMapViewControllerTests.swift
//  CapstoneTrail
//
//  Created by Joohyung Ryu on 2017. 3. 4..
//  Copyright (c) 2017 MSD. All rights reserved.
//

import XCTest
@testable import CapstoneTrail
import CoreLocation
import MapKit


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

    // Mark: User location tests
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


    func testMKMapViewDelegate_ShouldSetAfterViewDidLoad() {

        XCTAssertNotNil(testBed.trailMapView.delegate, "MKMapView.delegate must be instantiated")
    }


    func testCLAuthorizationStatus_IsAuthorized() {

        // Need to run the app and authorized the permission
        XCTAssertEqual(testBed.locationAuthStatus, CLAuthorizationStatus.authorizedWhenInUse)
    }


    func testShowUserLocation_SetAsTrueAfterViewDidLoad() {

        XCTAssertTrue(testBed.trailMapView.showsUserLocation, "CLLocationManager.showUserLocation must be set as true in viewDidLoad")
    }

    // MARK: Zoom map test
    func testCurrentLocationCoordinate_IsNotNil() {

        XCTAssertNotNil(testBed.currentCoordinate, "Current location coordinate must not be nil")
    }


    func testUserLocationCoordinate_IsNotZero() {

        XCTAssertNotEqual(testBed.currentCoordinate, CLLocationCoordinate2D(), "Current Coordinate must have unique value, not (0.0, 0.0)")
    }


    func testCoordinateSpan_IsNotNil() {

        XCTAssertNotNil(testBed.coordinateSpan, "MKCoordinateSpan must not be nil")
    }


    func testCoordinateSpan_IsNotZero() {

        XCTAssertNotEqual(testBed.coordinateSpan, MKCoordinateSpan(), "Current MKCoordinateSpan must have unique value, not (0.0, 0.0)")
    }


    func testCoordinateRegion_IsNotNil() {

        XCTAssertNotNil(testBed.coordinateRegion, "MKCoordinateRegion must not be nil")
    }
}


extension CLLocationCoordinate2D: Equatable {
    // Need for 'testUserLocationCoordinate_IsNotZero'
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {

        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.latitude)
    }
}


extension MKCoordinateSpan: Equatable {
    // Need for 'testCoordinateSpan_IsNotZero'
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {

        return (lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta)
    }
}
