//
//  WaterIntakeLineChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/11/23.
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct WaterIntakeLineChartView: View {

    @EnvironmentObject var modelData: ModelData

    @State private var chartViewHeight = 250.0
    @State private var selectedWaterElement: SweatWaterSampleChartData?
    @State private var showLollipop = true

    @Binding var sweatWaterSampleSChart: [SweatWaterSampleChartData]
    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component

    @Binding var chartYScaleTop: Int
    @Binding var chartYScaleBottom: Int
    @Binding var chartYMetricScaleTop: Int
    @Binding var chartYMetricScaleBottom: Int
    @Binding var chartYScaleSteps: Int
    @Binding var chartYMetricScaleSteps: Int
    @Binding var startSessionHour: Int

    // Here are the Sweat/Intake chart gradient values for water and sodium. They run from -1, 0, 1 and map to -80, 0, 80
    let positionForSodiumHydratedColor = -0.01
    let positionForSodiumDehydratedColor = -0.3
    let positionForSweatHydratedColor = -0.01
    let positionForSweatDehydratedColor = -0.3

    let lollipopWaterOffset: CGFloat = -30.0

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        VStack (spacing: 0) {

            Chart {
                ForEach(sweatWaterSampleSChart.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Seconds", sweatWaterSampleSChart[index].timeStamp),
                        y: .value("Today", modelData.userPrefsData.handleUserSweatConversion(oz: sweatWaterSampleSChart[index].sweatVolumeDeficitInOz))
                    )
                    .foregroundStyle(Color(hex: generalCHAppColors.intakeChartHydratedLineColor))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
            }
            .chartLegend(position: .bottom)
            .chartForegroundStyleScale([(modelData.userPrefsData.getUserSweatUnitString()) : Color(hex: generalCHAppColors.intakeChartHydratedLineColor)])
            .padding(.trailing, languageCode == "ja" ? 25 : 15)
            .padding(.leading, 15)
            .padding(.bottom, 15)
            .padding(.top, 5)
            .frame(height: ViewConstants.chartHeight)
            .chartYScale(domain: [(modelData.userPrefsData.useUnits == "1" ? chartYScaleBottom : chartYMetricScaleBottom), (modelData.userPrefsData.useUnits == "1" ? chartYScaleTop : chartYMetricScaleTop)])
            .chartYAxis {
                AxisMarks(position: .leading, values: stride(from: (modelData.userPrefsData.useUnits == "1" ? chartYScaleBottom : chartYMetricScaleBottom), to: (modelData.userPrefsData.useUnits == "1" ? chartYScaleTop+1 : chartYMetricScaleTop+1), by: (modelData.userPrefsData.useUnits == "1" ? chartYScaleSteps : chartYMetricScaleSteps)).map { $0 })
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
                                    let elementWater = findWaterElement(location: value.location, proxy: proxy, geometry: geo)
                                    if selectedWaterElement?.timeStamp == elementWater?.timeStamp {
                                        // If tapping the same element, clear the selection.
                                        selectedWaterElement = nil
                                    } else {
                                        selectedWaterElement = elementWater
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedWaterElement = findWaterElement(location: value.location, proxy: proxy, geometry: geo)
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
                            .offset(x: (modelData.userPrefsData.useUnits == "1" ? 40 : 55), y: 5)
                        
                        VStack(spacing: 0) {
                            Text("HYDRATED")
                                .padding()
                                .foregroundColor(Color(hex: generalCHAppColors.intakeChartHydratedtext))
                                .rotationEffect(Angle(degrees: -90))
                                .font(.custom("Jost-Regular", size: 13))
                        }
                        .position(x: (modelData.userPrefsData.useUnits == "1" ? 50 : 65), y: languageCode == "ja" ? 40 : 40)
                        
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
                }
            }
            .onAppear() {
                chartViewHeight = 300.0
            }
        }
    }

    private struct ViewConstants {
            static let chartWidth: CGFloat = 300
            static let chartHeight: CGFloat = 220
            static let dataPointWidth: CGFloat = 10
    }

    func getLollipopFrameWidth() -> CGFloat {
        var boxWidth: CGFloat = 200
        boxWidth = 260.0
        
        if modelData.userPrefsData.useUnits == "1" {
            if selectedWaterElement!.fluidTotalIntakeInOz > 100 {
                boxWidth += 10
            }
        }
        else {
            boxWidth += 10
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

}
