//
//  SkinTempChartData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/7/23.
//

import Foundation

struct SkinTempChartData: Identifiable {
    let id = UUID()
    let timeStamp: Date
    let bodyTemperatureSkinInF: Double


    init(timeStamp: Date, bodyTemperatureSkinInF: Double) {
        self.timeStamp = timeStamp
        self.bodyTemperatureSkinInF = bodyTemperatureSkinInF
        //print("SkinTempChartData.timeStamp = \(self.timeStamp), \(bodyTemperatureSkinInF)")
    }
}

extension SkinTempChartData: Equatable {
  static func ==(lhs: SkinTempChartData, rhs: SkinTempChartData) -> Bool {
    return lhs.timeStamp == rhs.timeStamp && lhs.bodyTemperatureSkinInF == rhs.bodyTemperatureSkinInF
  }
}
