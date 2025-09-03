//
//  SweatSodiumSampleChartDataTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class SweatSodiumSampleChartDataTests: XCTestCase {
    
    func testInit() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = 10.0
        let sodiumTotalIntakeInMg: UInt16 = 100
        let sweatSodiumTotalLossInMg: UInt16 = 50
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, sweatSodiumDeficitInMg)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
    
    func testInitWithZeroDeficit() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = -0.0
        let sodiumTotalIntakeInMg: UInt16 = 100
        let sweatSodiumTotalLossInMg: UInt16 = 50
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, 0)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
    
    func testInitWithNegativeDeficit() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = -10.0
        let sodiumTotalIntakeInMg: UInt16 = 100
        let sweatSodiumTotalLossInMg: UInt16 = 50
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, sweatSodiumDeficitInMg)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
    
    func testInitWithZeroIntake() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = 10.0
        let sodiumTotalIntakeInMg: UInt16 = 0
        let sweatSodiumTotalLossInMg: UInt16 = 50
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, sweatSodiumDeficitInMg)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
    
    func testInitWithZeroLoss() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = 10.0
        let sodiumTotalIntakeInMg: UInt16 = 100
        let sweatSodiumTotalLossInMg: UInt16 = 0
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, sweatSodiumDeficitInMg)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
    
    func testInitWithNegativeValues() {
        let timeStamp = Date()
        let sweatSodiumDeficitInMg = -10.0
        let sodiumTotalIntakeInMg: UInt16 = 100
        let sweatSodiumTotalLossInMg: UInt16 = 50
        
        let chartData = SweatSodiumSampleChartData(timeStamp: timeStamp, sweatSodiumDeficitInMg: sweatSodiumDeficitInMg, sodiumTotalIntakeInMg: sodiumTotalIntakeInMg, sweatSodiumTotalLossInMg: sweatSodiumTotalLossInMg)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatSodiumDeficitInMg, sweatSodiumDeficitInMg)
        XCTAssertEqual(chartData.sodiumTotalIntakeInMg, sodiumTotalIntakeInMg)
        XCTAssertEqual(chartData.sweatSodiumTotalLossInMg, sweatSodiumTotalLossInMg)
    }
}
