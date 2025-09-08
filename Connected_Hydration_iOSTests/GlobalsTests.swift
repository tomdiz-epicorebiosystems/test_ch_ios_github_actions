//
//  GlobalsTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class GlobalsTests: XCTestCase {
    
    func testHydrationColors() {
        XCTAssertEqual(chHydrationColors.waterFull, "#2A9AD6")
        XCTAssertEqual(chHydrationColors.waterHalf, "#348DCB")
        XCTAssertEqual(chHydrationColors.waterQuarter, "#417CBD")
        XCTAssertEqual(chHydrationColors.sodiumQuarter, "#5169AC")
        XCTAssertEqual(chHydrationColors.sodiumHalf, "#5E589D")
        XCTAssertEqual(chHydrationColors.sodiumFull, "#684B92")
    }
    
    func testGeneralCHAppColors() {
        XCTAssertEqual(generalCHAppColors.grayStandardText, "#49494C")
        XCTAssertEqual(generalCHAppColors.lightGrayStandardBackground, "#EEEEEF")
        XCTAssertEqual(generalCHAppColors.mediumGrayStandardBackground, "#E0E1E2")
        XCTAssertEqual(generalCHAppColors.regularGrayStandardBackground, "#BBBDC0")
        XCTAssertEqual(generalCHAppColors.connexSelectionColor, "#009EDF")
        XCTAssertEqual(generalCHAppColors.connexLightGrayBackground, "#ECEEFF0")
        XCTAssertEqual(generalCHAppColors.onboardingLightBackground, "#344752")
        XCTAssertEqual(generalCHAppColors.onboardingDarkBackground, "#27363E")
        XCTAssertEqual(generalCHAppColors.onboardingLtGrayColor, "#858789")
        XCTAssertEqual(generalCHAppColors.onboardingLtBlueColor, "#249AD6")
        XCTAssertEqual(generalCHAppColors.insightMediumColor, "#3A4652")
        XCTAssertEqual(generalCHAppColors.insightLightColor, "#6D6E70")
        XCTAssertEqual(generalCHAppColors.intakeFractionalStandardText, "#404041")
        XCTAssertEqual(generalCHAppColors.intakeBottleIconStandardText, "#3C698C")
        XCTAssertEqual(generalCHAppColors.linkStandardText, "#0092CF")
        XCTAssertEqual(generalCHAppColors.settingsColorCoalText, "#4A4A4D")
        XCTAssertEqual(generalCHAppColors.settingsColorHydroDarkText, "#476889")
        XCTAssertEqual(generalCHAppColors.settingsSliderOnColor, "#2A9AD6")
        XCTAssertEqual(generalCHAppColors.settingsHeaderBackgroundColor, "#ADAEB0")
        XCTAssertEqual(generalCHAppColors.skinTemp, "#6E8A9F")
        XCTAssertEqual(generalCHAppColors.exertionTemp, "#66BED1")
        XCTAssertEqual(generalCHAppColors.intakeChartRectMark, "#EBF5FC")
        XCTAssertEqual(generalCHAppColors.intakeChartHydratedtext, "#ACC8E0")
        XCTAssertEqual(generalCHAppColors.intakeChartHydratedLineColor, "#3B6C93")
        XCTAssertEqual(generalCHAppColors.intakeChartMidPointLineColor, "#D9BB44")
        XCTAssertEqual(generalCHAppColors.intakeChartDehydratedLineColor, "#B22124")
        XCTAssertEqual(generalCHAppColors.intakeChartLollipopColor, "#476788")
    }
    
    func testGetChartDateTime() {
        let date = Date(timeIntervalSince1970: 0.0)
        let testTime = getChartDateTime(seconds: 50000)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let calendar = Calendar.current
        let newChartDate = calendar.date(byAdding: .second, value: Int(50000), to: date)!
        
        XCTAssertEqual(testTime, newChartDate)
    }
/*
    func testGetChartSessionSessionStart() {
        let testTime = getChartSessionSessionStart()
        XCTAssertEqual(testTime, "7:00 pm")
    }

    func testGetChartSessionStartHour() {
        let testSessionHour = getChartSessionStartHour()
        XCTAssertEqual(testSessionHour, 19)
    }

    func testGetChartCurrentSessionHour() {
        let testSessionHour = getChartCurrentSessionHour(seconds: 50000)
        XCTAssertEqual(testSessionHour, 8)
    }
*/
    func testGetChartCurrentSessionMins() {
        let testSessionMins = getChartCurrentSessionMins(seconds: 50000)
        XCTAssertEqual(testSessionMins, 53)
    }
}
