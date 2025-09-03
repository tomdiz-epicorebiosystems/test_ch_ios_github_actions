//
//  ActivityLineChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/7/23.
//

import SwiftUI
import Charts
import BLEManager

struct ActivityLineChartView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedExertionElement: ExertionChartData?
    @State private var showLollipop = true
    
    @Binding var exertionSChart: [ExertionChartData]
    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack (spacing: 0) {

            Chart {
                ForEach(exertionSChart.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Hours", exertionSChart[index].timeStamp),
                        y: .value("Today", exertionSChart[index].activityCounts < 17 ? 17 : exertionSChart[index].activityCounts)
                    )
                    .foregroundStyle(Color(hex: generalCHAppColors.exertionTemp))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .foregroundStyle(by: .value("Type", String(localized:"Activity Level")))
            }
            .chartForegroundStyleScale([String(localized:"Activity Level"): Color(hex: generalCHAppColors.exertionTemp)])
            .padding(.leading, languageCode == "ja" ? 35 : 15)
            .padding(.trailing, languageCode == "ja" ? 25 : 15)
            .padding(.vertical, 15)
            .frame(height: 220)
            .chartYScale(domain: [16, 44])
            .chartYAxis(.hidden)
            //.chartYAxis {
            //    AxisMarks(position: .leading, values: stride(from: 16, to: 45, by: 2).map { $0 })
            //}
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
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let elementExertion = findExertionElement(location: value.location, proxy: proxy, geometry: geo)
                                    if selectedExertionElement?.timeStamp == elementExertion?.timeStamp {
                                        // If tapping the same element, clear the selection.
                                        selectedExertionElement = nil
                                    } else {
                                        selectedExertionElement = elementExertion
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedExertionElement = findExertionElement(location: value.location, proxy: proxy, geometry: geo)
                                        }
                                )
                        )
                }
            }
            .chartOverlay { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        if showLollipop, let selectedExertionElement {
                            let dateInterval = Calendar.current.dateInterval(of: .second, for: selectedExertionElement.timeStamp)!
                            let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                            
                            let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                            let lineHeight = geo[proxy.plotAreaFrame].maxY
                            let boxWidth: CGFloat = getLollipopFrameWidth()
                            let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2) - 15)
                            
                            DottedLine()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                .frame(width: 2, height: lineHeight)
                                .position(x: lineX, y: lineHeight / 2)
                                .foregroundColor(Color(hex: generalCHAppColors.intakeChartLollipopColor))

                            HStack(alignment: .center) {
                                Text("\(selectedExertionElement.timeStamp, format: .dateTime.hour().minute())")
                                    .font(.custom("Oswald-Bold", size: 12))
                                    .foregroundColor(.white)
                                    .background {
                                        Capsule()
                                            .fill(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                            .frame(width: 60, height: 80)
                                    }

                                if selectedExertionElement.activityCounts <= 18 {
                                    Text("Very Low")
                                        .foregroundColor(Color(hex: generalCHAppColors.exertionTemp))
                                        .font(.custom("Oswald-Bold", size: 14))
                                        .padding(.leading, 5)

                                }

                                else if selectedExertionElement.activityCounts < 30 {
                                    Text("Light")
                                        .foregroundColor(Color(hex: generalCHAppColors.exertionTemp))
                                        .font(.custom("Oswald-Bold", size: 14))
                                        .padding(.leading, 5)

                                }
                                
                                else if selectedExertionElement.activityCounts < 35 {
                                    Text("Moderate")
                                        .foregroundColor(Color(hex: generalCHAppColors.exertionTemp))
                                        .font(.custom("Oswald-Bold", size: 14))
                                        .padding(.leading, 5)
                                }

                                else {
                                    Text("Intense")
                                        .foregroundColor(Color(hex: generalCHAppColors.exertionTemp))
                                        .font(.custom("Oswald-Bold", size: 14))
                                        .padding(.leading, 5)
                                }

                                Text("Activity Level")
                                    .foregroundColor(Color(hex: generalCHAppColors.exertionTemp))
                                    .font(.custom("Oswald-Regular", size: 12))
                                    .padding(.leading, -5)
                            }
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    self.selectedExertionElement = nil
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
                            .offset(x: boxOffset)
                        }
                    }
                }
            }
            .chartBackground { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        let third = (geo[proxy.plotAreaFrame].size.height / 3)
                        
                        if showHourChartXAxis == true {
                            // RED - High
                            Rectangle()
                                .fill(Color(hex: "#FFD4D4"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: (geo[proxy.plotAreaFrame].size.height / 3) + 5)
                                .offset(x: languageCode == "ja" ? 35 : 15, y: 13)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"INTENSE"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#FF2E2E"))
                                    .font(.custom("Oswald-Regular", size: 10))
                            }
                            .position(x: languageCode == "ja" ? 55 : 42, y: third - 8)

                            // YELLOW - Moderate
                            Rectangle()
                                .fill(Color(hex: "#FFF4D4"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 25)
                                .offset(x: languageCode == "ja" ? 35 : 15, y: (geo[proxy.plotAreaFrame].size.height / 2) - 9)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"MODERATE"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -10)
                            }
                            .position(x: languageCode == "ja" ? 55 : 55, y: (geo[proxy.plotAreaFrame].size.height / 2) + 4)

                            // GREEN - Low
                            Rectangle()
                                .fill(Color(hex: "#E7F1E0"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 55)
                                .offset(x: languageCode == "ja" ? 35 : 15, y: 80)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"LIGHT"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#90BF70"))
                                    .font(.custom("Oswald-Regular", size: 10))
                            }
                            .position(x: languageCode == "ja" ? 45 : 35, y: geo[proxy.plotAreaFrame].size.height - 25)

                            // Grey - inactive
                            Rectangle()
                                .fill(Color(hex: "#D9D9D9"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 11)
                                .offset(x: languageCode == "ja" ? 35 : 15, y: geo[proxy.plotAreaFrame].size.height + 6)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"Very Low"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#AEAEAE"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -10)
                            }
                            .position(x: languageCode == "ja" ? 75 : 50, y: geo[proxy.plotAreaFrame].size.height + 10)
                        }
                        else {
                            // RED - High
                            Rectangle()
                                .fill(Color(hex: "#FFD4D4"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 60)
                                .offset(x: 20, y: 12)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"INTENSE"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#FF2E2E"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    //.offset(x: 20)
                            }
                            .position(x: 40, y: third - 8)
                                                            
                            // YELLOW - Moderate
                            Rectangle()
                                .fill(Color(hex: "#FFF4D4"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 40)
                                .offset(x: 20, y: (geo[proxy.plotAreaFrame].size.height / 2) - 16)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"MODERATE"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -15)
                            }
                            .position(x: languageCode == "ja" ? 40 : 60, y: (geo[proxy.plotAreaFrame].size.height / 2) + 1)
                            
                            // GREEN - Low
                            Rectangle()
                                .fill(Color(hex: "#E7F1E0"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 74)
                                .offset(x: 20, y: geo[proxy.plotAreaFrame].size.height - 73)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"LIGHT"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#90BF70"))
                                    .font(.custom("Oswald-Regular", size: 10))
                            }
                            .position(x: languageCode == "ja" ? 35 : 40, y: geo[proxy.plotAreaFrame].size.height - 40)
                            
                            // Grey - inactive
                            Rectangle()
                                .fill(Color(hex: "#D9D9D9"))
                                .frame(width: geo[proxy.plotAreaFrame].size.width, height: 15)
                                .offset(x: 20, y: geo[proxy.plotAreaFrame].size.height + 1)
                            
                            VStack(spacing: 0) {
                                Text(String(localized:"VERY LOW"))
                                    .padding()
                                    .foregroundColor(Color(hex: "#AEAEAE"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -7)
                            }
                            .position(x: languageCode == "ja" ? 80 : 55, y: geo[proxy.plotAreaFrame].size.height + 9)
                        }
                    }
                }
            }
            
            Spacer()
            
        }
    }
        
    private func findExertionElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ExertionChartData? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for chartDataIndex in exertionSChart.indices {
                let nthChartDataDistance = exertionSChart[chartDataIndex].timeStamp.distance(to: date)
                if abs(nthChartDataDistance) < minDistance {
                    minDistance = abs(nthChartDataDistance)
                    index = chartDataIndex
                }
            }
            if let index {
                return exertionSChart[index]
            }
        }
        return nil
    }
    
    func getLollipopFrameWidth() -> CGFloat {
        var boxWidth: CGFloat = 140.0

        if selectedExertionElement!.activityCounts <= 18 {
            boxWidth += (languageCode == "ja" ? 90.0 : 40.0)
            return boxWidth
        }

        if ((selectedExertionElement!.activityCounts > 18) && (selectedExertionElement!.activityCounts < 30)) {
            boxWidth += 20.0
            return boxWidth
        }
        
        if ((selectedExertionElement!.activityCounts >= 30) && (selectedExertionElement!.activityCounts < 35)) {
            boxWidth += 40.0
            return boxWidth
        }

        if selectedExertionElement!.activityCounts >= 35 {
            boxWidth += 30.0
        }

        return boxWidth
    }
}
