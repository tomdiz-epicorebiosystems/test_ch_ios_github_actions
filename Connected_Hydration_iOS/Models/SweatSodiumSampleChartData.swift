//
//  SweatSodiumSampleChartData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/14/23.
//

import Foundation

struct SweatSodiumSampleChartData: Identifiable {
    let id = UUID()
    let timeStamp: Date
    let sweatSodiumDeficitInMg: Double
    let sodiumTotalIntakeInMg: UInt16
    let sweatSodiumTotalLossInMg: UInt16

    init(timeStamp: Date, sweatSodiumDeficitInMg: Double, sodiumTotalIntakeInMg: UInt16, sweatSodiumTotalLossInMg: UInt16) {
        self.timeStamp = timeStamp
        self.sweatSodiumDeficitInMg = sweatSodiumDeficitInMg == -0.0 ? 0 : sweatSodiumDeficitInMg
        self.sodiumTotalIntakeInMg = sodiumTotalIntakeInMg
        self.sweatSodiumTotalLossInMg = sweatSodiumTotalLossInMg
    }
}
