//
//  SweatIntakeLineChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/11/23.
//

import SwiftUI
import Charts
import BLEManager

struct WaterIntakeLineChartView: View {

    @EnvironmentObject var modelData: ModelData

    @State var sweatElectrolyteDisplaySelection: Int = 0
    @State var notificationSweatHistoricalDataLogDownloadComplete: Any? = nil
    @State var sweatWaterSampleSChart: [SweatWaterSampleChartData] = []
    @State var sweatSodiumSampleSChart: [SweatSodiumSampleChartData] = []
    @State private var chartViewHeight = 250.0

    @State private var selectedWaterElement: SweatWaterSampleChartData?
    @State private var selectedSodiumElement: SweatSodiumSampleChartData?
    @State private var showLollipop = true
    let lollipopWaterOffset: CGFloat = -30.0
    let lollipopSodiumOffset: CGFloat = -30.0
    @State private var chartYScaleTop = 40
    @State private var chartYScaleBottom = -40
    @State private var chartYMetricScaleTop = 1250
    @State private var chartYMetricScaleBottom = -1250
    @State private var chartSodiumYScaleTop = 1000
    @State private var chartSodiumYScaleBottom = -1000
    
    @State private var chartYScaleSteps = 10
    @State private var chartYMetricScaleSteps = 250
    @State private var chartSodiumYScaleSteps = 200

    @State private var startSessionHour = 0

    @Binding var skinTempSChart: [SkinTempChartData]
    @Binding var exertionSChart: [ExertionChartData]
    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component

    // Here are the Sweat/Intake chart gradient values for water and sodium. They run from -1, 0, 1 and map to -80, 0, 80
    let positionForSodiumHydratedColor = -0.01
    let positionForSodiumDehydratedColor = -0.3
    let positionForSweatHydratedColor = -0.01
    let positionForSweatDehydratedColor = -0.3

    // Custom binding for the `selection`
    var binding: Binding<Int> {
        .init(get: {
            sweatElectrolyteDisplaySelection
        }, set: {
            sweatElectrolyteDisplaySelection = $0
            updateHistoricalSweatDataPlot(isUpdate: false)
        })
    }

    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("SWEAT / INTAKE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .padding(.top, 10)
                    .padding(.leading, 20)
                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))

                Spacer()

                Picker("", selection: binding) {
                    Text("WATER").tag(0)
                    Text("SODIUM").tag(1)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .padding(.top, 10)
                .padding(.trailing, 5)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)

            Chart {
                if sweatElectrolyteDisplaySelection == 0 {
                    
                    //let atRiskLevelPercentageOnPlot = Double(BLEManager.bleSingleton.subjectWeightInKg) * 0.338 / Double(chartYScaleBottom)
                    //let atRiskLevelPositionOnPlot = (1.0 + atRiskLevelPercentageOnPlot) / 2.0
                    //let dehydratedLevelPositionONPlot = (1.0 + atRiskLevelPercentageOnPlot * 2.0) / 2.0
                    
                    ForEach(sweatWaterSampleSChart.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Seconds", sweatWaterSampleSChart[index].timeStamp),
                            y: .value("Today", modelData.userPrefsData.handleUserSweatConversion(oz: sweatWaterSampleSChart[index].sweatVolumeDeficitInOz))
                        )
                        .foregroundStyle(Color(hex: generalCHAppColors.intakeChartHydratedLineColor))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        //.interpolationMethod(.catmullRom)
                        // TODO: Revisit the color change with sweat loss later.
//                                .foregroundStyle(
//                                    .linearGradient(
//                                        Gradient(
//                                            stops: [
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartDehydratedLineColor), location: 0.0),
//
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartDehydratedLineColor), location: dehydratedLevelPositionONPlot),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartMidPointLineColor), location: dehydratedLevelPositionONPlot + 0.001),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartMidPointLineColor), location: atRiskLevelPositionOnPlot),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartHydratedLineColor), location: atRiskLevelPositionOnPlot + 0.001),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartHydratedLineColor), location: 0.5)
//
////                                                .init(color: .blue, location: 0.0),
////                                                .init(color: .blue, location: 0.001),
////                                                .init(color: .blue, location: 0.5),
////                                                .init(color: .green, location: 0.5001),
////                                                .init(color: .green, location: 0.75),
////                                                .init(color: .red, location: 0.751),
////                                                .init(color: .red, location: 1.0)
//                                        ]),
//                                        startPoint: .bottom,
//                                        endPoint: .top)
//                                )
                    }
//                            .foregroundStyle(by: .value("Type", modelData.userPrefsData.getUserSweatUnitString()))
                }
                else {
                    ForEach(sweatSodiumSampleSChart.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Seconds", sweatSodiumSampleSChart[index].timeStamp),
                            y: .value("Today", sweatSodiumSampleSChart[index].sweatSodiumDeficitInMg)
                        )
                        .foregroundStyle(Color(hex: chHydrationColors.sodiumFull))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        //.interpolationMethod(.catmullRom)
//                                .foregroundStyle(
//                                    .linearGradient(
//                                        Gradient(
//                                            stops: [
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartDehydratedLineColor), location: -1.0),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartDehydratedLineColor), location: positionForSodiumDehydratedColor),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartMidPointLineColor), location: positionForSodiumDehydratedColor + 0.001),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartMidPointLineColor), location: positionForSodiumHydratedColor),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartHydratedLineColor), location: positionForSodiumHydratedColor + 0.001),
//                                                .init(color: Color(hex: generalCHAppColors.intakeChartHydratedLineColor), location: 1),
//                                        ]),
//                                        startPoint: .bottom,
//                                        endPoint: .top)
//                                )
                    }
//                            .foregroundStyle(by: .value("Type", modelData.userPrefsData.getUserSodiumUnitString()))
                }
            }
            .chartLegend(position: .bottom)
            .chartForegroundStyleScale([(sweatElectrolyteDisplaySelection == 0 ? modelData.userPrefsData.getUserSweatUnitString() : modelData.userPrefsData.getUserSodiumUnitString()): (sweatElectrolyteDisplaySelection == 0 ? Color(hex: generalCHAppColors.intakeChartHydratedLineColor) : Color(hex: chHydrationColors.sodiumFull))])
            .padding(15)
            .frame(height: ViewConstants.chartHeight)
        
            .chartYScale(domain: [sweatElectrolyteDisplaySelection == 0 ? (modelData.userPrefsData.useUnits == "1" ? chartYScaleBottom : chartYMetricScaleBottom) : chartSodiumYScaleBottom, sweatElectrolyteDisplaySelection == 0 ? (modelData.userPrefsData.useUnits == "1" ? chartYScaleTop : chartYMetricScaleTop) : chartSodiumYScaleTop])
        
            .chartYAxis {
                if sweatElectrolyteDisplaySelection == 0 {
                    AxisMarks(position: .leading, values: stride(from: (modelData.userPrefsData.useUnits == "1" ? chartYScaleBottom : chartYMetricScaleBottom), to: (modelData.userPrefsData.useUnits == "1" ? chartYScaleTop+1 : chartYMetricScaleTop+1), by: (modelData.userPrefsData.useUnits == "1" ? chartYScaleSteps : chartYMetricScaleSteps)).map { $0 })
                }
                else {
                    AxisMarks(position: .leading, values: stride(from: chartSodiumYScaleBottom, to: chartSodiumYScaleTop+1, by: chartSodiumYScaleSteps).map { $0 })
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .leading) {
                Text("Session Started: \(getChartSessionSessionStart())")
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: showHourChartXTime, count: showHourChartXCount, roundUpperBound: true)) { value in
                    if let date = value.as(Date.self) {
                        if showHourChartXAxis == true {
                            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        }
                        else {
                            AxisValueLabel {
                                HStack {
                                    Text(date, format: .dateTime.minute())
                                        .padding(.trailing, -7)
                                    Text("min")
                                }
                            }
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    if sweatElectrolyteDisplaySelection == 0 {
                                        let elementWater = findWaterElement(location: value.location, proxy: proxy, geometry: geo)
                                        if selectedWaterElement?.timeStamp == elementWater?.timeStamp {
                                            // If tapping the same element, clear the selection.
                                            selectedWaterElement = nil
                                        } else {
                                            selectedWaterElement = elementWater
                                        }
                                    }
                                    else {
                                        let elementSodium = findSodiumElement(location: value.location, proxy: proxy, geometry: geo)
                                        if selectedSodiumElement?.timeStamp == elementSodium?.timeStamp {
                                            // If tapping the same element, clear the selection.
                                            selectedSodiumElement = nil
                                        } else {
                                            selectedSodiumElement = elementSodium
                                        }
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            if sweatElectrolyteDisplaySelection == 0 {
                                                selectedWaterElement = findWaterElement(location: value.location, proxy: proxy, geometry: geo)
                                            }
                                            else {
                                                selectedSodiumElement = findSodiumElement(location: value.location, proxy: proxy, geometry: geo)
                                            }
                                        }
                                )
                        )
                }
            }
            .chartBackground { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        
                        Rectangle()
                            .fill(Color(hex: generalCHAppColors.intakeChartRectMark))
                            .frame(width: geo[proxy.plotAreaFrame].size.width, height: geo[proxy.plotAreaFrame].size.height / 2)
                            .offset(x: sweatElectrolyteDisplaySelection == 0 ? (modelData.userPrefsData.useUnits == "1" ? 40 : 55) : 55, y: 15)
                        
                        VStack(spacing: 0) {
                            Text("HYDRATED")
                                .padding()
                                .foregroundColor(Color(hex: generalCHAppColors.intakeChartHydratedtext))
                                .rotationEffect(Angle(degrees: -90))
                                .font(.custom("Jost-Regular", size: 15))
                        }
                        .position(x: sweatElectrolyteDisplaySelection == 0 ? (modelData.userPrefsData.useUnits == "1" ? 50 : 65) : 65, y: 55)
                        
                        if sweatElectrolyteDisplaySelection == 0 {
                            if showLollipop, let selectedWaterElement {
                                let dateInterval = Calendar.current.dateInterval(of: .second, for: selectedWaterElement.timeStamp)!
                                let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                                
                                let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                                let lineHeight = geo[proxy.plotAreaFrame].maxY
                                let boxWidth = getLollipopFrameWidth()
                                let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2) - 15)
                                
                                DottedLine()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                    .frame(width: 2, height: lineHeight)
                                    .position(x: lineX, y: lineHeight / 2)
                                    .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))

                                HStack(alignment: .center) {
                                    Text("\(selectedWaterElement.timeStamp, format: .dateTime.hour().minute())")
                                        .font(.custom("Oswald-Bold", size: 12))
                                        .foregroundColor(.white)
                                        .background {
                                            Capsule()
                                                .fill(Color(hex: generalCHAppColors.intakeChartHydratedLineColor))
                                                .frame(width: 60, height: 80)
                                        }
                                    
                                    Text("\(modelData.userPrefsData.handleUserSweatConversion(oz: Double(selectedWaterElement.sweatVolumeTotalLossInOz)), specifier: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f")")
                                        .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                        .font(.custom("Oswald-Bold", size: 12))
                                        .padding(.leading, 5)
                                    Text("SWEAT LOSS")
                                        .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                        .font(.custom("Oswald-Regular", size: 12))
                                        .padding(.leading, -5)
                                    Text(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f", modelData.userPrefsData.handleUserSweatConversion(oz: Double(selectedWaterElement.fluidTotalIntakeInOz))))
                                        .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                        .font(.custom("Oswald-Bold", size: 12))
                                        .padding(.leading, 5)
                                    Text("WATER CONSUMED")
                                        .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                        .font(.custom("Oswald-Regular", size: 12))
                                        .padding(.leading, -5)
                                }
                                .onAppear() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        self.selectedWaterElement = nil
                                    }
                                }
                                .frame(width: boxWidth, alignment: .leading)
                                .frame(height: 10)
                                .padding(5)
                                .background(Color(.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: generalCHAppColors.intakeChartLollipopColor), lineWidth: 3)
                                )
                                .cornerRadius(15)
                                .shadow(radius: 10, y: 15)
                                .offset(x: boxOffset, y: lollipopWaterOffset)
                            }
                        }
                        else {
                            if showLollipop,
                               let selectedSodiumElement {
                                let dateInterval = Calendar.current.dateInterval(of: .second, for: selectedSodiumElement.timeStamp)!
                                let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                                
                                let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                                let lineHeight = geo[proxy.plotAreaFrame].maxY
                                let boxWidth = getLollipopFrameWidth()
                                let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2) - 15)
                                
                                DottedLine()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                    .frame(width: 2, height: lineHeight)
                                    .position(x: lineX, y: lineHeight / 2)
                                    .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))

                                HStack(alignment: .center) {
                                    Text("\(selectedSodiumElement.timeStamp, format: .dateTime.hour().minute())")
                                        .font(.custom("Oswald-Bold", size: 12))
                                        .foregroundColor(.white)
                                        .background {
                                            Capsule()
                                                .fill(Color(hex: chHydrationColors.sodiumFull))
                                                .frame(width: 60, height: 100)
                                        }
                                    
                                    VStack {
                                        HStack {
                                            Text("\(selectedSodiumElement.sweatSodiumTotalLossInMg, format: .number)")
                                                .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                                .font(.custom("Oswald-Bold", size: 12))
                                                .padding(.leading, 5)
                                            Text("SODIUM LOSS")
                                                .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                                .font(.custom("Oswald-Regular", size: 12))
                                                .padding(.leading, -5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        HStack {
                                            Text("\(selectedSodiumElement.sodiumTotalIntakeInMg, format: .number)")
                                                .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                                .font(.custom("Oswald-Bold", size: 12))
                                                .padding(.leading, 5)
                                            Text("SODIUM CONSUMED")
                                                .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                                .font(.custom("Oswald-Regular", size: 12))
                                                .padding(.leading, -5)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .onAppear() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        self.selectedSodiumElement = nil
                                    }
                                }
                                .frame(width: boxWidth, alignment: .leading)
                                .frame(height: 35)
                                .padding(5)
                                .background(Color(.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: chHydrationColors.sodiumFull), lineWidth: 3)
                                )
                                .cornerRadius(15)
                                .shadow(radius: 10, y: 15)
                                .offset(x: boxOffset, y: lollipopSodiumOffset)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                chartViewHeight = 300.0
            }
        }
        .trackRUMView(name: "SweatIntakeLineChartView")
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: chartViewHeight)
        .background(Color(.white))
        .cornerRadius(10)
        .padding(.top, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .onAppear() {
            
            if(notificationSweatHistoricalDataLogDownloadComplete == nil) {
                print("**** Started monitoring historical data")
                notificationSweatHistoricalDataLogDownloadComplete = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatHistoricalDataLogDownloadComplete), object: nil, queue: OperationQueue.main) { notification in self.updateHistoricalSweatDataPlot(isUpdate: true)
                }
            }
            
        }
    }

    private struct ViewConstants {
            static let chartWidth: CGFloat = 350
            static let chartHeight: CGFloat = 260
            static let dataPointWidth: CGFloat = 10
    }

    func getLollipopFrameWidth() -> CGFloat {
        var boxWidth: CGFloat = 200
        if sweatElectrolyteDisplaySelection == 0 {
            // water
            boxWidth = 260.0
            
            if modelData.userPrefsData.useUnits == "1" {
                if selectedWaterElement!.fluidTotalIntakeInOz > 100 {
                    boxWidth += 10
                }
            }
            else {
                boxWidth += 10
            }
            
        }
        else {
            // sodium
            boxWidth = 175
            if selectedSodiumElement!.sodiumTotalIntakeInMg > 1000 {
                boxWidth += 10
            }
            //if selectedSodiumElement.sweatSodiumDeficitInMg > 1000.0 {
            //    boxWidth += 10
            //}
        }
        return boxWidth
    }

    private func findWaterElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> SweatWaterSampleChartData? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for chartDataIndex in sweatWaterSampleSChart.indices {
                let nthChartDataDistance = sweatWaterSampleSChart[chartDataIndex].timeStamp.distance(to: date)
                if abs(nthChartDataDistance) < minDistance {
                    minDistance = abs(nthChartDataDistance)
                    index = chartDataIndex
                }
            }
            if let index {
                return sweatWaterSampleSChart[index]
            }
        }
        return nil
    }

    private func findSodiumElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> SweatSodiumSampleChartData? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for chartDataIndex in sweatSodiumSampleSChart.indices {
                let nthChartDataDistance = sweatSodiumSampleSChart[chartDataIndex].timeStamp.distance(to: date)
                if abs(nthChartDataDistance) < minDistance {
                    minDistance = abs(nthChartDataDistance)
                    index = chartDataIndex
                }
            }
            if let index {
                return sweatSodiumSampleSChart[index]
            }
        }
        return nil
    }

    // Brief: Method to display historical sweat data on the appropriate LineChart object
    func updateHistoricalSweatDataPlot(isUpdate: Bool) {
        /**** Functional Code ****/

        let hydrationHistoricalData = BLEManager.bleSingleton.getHydrationHistoricalData()

        skinTempSChart.removeAll()
        exertionSChart.removeAll()
        sweatWaterSampleSChart.removeAll()
        sweatSodiumSampleSChart.removeAll()

        if hydrationHistoricalData.count == 0 {
            return
        }

        DispatchQueue.global(qos: .background).sync {
            var currentFluidIntake = 0.0
            var currentSodiumIntake: UInt16 = 0
            var previousTimeStamp: UInt16 = 0
            
            chartYMetricScaleTop = 1250
            chartYMetricScaleBottom = -1250
            chartYMetricScaleSteps = 250
            chartYScaleTop = 40
            chartYScaleBottom = -40
            chartYScaleSteps = 10
            
            chartSodiumYScaleTop = 1000
            chartSodiumYScaleBottom = -1000
            chartSodiumYScaleSteps = 200
            
            var chartYWaterMax = 0.0
            var chartYWaterMin = 0.0
            var chartSodiumYDeficitMax = 0.0
            var chartSodiumYDeficitMin = 0.0
                            
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
                    if(sweatElectrolyteDisplaySelection == 0) {
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
                                                    
                    }
                        
                    else {
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
        }

        sweatWaterSampleSChart = sweatWaterSampleSChart.sorted(by: { $0.timeStamp.compare($1.timeStamp) == .orderedAscending })
        sweatSodiumSampleSChart = sweatSodiumSampleSChart.sorted(by: { $0.timeStamp.compare($1.timeStamp) == .orderedAscending })
        
        modelData.historicalSweatDataDownloadCompleted = true
    }

}
