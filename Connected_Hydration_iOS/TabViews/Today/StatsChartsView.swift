//
//  StatChartsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 1/15/25.
//

import Foundation
import SwiftUI
import BLEManager

enum ChartsDisplay: String, CaseIterable, Identifiable {
    case water
    case sodium
    case activity
    case temperature

    var id: Self { self }
}

extension ChartsDisplay {
    var indicatorImage: Image {
        switch self {
            
        case .water:
           return Image("indicator_water")
        case .sodium:
            return Image("indicator_sodium")
        case .activity:
            return Image("indicator_activity")
        case .temperature:
            return Image("indicator_temperature")
        }
    }
}

@available(iOS 16.0, *)
struct SegmentView: View {
    @Binding var selectedChart: Int

    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component

    @Binding var sweatWaterSampleSChart: [SweatWaterSampleChartData]
    @Binding var sweatSodiumSampleSChart: [SweatSodiumSampleChartData]
    @Binding var skinTempSChart: [SkinTempChartData]
    @Binding var exertionSChart: [ExertionChartData]

    @Binding var chartYScaleTop: Int
    @Binding var chartYScaleBottom: Int
    @Binding var chartYMetricScaleTop: Int
    @Binding var chartYMetricScaleBottom: Int
    @Binding var chartYScaleSteps: Int
    @Binding var chartYMetricScaleSteps: Int
    @Binding var startSessionHour: Int

    @Binding var chartSodiumYScaleTop: Int
    @Binding var chartSodiumYScaleBottom: Int
    @Binding var chartSodiumYScaleSteps: Int

    var body: some View {
        switch selectedChart {
        case 0:
            WaterIntakeLineChartView(sweatWaterSampleSChart: $sweatWaterSampleSChart, showHourChartXAxis: $showHourChartXAxis, showHourChartXCount: $showHourChartXCount, showHourChartXTime: $showHourChartXTime, chartYScaleTop: $chartYScaleTop, chartYScaleBottom: $chartYScaleBottom, chartYMetricScaleTop: $chartYMetricScaleTop, chartYMetricScaleBottom: $chartYMetricScaleBottom, chartYScaleSteps: $chartYScaleSteps, chartYMetricScaleSteps: $chartYMetricScaleSteps, startSessionHour: $startSessionHour)
        case 1:
            SodiumIntakeLineChartView(sweatSodiumSampleSChart: $sweatSodiumSampleSChart, showHourChartXAxis: $showHourChartXAxis, showHourChartXCount: $showHourChartXCount, showHourChartXTime: $showHourChartXTime, chartSodiumYScaleTop: $chartSodiumYScaleTop, chartSodiumYScaleBottom: $chartSodiumYScaleBottom, chartSodiumYScaleSteps: $chartSodiumYScaleSteps)
        case 2:
            ActivityLineChartView(exertionSChart: $exertionSChart, showHourChartXAxis: $showHourChartXAxis, showHourChartXCount: $showHourChartXCount, showHourChartXTime: $showHourChartXTime)
        default:
            SkinTempLineChartView(skinTempSChart: $skinTempSChart, showHourChartXAxis: $showHourChartXAxis, showHourChartXCount: $showHourChartXCount, showHourChartXTime: $showHourChartXTime)
        }
    }
}

@available(iOS 16.0, *)
struct StatsChartsView: View {
    
    @EnvironmentObject var modelData: ModelData

    @State var notificationSweatHistoricalDataLogDownloadComplete: Any? = nil
    @State var notificationSweatRealtimeDataLog: Any? = nil

    @State var chartYScaleTop = 40
    @State var chartYScaleBottom = -40
    @State var chartYMetricScaleTop = 1250
    @State var chartYMetricScaleBottom = -1250
    @State var chartYScaleSteps = 10
    @State var chartYMetricScaleSteps = 250
    @State var startSessionHour = 0

    @State private var chartSodiumYScaleTop = 1000
    @State private var chartSodiumYScaleBottom = -1000
    @State private var chartSodiumYScaleSteps = 200

    @State var chartDisplaySelection: Int = 0

    @State private var showHourChartXAxis = false
    @State private var showHourChartXCount = 10
    @State private var showHourChartXTime = Calendar.Component.hour

    @State var sweatWaterSampleSChart: [SweatWaterSampleChartData] = []
    @State var sweatSodiumSampleSChart: [SweatSodiumSampleChartData] = []
    @Binding var skinTempSChart: [SkinTempChartData]
    @Binding var exertionSChart: [ExertionChartData]
    @Binding var skinTempData: [Entry]
    @Binding var activityData: [Entry]

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    // Custom binding for the `selection`
    var binding: Binding<Int> {
        .init(get: {
            chartDisplaySelection
        }, set: {
            chartDisplaySelection = $0
            updateHistoricalSweatDataPlot(isUpdate: false)
        })
    }

    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text(String(localized:"STATS:") + " \(getChartString())")
                    .font(.custom("Oswald-Regular", size: languageCode == "ja" ? 16 : 20))
                    .padding(.top, 10)
                    .padding(.leading, 20)
                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                
                Spacer()
                
                Picker("", selection: binding) {
                    ForEach(0..<ChartsDisplay.allCases.count, id: \.self) { index in
                        VStack {
                            ChartsDisplay.allCases[index].indicatorImage
                                .resizable()
                                .frame(width: 24, height: 24)
                                .scaledToFit()
                                .tag(index)
                        }
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.gray)
                .fixedSize()
                .padding(.top, 10)
                .padding(.trailing, 5)
                .onReceive(timer) {_ in
                    if modelData.isCHDeviceConnected == true {
                        if chartDisplaySelection < 3 {
                            chartDisplaySelection += 1
                        }
                        else {
                            chartDisplaySelection = 0
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)

            // Chart views handler
            SegmentView(selectedChart: $chartDisplaySelection, showHourChartXAxis: $showHourChartXAxis, showHourChartXCount: $showHourChartXCount, showHourChartXTime: $showHourChartXTime, sweatWaterSampleSChart: $sweatWaterSampleSChart, sweatSodiumSampleSChart: $sweatSodiumSampleSChart, skinTempSChart: $skinTempSChart, exertionSChart: $exertionSChart, chartYScaleTop: $chartYScaleTop, chartYScaleBottom: $chartYScaleBottom, chartYMetricScaleTop: $chartYMetricScaleTop, chartYMetricScaleBottom: $chartYMetricScaleBottom, chartYScaleSteps: $chartYScaleSteps, chartYMetricScaleSteps: $chartYMetricScaleSteps, startSessionHour: $startSessionHour, chartSodiumYScaleTop: $chartSodiumYScaleTop, chartSodiumYScaleBottom: $chartSodiumYScaleBottom, chartSodiumYScaleSteps: $chartSodiumYScaleSteps)
        }
        .trackRUMView(name: "StatsChartsView")
        .onAppear() {
            
            if (notificationSweatHistoricalDataLogDownloadComplete == nil) {
                //print("**** Started monitoring historical data")
                notificationSweatRealtimeDataLog = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: CHNotifications.SweatDataAvailable), object: nil, queue: OperationQueue.main) { notification in self.updateHistoricalSweatDataPlot(isUpdate: true)
                }
                
                notificationSweatHistoricalDataLogDownloadComplete = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatHistoricalDataLogDownloadComplete), object: nil, queue: OperationQueue.main) { notification in self.updateHistoricalSweatDataPlot(isUpdate: true)
                }
            }

            // Choose random chart to show if device is connected
            if modelData.isCHDeviceConnected == true {
                chartDisplaySelection = generateRandomNumber()
            }
        }
        .onDisappear() {
            NotificationCenter.default.removeObserver(self)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 280)
        .background(Color(.white))
        .cornerRadius(10)
        .padding(.top, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }

    func generateRandomNumber() -> Int {
        return Int.random(in: 0...3)
    }

    func getChartString() -> String {
        if (ChartsDisplay.allCases[chartDisplaySelection].rawValue == "temperature") {
            return String(localized:"SKIN TEMP")
        }
        else if ((ChartsDisplay.allCases[chartDisplaySelection].rawValue == "water")) {
            return String(localized:"WATER")
        }
        else if ((ChartsDisplay.allCases[chartDisplaySelection].rawValue == "activity")) {
            return String(localized:"ACTIVITY")
        }
        else {
            return String(localized:"SODIUM")
        }
    }

    // Brief: Method to display historical sweat data on the appropriate LineChart object
    func updateHistoricalSweatDataPlot(isUpdate: Bool) {
        /** Functional Code **/
                
        let hydrationHistoricalData = modelData.ebsMonitor.getHistoricalData()

        skinTempSChart.removeAll()
        exertionSChart.removeAll()
        skinTempData.removeAll()
        activityData.removeAll()
        sweatWaterSampleSChart.removeAll()
        sweatSodiumSampleSChart.removeAll()
        
        if hydrationHistoricalData.count == 0 {
            return
        }
        
        DispatchQueue.global(qos: .background).sync {
            var currentFluidIntake = 0.0
            var currentSodiumIntake: UInt16 = 0
            var previousTimeStamp: UInt16 = 0
            var chartYWaterMax = 0.0
            var chartYWaterMin = 0.0
            var chartSodiumYDeficitMax = 0.0
            var chartSodiumYDeficitMin = 0.0

            chartYMetricScaleTop = 1250
            chartYMetricScaleBottom = -1250
            chartYMetricScaleSteps = 250
            chartYScaleTop = 40
            chartYScaleBottom = -40
            chartYScaleSteps = 10
            
            chartSodiumYScaleTop = 1000
            chartSodiumYScaleBottom = -1000
            chartSodiumYScaleSteps = 200

            for i in 0...(hydrationHistoricalData.count-1) {
                if previousTimeStamp != hydrationHistoricalData[i].timeStamp {
                    previousTimeStamp = hydrationHistoricalData[i].timeStamp
                    if ((hydrationHistoricalData[i].fluidTotalIntakeInOz != 0) ||
                        (hydrationHistoricalData[i].sodiumTotalIntakeInMg != 0))
                    {
                        currentFluidIntake = hydrationHistoricalData[i].fluidTotalIntakeInOz
                        currentSodiumIntake = hydrationHistoricalData[i].sodiumTotalIntakeInMg
                    }
                    skinTempSChart.append(SkinTempChartData.init(timeStamp: getChartDateTime(seconds: hydrationHistoricalData[i].timeStamp), bodyTemperatureSkinInF: modelData.userPrefsData.getUserTemperatureInF(celsius: hydrationHistoricalData[i].bodyTemperatureSkinInC)))
                    exertionSChart.append(ExertionChartData.init(timeStamp: getChartDateTime(seconds: hydrationHistoricalData[i].timeStamp), activityCounts: hydrationHistoricalData[i].activityCounts))
                    sweatWaterSampleSChart.append(SweatWaterSampleChartData.init(timeStamp: getChartDateTime(seconds: hydrationHistoricalData[i].timeStamp), sweatVolumeDeficitInOz: (Double(hydrationHistoricalData[i].sweatVolumeDeficitInOz) * (-1.0)), fluidTotalIntakeInOz: currentFluidIntake, sweatVolumeTotalLossInOz: hydrationHistoricalData[i].sweatVolumeLossWholeBodyInOz))
                    sweatSodiumSampleSChart.append(SweatSodiumSampleChartData.init(timeStamp: getChartDateTime(seconds: hydrationHistoricalData[i].timeStamp), sweatSodiumDeficitInMg: (Double(hydrationHistoricalData[i].sweatSodiumDeficitInMg) * (-1.0)),
                                                                                   sodiumTotalIntakeInMg: currentSodiumIntake,
                                                                                   sweatSodiumTotalLossInMg: hydrationHistoricalData[i].sweatSodiumLossWholeBodyInMg))
                    
                    // Find high/low of y-axis to see if need to adjust min/max of chart
                    // Water
                    let sweatDeficit = hydrationHistoricalData[i].sweatVolumeDeficitInOz * -1.0
                    if  sweatDeficit > 40 {
                        if chartYWaterMax < sweatDeficit {
                            chartYWaterMax = sweatDeficit
                            
                            if chartYWaterMax > abs(chartYWaterMin) {
                                let newYAxisScaleFactor = (sweatDeficit / 40.0).rounded()
                                chartYScaleTop = Int(40.0 * newYAxisScaleFactor) + 20
                                chartYScaleBottom = chartYScaleTop * -1
                                chartYScaleSteps = Int(10.0 * newYAxisScaleFactor)
                                
                                chartYMetricScaleTop = chartYScaleTop * 30
                                chartYMetricScaleBottom = chartYMetricScaleTop * -1
                                chartYMetricScaleSteps = Int(250.0 * newYAxisScaleFactor)
                            }
                        }
                    }
                    
                    else if sweatDeficit < -40 {
                        if chartYWaterMin > sweatDeficit {
                            chartYWaterMin = sweatDeficit
                            
                            if abs(chartYWaterMin) > chartYWaterMax {
                                
                                let newYAxisScaleFactor = abs((sweatDeficit / 40.0).rounded())
                                chartYScaleTop = Int(40.0 * newYAxisScaleFactor) + 20
                                chartYScaleBottom = chartYScaleTop * -1
                                chartYScaleSteps = Int(10.0 * newYAxisScaleFactor)
                                
                                
                                chartYMetricScaleTop = chartYScaleTop * 30
                                chartYMetricScaleBottom = chartYMetricScaleTop * -1
                                chartYMetricScaleSteps = Int(250.0 * newYAxisScaleFactor)
                            }
                            
                        }
                        
                    }
                    
                    // Sodium
                    let sweatSodiumDeficit = Double(hydrationHistoricalData[i].sweatSodiumDeficitInMg) * (-1.0)
                    if  sweatSodiumDeficit > 1000 {
                        if chartSodiumYDeficitMax < sweatSodiumDeficit {
                            chartSodiumYDeficitMax = sweatSodiumDeficit
                            
                            if chartSodiumYDeficitMax > abs(chartSodiumYDeficitMin) {
                                
                                let newYAxisScaleFactor = (sweatSodiumDeficit / 500.0).rounded() / 2.0
                                chartSodiumYScaleTop = Int((1000.0 * newYAxisScaleFactor)) + 500
                                chartSodiumYScaleBottom = chartSodiumYScaleTop * -1
                                
                                if chartSodiumYScaleTop > 1000 {
                                    chartSodiumYScaleSteps = Int(250 * newYAxisScaleFactor)
                                }
                            }
                        }
                    }
                    
                    else if sweatSodiumDeficit < -1000 {
                        if chartSodiumYDeficitMin > sweatSodiumDeficit {
                            chartSodiumYDeficitMin = sweatSodiumDeficit
                            
                            if abs(chartSodiumYDeficitMin) > chartSodiumYDeficitMax {
                                
                                let newYAxisScaleFactor = abs((sweatSodiumDeficit / 500.0).rounded()) / 2.0
                                chartSodiumYScaleTop = Int(1000 * newYAxisScaleFactor) + 500
                                chartSodiumYScaleBottom = chartSodiumYScaleTop * -1
                                
                                if chartSodiumYScaleTop > 1000 {
                                    chartSodiumYScaleSteps = Int(250 * newYAxisScaleFactor)
                                }
                            }
                        }
                        
                    }

                    // Check to see if need to switch to hour x-axis
                    startSessionHour = getChartSessionStartHour()
                    var currSessionHour = getChartCurrentSessionHour(seconds: hydrationHistoricalData[i].timeStamp)
                    
                    // If current session hour is less than start session hour, the session runs overnight, add 24 hours to the current hour component.
                    if currSessionHour < startSessionHour {
                        currSessionHour += 24
                    }
                    
                    if currSessionHour == startSessionHour {
                        showHourChartXAxis = true
                        showHourChartXCount = 1
                        showHourChartXTime = Calendar.Component.hour
                        
                    }
                    else if currSessionHour - startSessionHour <= 8 {
                        showHourChartXAxis = true
                        showHourChartXCount = 1
                        showHourChartXTime = Calendar.Component.hour
                    }
                    //print("startSessionHour = \(startSessionHour) : \(currSessionHour)")
                    //print("currSessionHour - startSessionHour = \(currSessionHour - startSessionHour)")
                    else if currSessionHour - startSessionHour <= 12 {
                        showHourChartXCount = 2
                        showHourChartXAxis = true
                    }
                    else {
                        showHourChartXCount = 4
                        showHourChartXAxis = true
                    }
                }
            }   // for loop

            // Handle summary view bar charts
            let minMaxActivityCounts: [(Float, Float)] = [
                (0.0, 16.9),
                (17.0, 29.9),
                (30.0, 34.9),
                (35.0, 45.0)
            ]

            let activityCounts: [Float] = exertionSChart.map { activityData in
                Float(activityData.activityCounts)
            }
            let activityPercentages = calculateBucketPercentages(temperatures: activityCounts, minMaxBuckets: minMaxActivityCounts)
            //print("activityPercentages = \(activityPercentages)")

            self.activityData = [
                .init(label: String(localized:"Very Low"), percentage: Int(activityPercentages[0])),
                .init(label: String(localized:"Light"), percentage: Int(activityPercentages[1])),
                .init(label: String(localized:"Moderate"), percentage: Int(activityPercentages[2])),
                .init(label: String(localized:"Intense"), percentage: Int(activityPercentages[3])),
            ]

            // Values are only in F skinTempSChart array
            let minMaxTemps = [
                    (Float(60.0), Float(89.9)),
                    (Float(90.0), Float(98.6)),
                    (Float(98.7), Float(120.0))
                ]

            let skinTemps: [Float] = skinTempSChart.map { sweatData in
                Float(sweatData.bodyTemperatureSkinInF)
            }

            let skinTempPercentages = calculateBucketPercentages(temperatures: skinTemps, minMaxBuckets: minMaxTemps)
            //print("skinTempPercentages = \(skinTempPercentages)")

            self.skinTempData = [
                .init(label: String(localized:"Normal"), percentage: Int(skinTempPercentages[0])),
                .init(label: String(localized:"Moderate"), percentage: Int(skinTempPercentages[1])),
                .init(label: String(localized:"High"), percentage: Int(skinTempPercentages[2])),
            ]
        }
        
        sweatWaterSampleSChart = sweatWaterSampleSChart.sorted(by: { $0.timeStamp.compare($1.timeStamp) == .orderedAscending })
        sweatSodiumSampleSChart = sweatSodiumSampleSChart.sorted(by: { $0.timeStamp.compare($1.timeStamp) == .orderedAscending })
        
        modelData.historicalSweatDataDownloadCompleted = true
    }
    
}
