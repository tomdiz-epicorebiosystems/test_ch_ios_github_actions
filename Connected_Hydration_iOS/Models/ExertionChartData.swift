//
//  ExertionChartData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/9/23.
//

import Foundation

struct ExertionChartData: Identifiable {
    let id = UUID()
    let timeStamp: Date
    let activityCounts: UInt8


    init(timeStamp: Date, activityCounts: UInt8) {
        self.timeStamp = timeStamp
        self.activityCounts = activityCounts
    }
}

extension ExertionChartData: Equatable {
  static func ==(lhs: ExertionChartData, rhs: ExertionChartData) -> Bool {
    return lhs.timeStamp == rhs.timeStamp && lhs.activityCounts == rhs.activityCounts
  }
}
