//
//  HistoryView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//

import SwiftUI
import BLEManager
import DGCharts
import KeychainAccess

struct HistoryView: View {

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    @EnvironmentObject var modelData: ModelData

    @State private var sweatDataStatsDataRangeSelect: Int = 0
    @State private var sweatElectrolyteDisplaySelect: Int = 0
    @State private var viewTitle = String(localized:"DAY")

    @State var lineChartData = LineChartData()
    @State var barChartData = BarChartData()

    @State var daysArrayWeekly: [String] = []
    @State var sweatWaterLossDataArrayWeekly: [Double] = []
    @State var sweatSodiumLossDataArrayWeekly: [Double] = []
    @State var waterIntakeDataArrayWeekly: [Double] = []
    @State var sodiumIntakeDataArrayWeekly: [Double] = []

    @State var daysArrayMonthly: [String] = []
    @State var sweatWaterLossDataArrayMonthly: [Double] = []
    @State var sweatSodiumLossDataArrayMonthly: [Double] = []
    @State var waterIntakeDataArrayMonthly: [Double] = []
    @State var sodiumIntakeDataArrayMonthly: [Double] = []

    @State var sweatElectrolyteDisplaySelection: Int = 0
    @State var historicalSweatDataDownloadCompleted: Bool = true

    @Binding var tabNothing: Tab
    
    var body: some View {
        NavigationStack {
            ZStack {
                BgStatusView() {}
                ScrollView(.vertical, showsIndicators: true) {
                    VStack (spacing: 0) {
                        HStack {
                            
                            Text(viewTitle)
                                .font(.custom("Oswald-Regular", size: 20))
                                .padding(.top, 10)
                                .padding(.leading, 20)
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                            Spacer()
                            
                            Picker(selection: $sweatElectrolyteDisplaySelect.onChange(sweatElectrolyteChange), label: Text("")) {
                                Text("WATER").tag(0)
                                Text("SODIUM").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                            
                            //                        Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        if sweatDataStatsDataRangeSelect == 0 {
                            DataHistoricalLineChartView(lineChartEntrySweatSamples: $lineChartData, sweatElectrolyteDisplaySelection: $sweatElectrolyteDisplaySelection)
                                .frame(height: 240)
                                .frame(maxHeight: .infinity)
                                .padding(.bottom, 20)
                            
                            Text("WORK TIME (HR)")
                                .font(.custom("Oswald-Regular", size: 12))
                                .padding(.top, -30)
                                .frame(alignment: .center)
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                        }
                        else {
                            WeeklyBarChartView(barChartEntrySamples: $barChartData, sweatElectrolyteDisplaySelection: $sweatElectrolyteDisplaySelection, dateRangeSelection: $sweatDataStatsDataRangeSelect, daysArrayWeekly: $daysArrayWeekly, sweatWaterLossDataArrayWeekly: $sweatWaterLossDataArrayWeekly, sweatSodiumLossDataArrayWeekly: $sweatSodiumLossDataArrayWeekly, waterIntakeDataArrayWeekly: $waterIntakeDataArrayWeekly, sodiumIntakeDataArrayWeekly: $sodiumIntakeDataArrayWeekly, daysArrayMonthly: $daysArrayMonthly, sweatWaterLossDataArrayMonthly: $sweatWaterLossDataArrayMonthly, sweatSodiumLossDataArrayMonthly: $sweatSodiumLossDataArrayMonthly, waterIntakeDataArrayMonthly: $waterIntakeDataArrayMonthly, sodiumIntakeDataArrayMonthly: $sodiumIntakeDataArrayMonthly)
                            
                                .frame(height: 240)
                                .frame(maxHeight: .infinity)
                                .padding(.bottom, 20)
                        }
                        
                        Picker(selection: $sweatDataStatsDataRangeSelect.onChange(viewLengthChange), label: Text("")) {
                            Text("DAY").tag(0)
                            Text("WEEK").tag(1)
                            Text("MONTH").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 400)
                    .background(Color(.white))
                    .cornerRadius(10)
                    .padding(.top, languageCode == "ja" ? ((modelData.sweatDashboardViewStatus == 1) ? 70 : 50) : 50)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }   // ScrollView
                .clipped()
                
                BgTabIntakeExtensionView(tabSelection: $tabNothing)
                    .clipped()
            }
            .addToolbar()
        }
        .trackRUMView(name: "HistoryView")
        .onAppear() {
            modelData.rootViewId = UUID()

            modelData.networkManager.modelData = modelData
            modelData.networkManager.getUserHistoryStats()

            if(sweatDataStatsDataRangeSelect == 0) {
                plotHistoricalSweatData()
            }
            
            else {
                plotHistoricalSweatDataWeeklyOrMonthly()
            }
        }
    }

    func viewLengthChange(_ tag: Int) {
        print("date length tag: \(tag)")
        if tag == 0 {
            logger.info("history", attributes: ["time_period": "day"])
            self.viewTitle = String(localized:"DAY")
            plotHistoricalSweatData()
        }
        else if tag == 1 {
            logger.info("history", attributes: ["time_period": "week"])
            self.viewTitle = String(localized:"WEEK")
            plotHistoricalSweatDataWeeklyOrMonthly()
        }
        else {
            logger.info("history", attributes: ["time_period": "month"])
                self.viewTitle = String(localized:"MONTH")
            plotHistoricalSweatDataWeeklyOrMonthly()
        }
    }

    func sweatElectrolyteChange(_ tag: Int) {
        print("sweat/electrolyte tag: \(tag)")
        if tag == 0 {
            sweatElectrolyteDisplaySelection = 0

            logger.info("history", attributes: ["loss_type": "sweat"])

            if self.sweatDataStatsDataRangeSelect == 0 {
                plotHistoricalSweatData()
            }
            else {
                plotHistoricalSweatDataWeeklyOrMonthly()
            }
        }
        else {
            sweatElectrolyteDisplaySelection = 1

            logger.info("history", attributes: ["loss_type": "sodium"])

            if self.sweatDataStatsDataRangeSelect == 0 {
                plotHistoricalSweatData()
            }
            else {
                plotHistoricalSweatDataWeeklyOrMonthly()
            }
        }
    }

    // Brief: Method to display historical sweat data on the appropriate LineChart object
    func plotHistoricalSweatData()
    {
        let hydrationHistoricalData = BLEManager.bleSingleton.getHydrationHistoricalData()
        //self.hydrationHistoricalData.append(contentsOf: BLEManager.bleSingleton.getHydrationHistoricalDataFromIndex(index: hydrationHistoricalData.count))

        if (sweatElectrolyteDisplaySelection == 0)
        {
            if(hydrationHistoricalData.count > 0) {
                
                // Defining chart line arrays
                var lineChartEntrySweatSamples = [ChartDataEntry]()

                DispatchQueue.global(qos: .background).sync {
                    /**** Adding datapoints to line arrays ****/
                    for i in 0...(hydrationHistoricalData.count-1) {
                        lineChartEntrySweatSamples.append(ChartDataEntry(x: Double(hydrationHistoricalData[i].timeStamp)/3600.0, y: (modelData.userPrefsData.handleUserSweatConversion(oz: hydrationHistoricalData[i].sweatVolumeDeficitInOz) * (-1.0))))
                    }
                }

//                lineChartEntrySweatSamples.sort {$0.x < $1.x}

                /******************************************/
                lineChartData = LineChartData()  // Declaring data for Chart

                let lineX = LineChartDataSet(entries: lineChartEntrySweatSamples, label: modelData.userPrefsData.getUserSweatUnitString())
                lineX.drawCirclesEnabled = false;
                lineX.colors = [NSUIColor.systemBlue]
//                lineX.mode = .cubicBezier
                lineX.lineWidth = 2
                lineX.drawHorizontalHighlightIndicatorEnabled = false
                lineX.highlightColor = .systemRed
                
                lineChartData.append(lineX)  //Adds the line to the dataSet

                /**** Plot Data ****/
                lineChartData.setDrawValues(false)
            }
        }
        
        if (sweatElectrolyteDisplaySelection == 1)
        {
            if(hydrationHistoricalData.count > 0) {
                
                // Defining chart line arrays
                var lineChartEntrySweatSamples = [ChartDataEntry]()
                                
                DispatchQueue.global(qos: .background).sync {
                    /**** Adding datapoints to line arrays ****/
                    for i in 0...(hydrationHistoricalData.count-1) {
                        lineChartEntrySweatSamples.append(ChartDataEntry(x: Double(hydrationHistoricalData[i].timeStamp)/3600.0, y: (modelData.userPrefsData.handleUserSodiumConversion(mg: hydrationHistoricalData[i].sweatSodiumDeficitInMg) * (-1.0))))
                    }
                }

//                lineChartEntrySweatSamples.sort {$0.x < $1.x}
                                
                /******************************************/
                lineChartData = LineChartData()  // Declaring data for Chart
                
                let lineX = LineChartDataSet(entries: lineChartEntrySweatSamples, label: modelData.userPrefsData.getUserSodiumUnitString())
                lineX.drawCirclesEnabled = false
                lineX.colors = [NSUIColor.systemPurple]
//                lineX.mode = .cubicBezier
                lineX.lineWidth = 2
                lineX.drawHorizontalHighlightIndicatorEnabled = false
                lineX.highlightColor = .systemRed
                
                lineChartData.append(lineX)  //Adds the line to the dataSet

                /**** Plot Data ****/
                lineChartData.setDrawValues(false)
                //sweatDataHistoricalView.data = data //Adds chart data to the chart and causes an update
            }
        }
    }

    func plotHistoricalSweatDataWeeklyOrMonthly() {
        
        var weeklyOrMonthlyDataArray: [DayIntakeLossData] = []
        
        if(self.sweatDataStatsDataRangeSelect == 1) {
        
            daysArrayWeekly = []
            sweatWaterLossDataArrayWeekly = []
            sweatSodiumLossDataArrayWeekly = []
            waterIntakeDataArrayWeekly = []
            sodiumIntakeDataArrayWeekly = []

            // Get the past 7 days of data
            let weeklyStatsData = modelData.userHistoryStats?.data.suffix(7)
            
            do {
                weeklyStatsData?.forEach {
                    weeklyOrMonthlyDataArray.append($0)
                }
                
                if weeklyOrMonthlyDataArray.count > 0 {
        
                    weeklyOrMonthlyDataArray.forEach {
                        let dateWithoutYearString = String($0.date.suffix(5))
                        daysArrayWeekly.append(dateWithoutYearString)
                        
                        sweatWaterLossDataArrayWeekly.append(modelData.userPrefsData.handleUserSweatConversion(ml: ($0.water_loss_ml ?? 0.0)))
                        sweatSodiumLossDataArrayWeekly.append($0.sodium_loss_ml ?? 0.0)
                        waterIntakeDataArrayWeekly.append(modelData.userPrefsData.handleUserSweatConversion(ml: ($0.water_intake_ml ?? 0.0)))
                        sodiumIntakeDataArrayWeekly.append($0.sodium_intake_ml ?? 0.0)
                    }
                    
                    var sweatWaterLossDataWeeklyEntries = [BarChartDataEntry]()
                    var waterIntakeDataWeeklyEntries = [BarChartDataEntry]()
                    var sweatSodiumLossDataWeeklyEntries = [BarChartDataEntry]()
                    var sodiumIntakeDataWeeklyEntries = [BarChartDataEntry]()
                    
                    for i in 0..<(weeklyOrMonthlyDataArray.count-1) {
                        sweatWaterLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: sweatWaterLossDataArrayWeekly[i]))
                        waterIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: waterIntakeDataArrayWeekly[i]))
                        sweatSodiumLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: sweatSodiumLossDataArrayWeekly[i]))
                        sodiumIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: sodiumIntakeDataArrayWeekly[i]))
                    }
                    
                    // Add current day's data from real-time reading from the patch.
                    sweatWaterLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(6), y: modelData.userPrefsData.handleUserSweatConversion(oz: BLEManager.bleSingleton.currentSweatFluidLossWholeBodyInOz)))
                    waterIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(6), y: modelData.userPrefsData.handleUserSweatConversion(oz: BLEManager.bleSingleton.currentFluidTotalIntakeInOz)))
                    sweatSodiumLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(6), y: modelData.userPrefsData.handleUserSodiumConversion(mg: BLEManager.bleSingleton.currentSweatSodiumLossWholeBodyInMg)))
                    sodiumIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(6), y: modelData.userPrefsData.handleUserSodiumConversion(mg: BLEManager.bleSingleton.currentSodiumTotalIntakeInMg)))
                    
                    let barSweatWaterLoss = BarChartDataSet(entries: sweatWaterLossDataWeeklyEntries, label: String(localized:"Loss") + "(" + modelData.userPrefsData.getUserSweatUnitString() + ")")
                    barSweatWaterLoss.colors = [UIColor(red: 172.0/255.0, green: 201.0/255.0, blue: 224.0/255.0, alpha: 1.0)]
                    
                    let barWaterIntake = BarChartDataSet(entries: waterIntakeDataWeeklyEntries, label: String(localized:"Intake") + "(" + modelData.userPrefsData.getUserSweatUnitString() + ")")
                    barWaterIntake.colors = [UIColor(red: 35.0/255.0, green: 155.0/255.0, blue: 218.0/255.0, alpha: 1.0)]
                    
                    let barSweatSodiumLoss = BarChartDataSet(entries: sweatSodiumLossDataWeeklyEntries, label: String(localized:"Loss") + "(" + modelData.userPrefsData.getUserSodiumUnitString() + ")")
                    barSweatSodiumLoss.colors = [UIColor(red: 179.0/255.0, green: 162.0/255.0, blue: 206.0/255.0, alpha: 1.0)]
                    
                    let barSodiumIntake = BarChartDataSet(entries: sodiumIntakeDataWeeklyEntries, label: String(localized:"Intake") + "(" + modelData.userPrefsData.getUserSodiumUnitString() + ")")
                    barSodiumIntake.colors = [UIColor(red: 108.0/255.0, green: 73.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
                    
                    var barChartDataSet : [BarChartDataSet]
                    
                    if(self.sweatElectrolyteDisplaySelection == 0) {
                        barChartDataSet = [barWaterIntake, barSweatWaterLoss]
                        barChartData = BarChartData(dataSets: barChartDataSet)
                    }
                    
                    else {
                        barChartDataSet = [barSodiumIntake, barSweatSodiumLoss]
                        barChartData = BarChartData(dataSets: barChartDataSet)
                    }
                    
                    barChartData.setDrawValues(false)
                    
                }
            }
        }
            
        else {
                
            daysArrayMonthly = []
            sweatWaterLossDataArrayMonthly = []
            sweatSodiumLossDataArrayMonthly = []
            waterIntakeDataArrayMonthly = []
            sodiumIntakeDataArrayMonthly = []
            
            // Get the past 30 days of data
            let monthlyStatsData = modelData.userHistoryStats?.data.suffix(30)
            
            do {
                monthlyStatsData?.forEach {
                    weeklyOrMonthlyDataArray.append($0)
                }
                
                if(weeklyOrMonthlyDataArray.count > 0) {
                    
                    weeklyOrMonthlyDataArray.forEach {
                        let dateWithoutYearString = String($0.date.suffix(5))
                        daysArrayMonthly.append(dateWithoutYearString)
                        
                        sweatWaterLossDataArrayMonthly.append(modelData.userPrefsData.handleUserSweatConversion(ml: ($0.water_loss_ml ?? 0.0)))
                        sweatSodiumLossDataArrayMonthly.append($0.sodium_loss_ml ?? 0.0)
                        waterIntakeDataArrayMonthly.append(modelData.userPrefsData.handleUserSweatConversion(ml: ($0.water_intake_ml ?? 0.0)))
                        sodiumIntakeDataArrayMonthly.append($0.sodium_intake_ml ?? 0.0)
                    }
                    
                    var sweatWaterLossDataWeeklyEntries = [BarChartDataEntry]()
                    var waterIntakeDataWeeklyEntries = [BarChartDataEntry]()
                    var sweatSodiumLossDataWeeklyEntries = [BarChartDataEntry]()
                    var sodiumIntakeDataWeeklyEntries = [BarChartDataEntry]()
                    
                    for i in 0..<(weeklyOrMonthlyDataArray.count-1) {
                        sweatWaterLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(i), y: sweatWaterLossDataArrayMonthly[i]))
                        waterIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(i), y: waterIntakeDataArrayMonthly[i]))
                        sweatSodiumLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(i), y: sweatSodiumLossDataArrayMonthly[i]))
                        sodiumIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(i), y: sodiumIntakeDataArrayMonthly[i]))
                    }

                    // Add current day's data from real-time reading from the patch.
                    sweatWaterLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: modelData.userPrefsData.handleUserSweatConversion(oz: BLEManager.bleSingleton.currentSweatFluidLossWholeBodyInOz)))
                    waterIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: modelData.userPrefsData.handleUserSweatConversion(oz: BLEManager.bleSingleton.currentFluidTotalIntakeInOz)))
                    sweatSodiumLossDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: modelData.userPrefsData.handleUserSodiumConversion(mg: BLEManager.bleSingleton.currentSweatSodiumLossWholeBodyInMg)))
                    sodiumIntakeDataWeeklyEntries.append(BarChartDataEntry(x: Double(weeklyOrMonthlyDataArray.count-1), y: modelData.userPrefsData.handleUserSodiumConversion(mg: BLEManager.bleSingleton.currentSodiumTotalIntakeInMg)))
                    
                    let barSweatWaterLoss = BarChartDataSet(entries: sweatWaterLossDataWeeklyEntries, label: String(localized:"Loss") + "(" + modelData.userPrefsData.getUserSweatUnitString() + ")")
                    barSweatWaterLoss.colors = [UIColor(red: 172.0/255.0, green: 201.0/255.0, blue: 224.0/255.0, alpha: 1.0)]
                    
                    let barWaterIntake = BarChartDataSet(entries: waterIntakeDataWeeklyEntries, label: String(localized:"Intake") + "(" + modelData.userPrefsData.getUserSweatUnitString() + ")")
                    barWaterIntake.colors = [UIColor(red: 35.0/255.0, green: 155.0/255.0, blue: 218.0/255.0, alpha: 1.0)]
                    
                    let barSweatSodiumLoss = BarChartDataSet(entries: sweatSodiumLossDataWeeklyEntries, label: String(localized:"Loss") + "(" + modelData.userPrefsData.getUserSodiumUnitString() + ")")
                    barSweatSodiumLoss.colors = [UIColor(red: 179.0/255.0, green: 162.0/255.0, blue: 206.0/255.0, alpha: 1.0)]
                    
                    let barSodiumIntake = BarChartDataSet(entries: sodiumIntakeDataWeeklyEntries, label: String(localized:"Intake") + "(" + modelData.userPrefsData.getUserSodiumUnitString() + ")")
                    barSodiumIntake.colors = [UIColor(red: 108.0/255.0, green: 73.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
                    
                    var barChartDataSet : [BarChartDataSet]
                    
                    if(self.sweatElectrolyteDisplaySelection == 0) {
                        barChartDataSet = [barWaterIntake, barSweatWaterLoss]
                        barChartData = BarChartData(dataSets: barChartDataSet)
                    }
                    
                    else {
                        barChartDataSet = [barSodiumIntake, barSweatSodiumLoss]
                        barChartData = BarChartData(dataSets: barChartDataSet)
                    }
                    
                    barChartData.setDrawValues(false)
                }
            }

        }
                        
    }

    private func generateCurrentLocalDate () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (formatter.string(from: Date()) as NSString) as String
    }

    // Brief: Method to display historical sweat data on the appropriate LineChart object
    func updateHistoricalSweatDataPlot()
    {
        let hydrationHistoricalData = BLEManager.bleSingleton.getHydrationHistoricalData()
        //self.hydrationHistoricalData.append(contentsOf: BLEManager.bleSingleton.getHydrationHistoricalDataFromIndex(index: hydrationHistoricalData.count))

        if (sweatElectrolyteDisplaySelection == 0)
        {
            if(hydrationHistoricalData.count > 0) {

                // Defining chart line arrays
                var lineChartEntrySweatSamples = [ChartDataEntry]()

                /**** Adding datapoints to line arrays ****/
                DispatchQueue.global(qos: .background).sync {
                    for i in 0...(hydrationHistoricalData.count-1) {
                        lineChartEntrySweatSamples.append(ChartDataEntry(x: Double(hydrationHistoricalData[i].timeStamp)/3600.0, y: (modelData.userPrefsData.handleUserSweatConversion(oz: hydrationHistoricalData[i].sweatVolumeDeficitInOz) * (-1.0))))
                    }
                }

//                lineChartEntrySweatSamples.sort {$0.x < $1.x}

                /******************************************/
                let lineChartData = LineChartData()  // Declaring data for Chart

                let lineX = LineChartDataSet(entries: lineChartEntrySweatSamples, label: "")
                lineX.drawCirclesEnabled = false;
                lineX.colors = [NSUIColor.systemBlue]
//                lineX.mode = .cubicBezier
                lineX.lineWidth = 2
                lineX.drawHorizontalHighlightIndicatorEnabled = false
                lineX.highlightColor = .systemRed

                lineChartData.append(lineX)  //Adds the line to the dataSet

                /**** Plot Data ****/
                lineChartData.setDrawValues(false)
                //sweatDataHistoricalView.data = data //Adds chart data to the chart and causes an update
            }

            historicalSweatDataDownloadCompleted = true
        }
        
        if (sweatElectrolyteDisplaySelection == 1)
        {
            if(hydrationHistoricalData.count > 0) {

                // Defining chart line arrays
                var lineChartEntrySweatSamples = [ChartDataEntry]()
                
                DispatchQueue.global(qos: .background).sync {
                    /**** Adding datapoints to line arrays ****/
                    for i in 0...(hydrationHistoricalData.count-1) {
                        lineChartEntrySweatSamples.append(ChartDataEntry(x: Double(hydrationHistoricalData[i].timeStamp)/3600.0, y: (modelData.userPrefsData.handleUserSodiumConversion(mg: hydrationHistoricalData[i].sweatSodiumDeficitInMg) * (-1.0))))
                    }
                }

//                lineChartEntrySweatSamples.sort {$0.x < $1.x}

                /******************************************/
                let lineChartData = LineChartData()  // Declaring data for Chart

                let lineX = LineChartDataSet(entries: lineChartEntrySweatSamples, label: "")
                lineX.drawCirclesEnabled = false
                lineX.colors = [NSUIColor.systemPurple]
//                lineX.mode = .cubicBezier
                lineX.lineWidth = 2
                lineX.drawHorizontalHighlightIndicatorEnabled = false
                lineX.highlightColor = .systemRed

                lineChartData.append(lineX)  //Adds the line to the dataSet

                /**** Plot Data ****/
                lineChartData.setDrawValues(false)
                //sweatDataHistoricalView.data = data //Adds chart data to the chart and causes an update
            }

            historicalSweatDataDownloadCompleted = true
        }
    }

}

struct DataHistoricalLineChartView : UIViewRepresentable {

    var sweatDataHistoricalView = LineChartView()

    @Binding var lineChartEntrySweatSamples: LineChartData
    @Binding var sweatElectrolyteDisplaySelection: Int

    func makeUIView(context: Context) -> LineChartView {
        
        sweatDataHistoricalView.leftAxis.drawLabelsEnabled = true      // Draw the left y-axis
        sweatDataHistoricalView.rightAxis.drawLabelsEnabled = false    // Don't draw the right y-axis
        sweatDataHistoricalView.xAxis.drawGridLinesEnabled = true      // Draw x-axis grid lines
        sweatDataHistoricalView.leftAxis.drawGridLinesEnabled = true   // Draw y-axis grid lines
        sweatDataHistoricalView.rightAxis.drawGridLinesEnabled = false // Don't draw y-axis grid lines

        sweatDataHistoricalView.xAxis.labelPosition = .bottom
        sweatDataHistoricalView.xAxis.setLabelCount(10, force: false)

        sweatDataHistoricalView.xAxis.axisMaximum = (round(lineChartEntrySweatSamples.xMax) + 1.0)
        sweatDataHistoricalView.animate(xAxisDuration: 2)

        if sweatElectrolyteDisplaySelection == 0 {
            sweatDataHistoricalView.leftAxis.axisMinimum = -80.0
            sweatDataHistoricalView.leftAxis.axisMaximum = 80.0
            sweatDataHistoricalView.leftAxis.setLabelCount(9, force: true)

        }
        else /*if sweatElectrolyteDisplaySelection == 1*/ {
            sweatDataHistoricalView.leftAxis.axisMinimum = -1000.0
            sweatDataHistoricalView.leftAxis.axisMaximum = 1000.0
            sweatDataHistoricalView.leftAxis.setLabelCount(11, force: true)
        }

        sweatDataHistoricalView.legend.textColor = UIColor.label

        return sweatDataHistoricalView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {

        // is there a refresh?
        
        if sweatElectrolyteDisplaySelection == 0 {

            uiView.leftAxis.axisMinimum = -80.0
            uiView.leftAxis.axisMaximum = 80.0

            if(lineChartEntrySweatSamples.yMax > 75.0) {
                uiView.leftAxis.axisMaximum = (round(lineChartEntrySweatSamples.yMax/20.0) + 2.0) * 20.0
            }
            if(lineChartEntrySweatSamples.yMin < -75.0) {
                uiView.leftAxis.axisMinimum = (round(lineChartEntrySweatSamples.yMin/20.0) - 2.0) * 20.0
            }
            
            uiView.leftAxis.setLabelCount(9, force: true)
        }
        else /*if sweatElectrolyteDisplaySelection == 1*/ {
            uiView.leftAxis.axisMinimum = -1000.0
            uiView.leftAxis.axisMaximum = 1000.0
            
            if(lineChartEntrySweatSamples.yMax > 800.0) {
                uiView.leftAxis.axisMaximum = (round(lineChartEntrySweatSamples.yMax/100.0) + 2.0) * 100.0
            }
            if(lineChartEntrySweatSamples.yMin < -800.0) {
                uiView.leftAxis.axisMinimum = (round(lineChartEntrySweatSamples.yMin/100.0) - 2.0) * 100.0
            }
            
            uiView.leftAxis.setLabelCount(11, force: true)
        }
        
//        uiView.animate(xAxisDuration: 2)
        
        // Expand x-axis with more data.
        uiView.xAxis.axisMaximum = (round(lineChartEntrySweatSamples.xMax) + 1.0)
        
        uiView.data = addData()
    }
    
    func addData() -> LineChartData {
        return lineChartEntrySweatSamples
    }

    typealias UIViewType = LineChartView
    
}

struct WeeklyBarChartView : UIViewRepresentable {

    var sweatDataHistoricalViewWeekly = BarChartView()

    @Binding var barChartEntrySamples: BarChartData
    @Binding var sweatElectrolyteDisplaySelection: Int
    @Binding var dateRangeSelection: Int
    @Binding var daysArrayWeekly: [String]
    @Binding var sweatWaterLossDataArrayWeekly: [Double]
    @Binding var sweatSodiumLossDataArrayWeekly: [Double]
    @Binding var waterIntakeDataArrayWeekly: [Double]
    @Binding var sodiumIntakeDataArrayWeekly: [Double]
    @Binding var daysArrayMonthly: [String]
    @Binding var sweatWaterLossDataArrayMonthly: [Double]
    @Binding var sweatSodiumLossDataArrayMonthly: [Double]
    @Binding var waterIntakeDataArrayMonthly: [Double]
    @Binding var sodiumIntakeDataArrayMonthly: [Double]

//    @Binding var sweatWaterLossDataWeeklyEntries: [BarChartDataEntry]
    
    func makeUIView(context: Context) -> BarChartView {

        self.sweatDataHistoricalViewWeekly.leftAxis.drawLabelsEnabled = true      // Draw the left y-axis
        self.sweatDataHistoricalViewWeekly.rightAxis.drawLabelsEnabled = false    // Don't draw the right y-axis
        self.sweatDataHistoricalViewWeekly.xAxis.drawGridLinesEnabled = false      // Draw x-axis grid lines
        self.sweatDataHistoricalViewWeekly.leftAxis.drawGridLinesEnabled = true   // Draw y-axis grid lines
        self.sweatDataHistoricalViewWeekly.rightAxis.drawGridLinesEnabled = false // Don't draw y-axis grid lines
        
        self.sweatDataHistoricalViewWeekly.legend.horizontalAlignment = .center
        self.sweatDataHistoricalViewWeekly.extraBottomOffset = 5.0
        
//        self.sweatDataHistoricalViewWeekly.xAxis.centerAxisLabelsEnabled = true
        
        if(dateRangeSelection == 1) {
            let groupSpace = 0.10
            let barSpace = 0.01
            let barWidth = 0.44
            
            self.sweatDataHistoricalViewWeekly.xAxis.drawLabelsEnabled = true
            self.sweatDataHistoricalViewWeekly.xAxis.labelPosition = .bottom
            self.sweatDataHistoricalViewWeekly.xAxis.centerAxisLabelsEnabled = true
            self.sweatDataHistoricalViewWeekly.xAxis.setLabelCount(7, force: false)
            self.sweatDataHistoricalViewWeekly.xAxis.labelRotationAngle = 0
            
            let startDate = 0
            barChartEntrySamples.barWidth = barWidth
            barChartEntrySamples.groupBars(fromX: Double(startDate), groupSpace: groupSpace, barSpace: barSpace)
            self.sweatDataHistoricalViewWeekly.notifyDataSetChanged()
            self.sweatDataHistoricalViewWeekly.xAxis.axisMinimum = Double(startDate)
            let gg = barChartEntrySamples.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            self.sweatDataHistoricalViewWeekly.xAxis.axisMaximum =  Double(startDate) +  gg * Double(7)
            self.sweatDataHistoricalViewWeekly.xAxis.valueFormatter = IndexAxisValueFormatter(values: daysArrayWeekly)
            print(self.sweatDataHistoricalViewWeekly.xAxis.axisMaximum)
            
        }
        else {
            let groupSpace = 0.10
            let barSpace = 0.01
            let barWidth = 0.44

            self.sweatDataHistoricalViewWeekly.xAxis.drawLabelsEnabled = true
            self.sweatDataHistoricalViewWeekly.xAxis.labelPosition = .bottom
            self.sweatDataHistoricalViewWeekly.xAxis.centerAxisLabelsEnabled = false
            self.sweatDataHistoricalViewWeekly.xAxis.labelRotationAngle = -60
            self.sweatDataHistoricalViewWeekly.xAxis.setLabelCount(15, force: false)
                        
            let startDate = 0
            barChartEntrySamples.barWidth = barWidth
            barChartEntrySamples.groupBars(fromX: Double(startDate), groupSpace: groupSpace, barSpace: barSpace)
            self.sweatDataHistoricalViewWeekly.notifyDataSetChanged()
            self.sweatDataHistoricalViewWeekly.xAxis.axisMinimum = Double(startDate)
            let gg = barChartEntrySamples.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            self.sweatDataHistoricalViewWeekly.xAxis.axisMaximum =  Double(startDate) +  gg * Double(30)
            self.sweatDataHistoricalViewWeekly.xAxis.valueFormatter = IndexAxisValueFormatter(values: daysArrayMonthly)
            print(self.sweatDataHistoricalViewWeekly.xAxis.axisMaximum)
        }
        
        if(self.sweatElectrolyteDisplaySelection == 0) {
            self.sweatDataHistoricalViewWeekly.leftAxis.setLabelCount(9, force: true)
            self.sweatDataHistoricalViewWeekly.leftAxis.axisMinimum = 0.0
            self.sweatDataHistoricalViewWeekly.leftAxis.axisMaximum = 80.0
            self.sweatDataHistoricalViewWeekly.animate(yAxisDuration: 1)
        }
        
        else {
            self.sweatDataHistoricalViewWeekly.leftAxis.setLabelCount(11, force: true)
            self.sweatDataHistoricalViewWeekly.leftAxis.axisMinimum = 0.0
            self.sweatDataHistoricalViewWeekly.leftAxis.axisMaximum = 1000.0
            self.sweatDataHistoricalViewWeekly.animate(yAxisDuration: 1)
        }
        
        self.sweatDataHistoricalViewWeekly.legend.textColor = UIColor.label

        return sweatDataHistoricalViewWeekly
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {

        if(dateRangeSelection == 1) {
            
            let groupSpace = 0.10
            let barSpace = 0.01
            let barWidth = 0.44
            
            uiView.xAxis.drawLabelsEnabled = true
            uiView.xAxis.labelPosition = .bottom
            uiView.xAxis.centerAxisLabelsEnabled = true
            uiView.xAxis.setLabelCount(7, force: false)
            uiView.xAxis.labelRotationAngle = 0

            let startDate = 0
            barChartEntrySamples.barWidth = barWidth
            barChartEntrySamples.groupBars(fromX: Double(startDate), groupSpace: groupSpace, barSpace: barSpace)
            uiView.notifyDataSetChanged()
            uiView.xAxis.axisMinimum = Double(startDate)
            let gg = barChartEntrySamples.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            uiView.xAxis.axisMaximum =  Double(startDate) +  gg * Double(7)
            uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: daysArrayWeekly)

        }
        else {
            let groupSpace = 0.10
            let barSpace = 0.01
            let barWidth = 0.44

            uiView.xAxis.drawLabelsEnabled = true
            uiView.xAxis.labelPosition = .bottom
            uiView.xAxis.centerAxisLabelsEnabled = false
            uiView.xAxis.setLabelCount(15, force: false)
            uiView.xAxis.labelRotationAngle = -60
            
            let startDate = 0
            barChartEntrySamples.barWidth = barWidth
            barChartEntrySamples.groupBars(fromX: Double(startDate), groupSpace: groupSpace, barSpace: barSpace)
            uiView.notifyDataSetChanged()
            uiView.xAxis.axisMinimum = Double(startDate)
            let gg = barChartEntrySamples.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            uiView.xAxis.axisMaximum =  Double(startDate) +  gg * Double(30)
            uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: daysArrayMonthly)

        }
        
        if(self.sweatElectrolyteDisplaySelection == 0) {
            uiView.leftAxis.axisMinimum = 0.0
            uiView.leftAxis.axisMaximum = 80.0
            
            if barChartEntrySamples.yMax > 75.0 {
                uiView.leftAxis.axisMaximum = (round(barChartEntrySamples.yMax/20.0) + 2.0) * 20.0
            }
            
            uiView.leftAxis.setLabelCount(9, force: true)
                        
//            uiView.animate(yAxisDuration: 1)
        }
        
        else {
            uiView.leftAxis.axisMinimum = 0.0
            uiView.leftAxis.axisMaximum = 1000.0
            
            if(barChartEntrySamples.yMax > 800.0) {
                uiView.leftAxis.axisMaximum = (round(barChartEntrySamples.yMax/100.0) + 2.0) * 100.0
            }
            
            uiView.leftAxis.setLabelCount(11, force: true)
            
//            uiView.animate(yAxisDuration: 1)
        }

        uiView.data = addData()
    }
    
    func addData() -> BarChartData {
        return barChartEntrySamples
    }

    typealias UIViewType = BarChartView
    
}
