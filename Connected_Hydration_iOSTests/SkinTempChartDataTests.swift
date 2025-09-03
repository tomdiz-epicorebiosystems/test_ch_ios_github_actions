//
//  SkinTempChartDataTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class SkinTempChartDataTests: XCTestCase {
    
    func testInit() {
        let timeStamp = Date()
        let bodyTemperatureSkinInF = 98.6
        
        let skinTempChartData = SkinTempChartData(timeStamp: timeStamp, bodyTemperatureSkinInF: bodyTemperatureSkinInF)
        
        XCTAssertEqual(skinTempChartData.timeStamp, timeStamp)
        XCTAssertEqual(skinTempChartData.bodyTemperatureSkinInF, bodyTemperatureSkinInF)
    }
    
    func testId() {
        let skinTempChartData = SkinTempChartData(timeStamp: Date(), bodyTemperatureSkinInF: 98.6)
        
        XCTAssertNotNil(skinTempChartData.id)
    }
    
    func testTimeStamp() {
        let timeStamp = Date()
        
        let skinTempChartData = SkinTempChartData(timeStamp: timeStamp, bodyTemperatureSkinInF: 98.6)
        
        XCTAssertEqual(skinTempChartData.timeStamp, timeStamp)
    }
    
    func testBodyTemperatureSkinInF() {
        let bodyTemperatureSkinInF = 98.6
        
        let skinTempChartData = SkinTempChartData(timeStamp: Date(), bodyTemperatureSkinInF: bodyTemperatureSkinInF)
        
        XCTAssertEqual(skinTempChartData.bodyTemperatureSkinInF, bodyTemperatureSkinInF)
    }
    
    func testEquality() {
        let timeStamp1 = Date()
        let timeStamp2 = Date().addingTimeInterval(60)
        
        let skinTempChartData1 = SkinTempChartData(timeStamp: timeStamp1, bodyTemperatureSkinInF: 98.6)
        let skinTempChartData2 = SkinTempChartData(timeStamp: timeStamp1, bodyTemperatureSkinInF: 98.6)
        let skinTempChartData3 = SkinTempChartData(timeStamp: timeStamp2, bodyTemperatureSkinInF: 98.6)
        
        XCTAssertEqual(skinTempChartData1, skinTempChartData2)
        XCTAssertNotEqual(skinTempChartData1, skinTempChartData3)
    }
    
    func testPerformanceExample() {
        let timeStamp = Date()
        let bodyTemperatureSkinInF = 98.6
        
        measure {
            _ = SkinTempChartData(timeStamp: timeStamp, bodyTemperatureSkinInF: bodyTemperatureSkinInF)
        }
    }
}
