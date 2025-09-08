//
//  Globals.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/16/23.
//

import Foundation
import UIKit
import SwiftUI
import BLEManager
import CoreBluetooth

// Base colors for sodium and water
struct chHydrationColors {
    static let waterFull: String = "#2A9AD6"
    static let waterHalf: String = "#348DCB"
    static let waterQuarter: String = "#417CBD"

    static let sodiumQuarter: String = "#5169AC"
    static let sodiumHalf: String = "#5E589D"
    static let sodiumFull: String = "#684B92"
}

struct generalCHAppColors {
    static let grayStandardText: String = "#49494C"
    static let lightGrayStandardBackground: String = "#EEEEEF"
    static let mediumGrayStandardBackground: String = "#E0E1E2"
    
    static let regularGrayStandardBackground: String = "#BBBDC0"
    
    static let connexSelectionColor: String = "#009EDF"
    static let connexLightGrayBackground: String = "#ECEEFF0"
    
    static let onboardingLightBackground: String = "#344752"
    static let onboardingDarkBackground: String = "#27363E"
    static let onboardingLtGrayColor: String = "#858789"
    static let onboardingLtBlueColor: String = "#249AD6"
    static let onboardingVeryDarkBackground: String = "#2a353f"

    static let insightMediumColor: String = "#3A4652"
    static let insightLightColor: String = "#6D6E70"
    static let insightLtGrayColor: String = "#e9eaee"

    static let intakeFractionalStandardText: String = "#404041"
    static let intakeBottleIconStandardText: String = "#3C698C"
    
    static let linkStandardText: String = "#0092CF"
    
    static let settingsColorCoalText: String = "#4A4A4D"
    static let settingsColorHydroDarkText: String = "#476889"
    static let settingsSliderOnColor: String = "#2A9AD6"
    static let settingsHeaderBackgroundColor: String = "#ADAEB0"
    static let skinTemp: String = "#6E8A9F"
    static let exertionTemp: String = "#66BED1"
    
    static let intakeChartRectMark: String = "#EBF5FC"
    static let intakeChartHydratedtext: String = "#ACC8E0"
    static let intakeChartHydratedLineColor: String = "#3B6C93"
    static let intakeChartMidPointLineColor: String = "#D9BB44"
    static let intakeChartDehydratedLineColor: String = "#B22124"
    static let intakeChartLollipopColor: String = "#476788"
    
    static let suggestedIntakeExpandedWaterBackground: String = "#E5F5FB"
    static let suggestedIntakeExpandedSodiumBackground: String = "#F0ECF4"
    static let suggestedIntakeDisclaimerRed: String = "#A4302B"
    static let suggestedIntakeButtonBackground: String = "#4A4A4D"
}

struct chYourSweatProfileColors {
    static let waterLow: String = "#bfe7f6"
    static let waterMedium: String = "#66c4ea"
    static let waterHigh: String = "#00a0e2"

    static let sodiumLow: String = "#dbd1e5"
    static let sodiumMedium: String = "#a792c1"
    static let sodiumHigh: String = "#73479c"
}


// Settings font sizes
let settingsTitleFontSize = 20.0
let settingsHeaderTextFontSize = 14.0
let settingsInfoTextFontSize = 14.0
let settingsSectionGrayHeight = 35.0
let settingsSensorTextFontSize = 16.0


// This is  used to know the Intake Tab Image update state
public enum IntakeTabState {
    case intakeNormal
    case intakeCancel
    case intakeAdd
    case intakeClose
    case intakeSave
    case intakeUpdate
}

// Current state of Intake Tab Image to use
public var intakeTabGlobalState = IntakeTabState.intakeNormal
public var tabBarItems: [UITabBarItem]?
public var tabBarView: UIView?

func updateIntakeTabState() {
    let items = tabBarItems
    if items == nil {
        return
    }
    for item in items!
    {
        if (item.title ?? "").isEmpty {
            //print("intakeTabGlobalState == \(intakeTabGlobalState)")
            switch intakeTabGlobalState {
            case .intakeNormal:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Normal")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Normal")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Normal")
                }
            case .intakeCancel:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Cancel")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Cancel")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Cancel")
                }
            case .intakeAdd:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Add")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Add")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Add")
                }
            case .intakeClose:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Close")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Close")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Close")
                }
            case .intakeSave:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Save Anim 0")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Save Anim 0")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Save Anim 0")
                }
            case .intakeUpdate:
                if #available(iOS 17.0, *) {
                    item.image = UIImage(named: "Intake Tab Update")!.withRenderingMode(.alwaysOriginal)
                    item.selectedImage = UIImage(named: "Intake Tab Update")!.withRenderingMode(.alwaysOriginal)
                }
                else {
                    item.image = UIImage(named: "Intake Tab Update")
                }
            }
        }
    }
}

func getCurrentDeviceNetworkImage(data: ModelData) -> Image {

    if let device = BLEManager.bleSingleton.centralManager {
        if device.state == .poweredOff {
            if data.isNetworkConnected == true {
                return Image("Connex - device alert")
            }
            else {  // both false
                return Image("Connex - device gray")
            }
        }
    }

    if data.csvFileIsUploading == true {
        return Image("Connex - device syncing")
    }
    else if data.isNetworkConnected == true && BLEManager.bleSingleton.sensorConnected == true {
        return Image("Connex - device check")
    }
    else if data.isNetworkConnected == true && BLEManager.bleSingleton.sensorConnected == false {
        return Image("Connex - device alert")
    }
    else if data.isNetworkConnected == false && BLEManager.bleSingleton.sensorConnected == true {
        return Image("Connex - network alert")
    }
    else {  // both false
        return Image("Connex - device gray")
    }
}

func getChartDateTime(seconds: UInt16) -> Date {
    let date = Date(timeIntervalSince1970: Double(BLEManager.bleSingleton.currentRecordingStartEpichTime))
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let calendar = Calendar.current
    let newChartDate = calendar.date(byAdding: .second, value: Int(seconds), to: date)!
    return newChartDate
}

func getChartSessionSessionStart() -> String {
    let date = Date(timeIntervalSince1970: Double(BLEManager.bleSingleton.currentRecordingStartEpichTime))
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.amSymbol = "am"
    dateFormatter.pmSymbol = "pm"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func getChartSessionStartHour() -> Int {
    let date = Date(timeIntervalSince1970: Double(BLEManager.bleSingleton.currentRecordingStartEpichTime))
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.amSymbol = "am"
    dateFormatter.pmSymbol = "pm"
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    return hour
}

func getChartCurrentSessionHour(seconds: UInt16) -> Int {
    let date = Date(timeIntervalSince1970: Double(BLEManager.bleSingleton.currentRecordingStartEpichTime))
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.amSymbol = "am"
    dateFormatter.pmSymbol = "pm"
    let calendar = Calendar.current
    let newChartDate = calendar.date(byAdding: .second, value: Int(seconds), to: date)!
    let hour = calendar.component(.hour, from: newChartDate)
    return hour
}

func getChartCurrentSessionMins(seconds: UInt16) -> Int {
    let date = Date(timeIntervalSince1970: Double(BLEManager.bleSingleton.currentRecordingStartEpichTime))
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.amSymbol = "am"
    dateFormatter.pmSymbol = "pm"
    let calendar = Calendar.current
    let newChartDate = calendar.date(byAdding: .second, value: Int(seconds), to: date)!
    let mins = calendar.component(.minute, from: newChartDate)
    return mins
}

var isBluetoothPermissionGranted: Bool {
    return CBCentralManager.authorization == .allowedAlways
}

var isBluetoothPoweredOn: Bool {
    let bluetoothManager = CBCentralManager()
    switch bluetoothManager.state {
    case .poweredOn:
        return true
    case .poweredOff:
        break
    case .resetting:
        break
    case .unauthorized:
        break
    case .unsupported:
        break
    case .unknown:
        break
    default:
        break
    }
    
    return false
}

func generateCurrentTimeStamp () -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss"
    return (formatter.string(from: Date()) as NSString) as String
}

func isCHArmBand(_ version: String) -> Bool {
    // Extract the major version prefix, e.g., "v3" from "v3.233"
    guard let majorVersion = version.split(separator: ".").first else {
        return false
    }
    
    // Return true for v3, v4, v5; false for v6, v7
    switch majorVersion {
    case "v3", "v4", "v5":
        return false
    case "v6", "v7":
        return true
    default:
        return false
    }
}
