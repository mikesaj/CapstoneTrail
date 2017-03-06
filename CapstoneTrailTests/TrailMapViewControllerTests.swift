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

        XCTAssertNotNil(testBed.view, "Instantiated view must not be nil")
        XCTAssertNotNil(testBed.viewWillAppear(false), "ViewWillAppear must be executable")
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

    // MARK: Zoom map tests
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

    // Mark: Trail data from Core Data tests
    func testTrailList_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.coreDataTrailList, "Trail data list must not be nil")
    }


    func testTrailList_HasItem() {

        XCTAssertTrue(testBed.coreDataTrailList.count > 0)
    }


    func testAppDelegate_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.appDelegate, "AppDelegate objectmust not be nil")
    }


    func testManagedContext_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.managedContext, "NSManagedObjectContext object must not be nil")
    }


    func testFetchRequest_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.fetchRequest, "NSFetchRequest object must not be nil")
    }


    func testFetchRequest_ShouldSetEntityName() {

        XCTAssertEqual(testBed.fetchRequest.entityName, "Trail", "NSFetchRequest object must set entity name as 'Trail'")
    }


    func testCoreDataTrailList_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.coreDataTrailList, "The array must not be nil")
        XCTAssertNotEqual(testBed.coreDataTrailList.count, 0, "The array must have more than 1 data")
    }

    // MARK: Trail routes on the map tests
    func testTrailsArray_IsNotNilAfterViewWillAppear() {

        XCTAssertNotNil(testBed.trails, "Trail object list must not be nil")
    }


    func testTrailsArray_IsNotEmptyAfterViewWillAppear() {

        XCTAssertNotEqual(testBed.trails.count, 0, "Trail object list must have more than 1 Trail object")
    }


    func testTrail_HasSameValuesAsCoreData() {

        let randNumber: UInt32 = arc4random_uniform(UInt32(testBed.coreDataTrailList.count))
        let index: Int = Int(randNumber)

        XCTAssertEqual(testBed.trails[index].id, testBed.coreDataTrailList[index].value(forKey: "id") as! Int, "ID values must be identical")
    }


    func testMapViewOverlays_IsNotZero() {

        XCTAssertNotEqual(testBed.trailMapView.overlays.count, 0, "The map view must have more than 1 overlays")
    }
}


extension CLLocationCoordinate2D: Equatable {
    // Need for 'testUserLocationCoordinate_IsNotZero', 'testPolyline_IsNoEmptyValues'
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {

        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
}


extension MKCoordinateSpan: Equatable {
    // Need for 'testCoordinateSpan_IsNotZero'
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {

        return (lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta)
    }
}
