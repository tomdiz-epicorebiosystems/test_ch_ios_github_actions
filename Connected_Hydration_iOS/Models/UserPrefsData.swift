//
//  UserPrefsData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 9/12/23.
//

import Foundation
import SwiftUI

final class UserPrefsData: NSObject, ObservableObject {
        
    @AppStorage("useUnits") var useUnits = "X"            // 0 is metric, 1 = imperial
    @AppStorage("userWeightLb") var userWeightLb = "165"
    @AppStorage("userWeightKg") var userWeightKg = "75"
    @AppStorage("heightFt") var heightFt = "5"
    @AppStorage("heightIn") var heightIn = "9"
    @AppStorage("heightCm") var heightCm = "175"
    @AppStorage("gender") var gender = "M"
    @AppStorage("buttonPressWaterIntakeMl") var buttonPressWaterIntakeMl = 500

    func setUserUnits() {
        if useUnits == "X" {
            let isMetric = Locale.current.measurementSystem == .metric
            if (isMetric) {
                useUnits = "0"
            }
            else {
                useUnits = "1"
            }
        }
    }
    
    func getUserWeightString() -> String {
        //print("useUnits == \(useUnits)")
        if useUnits == "0" {
            return "kg"
        }
        else {
            return "lb."
        }
    }
    
//    func getUserHeightFtValueString() -> String {
//        if heightFt == "0" {
//            return "4"
//        }
//        else if heightFt == "1" {
//            return "5"
//        }
//        else {
//            return "6"
//        }
//    }
    
    func getUserHeightFtIndex() -> Int {
        if heightFt == "4" {
            return 0
        }
        else if heightFt == "5" {
            return 1
        }
        else {
            return 2
        }
    }
    
    func getUserHeightInchesIndex() -> Int {
        return Int(heightIn) ?? 2
    }
    
    func getUserHeightMajorUnitString() -> String {
        if useUnits == "0" {
            return "cm"
        }
        else {
            return "ft."
        }
    }
    
    func getUserHeightMinorUnitString() -> String {
        if useUnits == "0" {
            return "cm"
        }
        else {
            return "in."
        }
    }
    
    func getUserSweatUnitString() -> String {
        if useUnits == "0" {
            return "ml"
        }
        else {
            return "oz"
        }
    }
    
    func getUserSweatUnitFullString() -> String {
        if useUnits == "0" {
            return "MILLILITERS"
        }
        else {
            return "OUNCES"
        }
    }
    
    func getUserSweatUnitTodayButtonString() -> String {
        if useUnits == "0" {
            return "MILLILITERS"
        }
        else {
            return "OUNCES"
        }
    }
    
    func getUserSodiumUnitFullString() -> String {
        return "MILLIGRAMS"
    }
    
    func getUserSodiumUnitTodayButtonString() -> String {
        return "MILLIGRAMS"
    }
    
    func getUserSodiumUnitString() -> String {
        if useUnits == "0" {
            return "mg"
        }
        else {
            return "mg"
        }
    }
    
    func handleUserSweatConversion(oz: Double) -> Double {
        if useUnits == "0" {
            return round(oz * 29.574)
        }
        else {
            return oz
        }
    }
    
    func handleUserSweatConversion(ml: Double) -> Double {
        if useUnits == "0" {
            return ml
        }
        else {
            return round((ml / 29.574) * 10) / 10
        }
    }
    
    func handleUserSodiumConversion(mg: Int16) -> Double {
        if useUnits == "0" {
            return Double(mg)
        }
        else {
            return Double(mg)
        }
    }
    
    func handleUserSodiumConversion(mg: UInt16) -> Double {
        if useUnits == "0" {
            return Double(mg)
        }
        else {
            return Double(mg)
        }
    }
    
    func handleUserSodiumConversion(mg: Double) -> Double {
        if useUnits == "0" {
            return Double(mg)
        }
        else {
            return Double(mg)
        }
    }

    func getUserHeightIn() -> String {
        return heightIn
    }

    func getUserWeight() -> String {
        if useUnits == "0" {
            return userWeightKg
        }
        else {
            return userWeightLb
        }
    }

    func getUserWeightKg() -> String {
        return userWeightKg
    }

    func getUserWeightLb() -> String {
        return userWeightLb
    }

    func getUserHeightInFt() -> String {
        return heightFt
    }

    func getUserHeightCm() -> String {
        return heightCm
    }
    
    func getUserTempUnitString() -> String {
        if useUnits == "0" {
            return "\u{00B0}C"
        }
        else {
            return "\u{00B0}F"
        }
    }
    
    func getUserTemperature(fahrenheit: Double) -> Double {
        if useUnits == "0" {
            return max((fahrenheit - 32) / 1.8000, 0.0)
        }
        else {
            return fahrenheit
        }
    }
    
    func getUserTemperature(celsius: Double) -> Double {
        if useUnits == "0" {
            return celsius
        }
        else {
            return (celsius  * (9/5)) + 32
        }
    }
    
    func getUserTemperatureInF(celsius: Double) -> Double {
        return (celsius  * (9/5)) + 32
    }
    
    func getUserExceedWarningString() -> String {
        logger.info("User exceeded 48oz of intake")
        if useUnits == "0" {
            return String(localized:"Don’t exceed 1500ml (1.5L) per hour\nof water intake.")
        }
        else {
            return String(localized:"Don’t exceed 48oz (1.5L) per hour\nof water intake.")
        }
    }
    
    func getTotalWaterIntake(amount: Double) -> Double {
        return handleUserSweatConversion(ml: amount)
    }
    
    func getTotalSodiumIntake(amount: Double) -> Double {
        return amount
    }

    func getFuildDeficitString() -> String {
        if useUnits == "0" {
            return "10000+"
        }
        else {
            return "338+"
        }
    }

    func getFuildDeficitAlertString() -> String {
        if useUnits == "0" {
            return String(localized:"Please don’t exceed 1500ml (1.5L) per hour of water intake.")
        }
        else {
                return String(localized:"Please don’t exceed 48oz (1.5L) per hour of water intake.")
        }
    }

    func setUserWeight(weight: String) {
        if useUnits == "0" {
            userWeightKg = weight
            let metriclb = (Double(weight) ?? 23.0) * 2.205
            userWeightLb = String(format: "%.0f", round(metriclb))
        }
        else {
            userWeightLb = weight
            let metricKg = (Double(weight) ?? 50.0) / 2.2
            userWeightKg = String(format: "%.0f", round(metricKg))
        }
    }

    // always metric from server
    func setUserWeightNetwork(weight: String) {
        userWeightKg = weight
        let metriclb = (Double(weight) ?? 23.0) * 2.205
        userWeightLb = String(format: "%.0f", round(metriclb))
    }

    func getUserWeightNetwork() -> String {
        return userWeightKg
    }

    func setUserWeightFromSensor(weightInKg: UInt16) {
        userWeightKg = "\(weightInKg)"
        let metriclb = Double(weightInKg) * 2.205
        userWeightLb = String(format: "%.0f", round(metriclb))
    }
    
    func setUserWeight(weight: String, units: Int) -> String {
        if units == 1 {
            
            var metriclb : Double
            if((Int(weight) ?? 23) < 23) {
                metriclb = 23.0 * 2.205
            }
            
            else {
                metriclb = (Double(weight) ?? 23.0) * 2.205
            }
            
            userWeightLb = String(format: "%.0f", round(metriclb))
            return userWeightLb
        }
        else {
            
            var metricKg : Double
            
            if((Int(weight) ?? 50) < 50) {
                metricKg = 50.0 / 2.2
            }
            
            else {
                metricKg = (Double(weight) ?? 50.0) / 2.2
            }
            userWeightKg = String(format: "%.0f", round(metricKg))
            return userWeightKg
        }
    }

    func setUserHeightFeet(feet: String) {
        heightFt = feet
        
        if(heightIn == "12") {
            heightIn = "0"
            heightFt = "\((UInt8(feet) ?? 4) + 1)"
        }
        
    }

    func setUserHeightInch(inches: String) {
        heightIn = inches
    }

    func setUserHeightCm(cm: UInt8) {
        heightCm = String(cm)
    }

    func setUserGender(gender: String) {
        self.gender = gender
    }

    func getUserGender() -> String {
        return gender
    }

    func resetUserPrefs() {
        useUnits = "1"
        userWeightLb = "165"
        userWeightKg = "75"
        heightFt = "5"
        heightIn = "9"
        heightCm = "175"
        gender = "M"
    }

}
