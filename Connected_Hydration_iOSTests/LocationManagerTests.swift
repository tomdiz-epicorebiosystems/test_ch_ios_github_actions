//
//  LocationManagerTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
import CoreLocation
@testable import Connected_Hydration_iOS

class LocationManagerTests: XCTestCase {
    
    var locationManager: LocationManager!
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
    }
    
    override func tearDown() {
        locationManager = nil
        super.tearDown()
    }
    
    func testLocationManagerInitialization() {
        XCTAssertNotNil(locationManager)
    }
    
    func testLocationStatusNotDetermined() {
        XCTAssertEqual(locationManager.locationStatus, nil)
    }
    
    func testLastLocationNil() {
        XCTAssertNil(locationManager.lastLocation)
    }
    
    func testStatusStringUnknown() {
        XCTAssertEqual(locationManager.statusString, "unknown")
    }
    
    func testDidUpdateLocations() {
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        locationManager.locationManager(CLLocationManager(), didUpdateLocations: [location])
        
        XCTAssertEqual(locationManager.lastLocation, location)
    }
    
    func testDidFailWithError() {
        let error = NSError(domain: "TestError", code: 0, userInfo: nil)
        locationManager.locationManager(CLLocationManager(), didFailWithError: error)
        
        // Add assertions to handle the failure to get a user's location
    }
}
