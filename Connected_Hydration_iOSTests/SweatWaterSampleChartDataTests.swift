//
//  SweatWaterSampleChartDataTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class SweatWaterSampleChartDataTests: XCTestCase {
    
    func testInit() {
        let timeStamp = Date()
        let sweatVolumeDeficitInOz = 10.0
        let fluidTotalIntakeInOz = 20.0
        let sweatVolumeTotalLossInOz = 30.0
        
        let chartData = SweatWaterSampleChartData(timeStamp: timeStamp, sweatVolumeDeficitInOz: sweatVolumeDeficitInOz, fluidTotalIntakeInOz: fluidTotalIntakeInOz, sweatVolumeTotalLossInOz: sweatVolumeTotalLossInOz)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatVolumeDeficitInOz, sweatVolumeDeficitInOz)
        XCTAssertEqual(chartData.fluidTotalIntakeInOz, fluidTotalIntakeInOz)
        XCTAssertEqual(chartData.sweatVolumeTotalLossInOz, sweatVolumeTotalLossInOz)
    }
    
    func testInit_withNegativeSweatVolumeDeficit() {
        let timeStamp = Date()
        let sweatVolumeDeficitInOz = -10.0
        let fluidTotalIntakeInOz = 20.0
        let sweatVolumeTotalLossInOz = 30.0
        
        let chartData = SweatWaterSampleChartData(timeStamp: timeStamp, sweatVolumeDeficitInOz: sweatVolumeDeficitInOz, fluidTotalIntakeInOz: fluidTotalIntakeInOz, sweatVolumeTotalLossInOz: sweatVolumeTotalLossInOz)
        
        XCTAssertEqual(chartData.timeStamp, timeStamp)
        XCTAssertEqual(chartData.sweatVolumeDeficitInOz, -10.0)
        XCTAssertEqual(chartData.fluidTotalIntakeInOz, fluidTotalIntakeInOz)
        XCTAssertEqual(chartData.sweatVolumeTotalLossInOz, sweatVolumeTotalLossInOz)
    }

    func testEquatable_withDifferentValues() {
        let timeStamp1 = Date()
        let timeStamp2 = Date().addingTimeInterval(60)
        
        let chartData1 = SweatWaterSampleChartData(timeStamp: timeStamp1, sweatVolumeDeficitInOz: 10.0, fluidTotalIntakeInOz: 20.0, sweatVolumeTotalLossInOz: 30.0)
        
        let chartData2 = SweatWaterSampleChartData(timeStamp: timeStamp2, sweatVolumeDeficitInOz: 10.0, fluidTotalIntakeInOz: 20.0, sweatVolumeTotalLossInOz: 30.0)
        
        XCTAssertNotEqual(chartData1, chartData2)
    }
    
    func testEquatable_withDifferentIds() {
        let timeStamp = Date()
        
        let chartData1 = SweatWaterSampleChartData(timeStamp: timeStamp, sweatVolumeDeficitInOz: 10.0, fluidTotalIntakeInOz: 20.0, sweatVolumeTotalLossInOz: 30.0)
        
        let chartData2 = SweatWaterSampleChartData(timeStamp: timeStamp, sweatVolumeDeficitInOz: 10.0, fluidTotalIntakeInOz: 20.0, sweatVolumeTotalLossInOz: 30.0)
        
        XCTAssertNotEqual(chartData1.id, chartData2.id)
    }
    
}
