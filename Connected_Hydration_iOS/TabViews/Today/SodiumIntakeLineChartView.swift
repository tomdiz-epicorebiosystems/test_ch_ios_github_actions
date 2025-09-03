//
//  SodiumIntakeLineChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 1/20/25.
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct SodiumIntakeLineChartView: View {
    
    @EnvironmentObject var modelData: ModelData

    @State private var chartViewHeight = 250.0

    @State private var showLollipop = true
    let lollipopSodiumOffset: CGFloat = -30.0

    @State private var startSessionHour = 0

    @State private var selectedSodiumElement: SweatSodiumSampleChartData?

    @Binding var sweatSodiumSampleSChart: [SweatSodiumSampleChartData]
    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component

    @Binding var chartSodiumYScaleTop: Int
    @Binding var chartSodiumYScaleBottom: Int
    @Binding var chartSodiumYScaleSteps: Int

    // Here are the Sweat/Intake chart gradient values for water and sodium. They run from -1, 0, 1 and map to -80, 0, 80
    let positionForSodiumHydratedColor = -0.01
    let positionForSodiumDehydratedColor = -0.3
    let positionForSweatHydratedColor = -0.01
    let positionForSweatDehydratedColor = -0.3
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack (spacing: 0) {

            Chart {
                ForEach(sweatSodiumSampleSChart.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Seconds", sweatSodiumSampleSChart[index].timeStamp),
                        y: .value("Today", sweatSodiumSampleSChart[index].sweatSodiumDeficitInMg)
                    )
                    .foregroundStyle(Color(hex: chHydrationColors.sodiumFull))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
            }
            .chartLegend(position: .bottom)
            .chartForegroundStyleScale([(modelData.userPrefsData.getUserSodiumUnitString()) : (Color(hex: chHydrationColors.sodiumFull))])
            .padding(.trailing, languageCode == "ja" ? 25 : 15)
            .padding(.leading, 15)
            .padding(.bottom, 15)
            .padding(.top, 5)
            .frame(height: ViewConstants.chartHeight)
            .chartYScale(domain: [chartSodiumYScaleBottom, chartSodiumYScaleTop])
            .chartYAxis {
                AxisMarks(position: .leading, values: stride(from: chartSodiumYScaleBottom, to: chartSodiumYScaleTop+1, by: chartSodiumYScaleSteps).map { $0 })
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
                                    let elementSodium = findSodiumElement(location: value.location, proxy: proxy, geometry: geo)
                                    if selectedSodiumElement?.timeStamp == elementSodium?.timeStamp {
                                        // If tapping the same element, clear the selection.
                                        selectedSodiumElement = nil
                                    } else {
                                        selectedSodiumElement = elementSodium
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedSodiumElement = findSodiumElement(location: value.location, proxy: proxy, geometry: geo)
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
                            .offset(x: 55, y: 5)
                        
                        VStack(spacing: 0) {
                            Text("HYDRATED")
                                .padding()
                                .foregroundColor(Color(hex: generalCHAppColors.intakeChartHydratedtext))
                                .rotationEffect(Angle(degrees: -90))
                                .font(.custom("Jost-Regular", size: 13))
                        }
                        .position(x: 65, y: languageCode == "ja" ? 40 : 40)

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
        boxWidth = 175
        if selectedSodiumElement!.sodiumTotalIntakeInMg > 1000 {
            boxWidth += 10
        }
        return boxWidth
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

}
