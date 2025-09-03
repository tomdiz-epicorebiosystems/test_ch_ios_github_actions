//
//  SweatWaterSampleChartData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/9/23.
//

import Foundation

struct SweatWaterSampleChartData: Identifiable, Equatable {
    let id = UUID()
    let timeStamp: Date
    let sweatVolumeDeficitInOz: Double
    let fluidTotalIntakeInOz: Double
    let sweatVolumeTotalLossInOz: Double

    init(timeStamp: Date, sweatVolumeDeficitInOz: Double, fluidTotalIntakeInOz: Double, sweatVolumeTotalLossInOz: Double) {
        self.timeStamp = timeStamp
        self.sweatVolumeDeficitInOz = sweatVolumeDeficitInOz == -0.0 ? 0 : sweatVolumeDeficitInOz
        self.fluidTotalIntakeInOz = fluidTotalIntakeInOz
        self.sweatVolumeTotalLossInOz = sweatVolumeTotalLossInOz
        //print("SweatWaterSampleChartData.timeStamp = \(self.timeStamp), \(self.sweatVolumeDeficitInOz), \(self.fluidTotalIntakeInOz), \(self.sweatVolumeTotalLossInOz)")
    }
}
