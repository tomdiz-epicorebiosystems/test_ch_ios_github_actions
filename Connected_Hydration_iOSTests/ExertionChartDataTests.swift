//
//  ExertionChartDataTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class ExertionChartDataTests: XCTestCase {
    
    func testInit() {
        let timeStamp = Date()
        let activityCounts: UInt8 = 5
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: activityCounts)
        
        XCTAssertEqual(exertionChartData.timeStamp, timeStamp)
        XCTAssertEqual(exertionChartData.activityCounts, activityCounts)
    }
    
    func testId() {
        let timeStamp = Date()
        let activityCounts: UInt8 = 5
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: activityCounts)
        
        XCTAssertNotNil(exertionChartData.id)
    }
    
    func testTimeStamp() {
        let timeStamp = Date()
        let activityCounts: UInt8 = 5
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: activityCounts)
        
        XCTAssertEqual(exertionChartData.timeStamp, timeStamp)
    }
    
    func testActivityCounts() {
        let timeStamp = Date()
        let activityCounts: UInt8 = 5
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: activityCounts)
        
        XCTAssertEqual(exertionChartData.activityCounts, activityCounts)
    }
    
    func testInitWithZeroActivityCount() {
        let timeStamp = Date()
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: 0)
        
        XCTAssertEqual(exertionChartData.activityCounts, 0)
    }
    
    func testInitWithMaxActivityCount() {
        let timeStamp = Date()
        
        let exertionChartData = ExertionChartData(timeStamp: timeStamp, activityCounts: UInt8.max)
        
        XCTAssertEqual(exertionChartData.activityCounts, UInt8.max)
    }
    
    func testEquality() {
        let timeStamp1 = Date()
        let timeStamp2 = Date().addingTimeInterval(60)
        
        let exertionChartData1 = ExertionChartData(timeStamp: timeStamp1, activityCounts: 100)
        let exertionChartData2 = ExertionChartData(timeStamp: timeStamp1, activityCounts: 100)
        let exertionChartData3 = ExertionChartData(timeStamp: timeStamp2, activityCounts: 20)
        
        XCTAssertEqual(exertionChartData1, exertionChartData2)
        XCTAssertNotEqual(exertionChartData1, exertionChartData3)
    }

}
