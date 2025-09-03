//
//  WorkDaySummaryView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/27/23.
//

import SwiftUI
import BLEManager
import Charts

enum SummaryChartColors {
    static let inactiveGrayHex = "#B7B7B7"
    static let lightGreenHex = "#466888"
    static let moderateYellowHex = "#D5BB59"
    static let highRedHex = "#A4302B"
}

struct Entry: Identifiable {
    let id = UUID()
    let label: String
    let percentage: Int
}

struct ActivityData {

    struct Series: Identifiable {
        let label: String

        let percentage: Double

        var id: String { label }
    }

    static let minMaxActivityCounts: [(Float, Float)] = [
        (0.0, 16.9),
        (17.0, 29.9),
        (30.0, 34.9),
        (35.0, 45.0)
    ]
}

struct WorkDaySummaryView: View {

    @EnvironmentObject var modelData: ModelData

    @Binding var skinTempData: [Entry]
    @Binding var activityData: [Entry]
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        VStack (spacing: 0) {
            Text("SUMMARY")
                .font(.custom("Oswald-Regular", size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))

            HStack {
                VStack {
                    Text("DURATION (HR:MIN)")
                        .font(.custom("Oswald-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        
                        if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                            Text(generateTimeStringFromTimeStamp(timeStampInSeconds: BLEManager.bleSingleton.currentRecordingDuration))
                                .font(.custom("TenbyEight", size: 36))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        }
                        else {
                            Text("00:00")
                                .font(.custom("TenbyEight", size: 36))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        }
                    }
                }
                .padding(.trailing, 20)
                
                if(BLEManager.bleSingleton.firmwareRevString > "v3.233") {
                    
                    VStack {
                        Text("ALARMS")
                            .font(.custom("Oswald-Regular", size: 16))
                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        
                        HStack {
                            Image(systemName: "bell.and.waves.left.and.right.fill")
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                Text("\(modelData.alarmCount)")
                                    .font(.custom("TenbyEight", size: 36))
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            }
                            else {
                                Text("0")
                                    .font(.custom("TenbyEight", size: 36))
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            }
                        }
                    }
                    .padding(.leading, 20)
                }

            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)

            VStack {

                VStack {    // Activity bar chart
                    HStack {
                        Text("ACTIVITY LEVEL")
                            .font(.custom("Oswald-Regular", size: 16))
                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        
                        Image("indicator_activity")
                    }
                    
                    if !activityData.isEmpty {
                        ActivityChart

                        HStack(spacing: 5) {

                            Text("\(activityData[0].label) \(activityData[0].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.inactiveGrayHex))

                            Text("\(activityData[1].label) \(activityData[1].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.lightGreenHex))
                                .padding(.leading, 5)
                                .padding(.trailing, 5)

                            Text("\(activityData[2].label) \(activityData[2].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.moderateYellowHex))
                                .padding(.leading, 5)
                                .padding(.trailing, 5)

                            Text("\(activityData[3].label) \(activityData[3].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.highRedHex))

                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else {
                        EmptySummaryBarChart
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

                VStack {    // Skin Temp bar chart
                    HStack {
                        Text(String(localized:"SKIN TEMP ") + "(" + modelData.userPrefsData.getUserTempUnitString() + ")")
                            .font(.custom("Oswald-Regular", size: 16))
                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                        
                        Image("indicator_temperature")
                    }
                    
                    if !skinTempData.isEmpty {
                        SkinTempChart

                        HStack(spacing: 5) {
                            Text("\(skinTempData[0].label) \(skinTempData[0].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.lightGreenHex))

                            Text("\(skinTempData[1].label) \(skinTempData[1].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: "#FFC103"))
                                .padding(.leading, 5)
                                .padding(.trailing, 5)

                            Text("\(skinTempData[2].label) \(skinTempData[2].percentage)%")
                                .font(.custom("Oswald-Light", size: 14))
                                .foregroundColor(Color(hex: SummaryChartColors.highRedHex))

                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else {
                        EmptySummaryBarChart
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

            }   // VStack
            .padding(.bottom, 10)

            Spacer()

        }
        .trackRUMView(name: "WorkDaySummaryView")
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 320)
        .background(Color(.white))
        .cornerRadius(10)
        .padding(.top, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }

    private var EmptySummaryBarChart: some View {
        Chart() {
            Plot {
                BarMark(
                    x: .value("Activity Size", 100)
                )
                .foregroundStyle(.gray)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color(.systemFill))
                .cornerRadius(8)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...100)
        .chartYScale(range: .plotDimension(endPadding: -8))
        .chartLegend(position: .bottom, spacing: 8)
        .chartLegend(.hidden)
        .frame(height: 20)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
    
    private var ActivityChart: some View {
        Chart(activityData, id: \.label) { element in
            Plot {
                BarMark(
                    x: .value("Activity Size", element.percentage)
                )
                .foregroundStyle(element.label == String(localized:"Very Low") ? Color(hex: SummaryChartColors.inactiveGrayHex) : element.label == String(localized:"Light") ? Color(hex: SummaryChartColors.lightGreenHex) : element.label == String(localized:"Moderate") ? Color(hex: SummaryChartColors.moderateYellowHex) : Color(hex: SummaryChartColors.highRedHex))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color(.systemFill))
                .cornerRadius(8)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...100)
        .chartYScale(range: .plotDimension(endPadding: -8))
        .chartLegend(position: .bottom, spacing: 8)
        .chartLegend(.visible)
        .frame(height: 20)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }

    private var SkinTempChart: some View {
        Chart(skinTempData, id: \.label) { element in
            Plot {
                BarMark(
                    x: .value("Activity Size", element.percentage)
                )
                .foregroundStyle(element.label == String(localized:"Normal") ? Color(hex: SummaryChartColors.lightGreenHex) : element.label == String(localized:"Moderate") ? Color(hex: SummaryChartColors.moderateYellowHex) : Color(hex: SummaryChartColors.highRedHex))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color(.systemFill))
                .cornerRadius(8)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...100)
        .chartYScale(range: .plotDimension(endPadding: -8))
        .chartLegend(position: .bottom, spacing: 8)
        .chartLegend(.visible)
        .frame(height: 20)
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }

    private func generateTimeStringFromTimeStamp(timeStampInSeconds: UInt16) -> String {
        let hourString = String(format: "%02d", Int(timeStampInSeconds/3600))
        let minString = String(format: "%02d", Int((timeStampInSeconds/60))%60)
        
        return hourString + ":" + minString
    }
}

func calculateBucketPercentages(
    temperatures: [Float],
    minMaxBuckets: [(Float, Float)]
) -> [Float] {
    // Initialize an array to store the counts of temperatures falling into each bucket
    var bucketCounts = Array(repeating: 0, count: minMaxBuckets.count)

    // Iterate over each temperature and check which bucket it falls into
    for temperature in temperatures {
        for (index, bucket) in minMaxBuckets.enumerated() {
            let (minTemp, maxTemp) = bucket
            if temperature >= minTemp && temperature <= maxTemp {
                bucketCounts[index] += 1
                break
            }
        }
    }

    // Calculate the total number of temperatures
    let totalTemperatures = temperatures.count

    // If no temperatures are recorded, return an array of zeros
    if totalTemperatures == 0 {
        return Array(repeating: 0, count: minMaxBuckets.count)
    }

    // Compute raw percentages
    var bucketPercentages = bucketCounts.map { count in
        (Float(count) / Float(totalTemperatures)) * 100
    }

    // Round each percentage
    bucketPercentages = bucketPercentages.map { round($0) }

    // Ensure the total is exactly 100%
    let totalRounded = bucketPercentages.reduce(0, +)
    let difference = 100 - totalRounded

    // Adjust the largest bucket to ensure total 100%
    if let maxIndex = bucketPercentages.indices.max(by: { bucketPercentages[$0] < bucketPercentages[$1] }) {
        bucketPercentages[maxIndex] += difference
    }

    return bucketPercentages
}
