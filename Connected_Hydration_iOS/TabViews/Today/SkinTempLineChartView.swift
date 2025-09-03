//
//  SkinTempLineChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 6/24/24.
//

import SwiftUI
import Charts
import BLEManager

struct SkinTempLineChartView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedSkinTempElement: SkinTempChartData?
    @State private var showLollipop = true
    
    @Binding var skinTempSChart: [SkinTempChartData]
    @Binding var showHourChartXAxis: Bool
    @Binding var showHourChartXCount: Int
    @Binding var showHourChartXTime: Calendar.Component
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack (spacing: 0) {

            Chart {
                ForEach(skinTempSChart.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Hours", skinTempSChart[index].timeStamp),
                        y: .value("Today", modelData.userPrefsData.getUserTemperature(fahrenheit: skinTempSChart[index].bodyTemperatureSkinInF))
                    )
                    .foregroundStyle(Color(hex: generalCHAppColors.skinTemp))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .foregroundStyle(by: .value("Type", String(localized:"Skin Temp") + "(" + modelData.userPrefsData.getUserTempUnitString() + ")"))
            }
            .chartForegroundStyleScale([String(localized:"Skin Temp") + "(" + modelData.userPrefsData.getUserTempUnitString() + ")": Color(hex: generalCHAppColors.skinTemp)])
            .padding(.trailing, languageCode == "ja" ? 25 : 15)
            .padding(.leading, 15)
            .padding(.vertical, 15)
            .frame(height: 220)
            .chartYScale(domain: [(modelData.userPrefsData.useUnits == "1") ? 60 : 20, ((modelData.userPrefsData.useUnits == "1") ? 120 : 60)])
            .chartYAxis {
                AxisMarks(position: .leading, values: stride(from: ((modelData.userPrefsData.useUnits == "1") ? 60 : 20), to: ((modelData.userPrefsData.useUnits == "1") ? 121 : 61), by: ((modelData.userPrefsData.useUnits == "1") ? 20 : 10)).map { $0 })
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
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let elementSkinTemp = findSkinTempElement(location: value.location, proxy: proxy, geometry: geo)
                                    if selectedSkinTempElement?.timeStamp == elementSkinTemp?.timeStamp {
                                        // If tapping the same element, clear the selection.
                                        selectedSkinTempElement = nil
                                    } else {
                                        selectedSkinTempElement = elementSkinTemp
                                    }
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedSkinTempElement = findSkinTempElement(location: value.location, proxy: proxy, geometry: geo)
                                        }
                                )
                        )
                }
            }
            .chartOverlay { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        if showLollipop, let selectedSkinTempElement {
                            let dateInterval = Calendar.current.dateInterval(of: .second, for: selectedSkinTempElement.timeStamp)!
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
                                Text("\(selectedSkinTempElement.timeStamp, format: .dateTime.hour().minute())")
                                    .font(.custom("Oswald-Bold", size: 12))
                                    .foregroundColor(.white)
                                    .background {
                                        Capsule()
                                            .fill(Color(hex: generalCHAppColors.intakeChartLollipopColor))
                                            .frame(width: 60, height: 80)
                                    }

                                Text("\(modelData.userPrefsData.getUserTemperature(fahrenheit: selectedSkinTempElement.bodyTemperatureSkinInF), specifier: "%.1f")")
                                    .foregroundColor(Color(hex: generalCHAppColors.skinTemp))
                                    .font(.custom("Oswald-Bold", size: 14))
                                    .padding(.leading, 5)
                                
                                Text("Skin Temp")
                                    .foregroundColor(Color(hex: generalCHAppColors.skinTemp))
                                    .font(.custom("Oswald-Regular", size: 12))
                                    .padding(.leading, -5)
                            }
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    self.selectedSkinTempElement = nil
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

                        if showHourChartXAxis == true {
                            if (modelData.userPrefsData.useUnits == "1") {
                                // RED - High
                                 Rectangle()
                                     .fill(Color(hex: "#FFD4D4"))
                                     .frame(width: geo[proxy.plotAreaFrame].size.width, height: 65)
                                     .offset(x: 40, y: 12)
                                 
                                 VStack(spacing: 0) {
                                     Text("HIGH")
                                         .padding()
                                         .foregroundColor(Color(hex: "#FF2E2E"))
                                         .font(.custom("Oswald-Regular", size: 10))
                                 }
                                 .position(x: languageCode == "ja" ? 50 : 60, y: (geo[proxy.plotAreaFrame].size.height / 2) - 30)

                                // YELLOW - Moderate
                                Rectangle()
                                    .fill(Color(hex: "#FFF4D4"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: 20)
                                    .offset(x: 40, y: (geo[proxy.plotAreaFrame].size.height / 2) - 3)

                                VStack(spacing: 0) {
                                    Text("MODERATE")
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -10)
                                }
                                .position(x: languageCode == "ja" ? 60 : 80, y: (geo[proxy.plotAreaFrame].size.height / 2) + 8)

                                // GREEN - Low
                                Rectangle()
                                    .fill(Color(hex: "#E7F1E0"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: geo[proxy.plotAreaFrame].size.height - 65)
                                    .offset(x: 40, y: 80)
                                
                                VStack(spacing: 0) {
                                    Text("NORMAL")
                                        .padding()
                                        .foregroundColor(Color(hex: "#90BF70"))
                                        .font(.custom("Oswald-Regular", size: 10))
                                        .offset(x: 6)
                                }
                                .position(x: languageCode == "ja" ? 60 : 60, y: geo[proxy.plotAreaFrame].size.height - 18)
                            }
                            else {
                                // RED - High
                                 Rectangle()
                                     .fill(Color(hex: "#FFD4D4"))
                                     .frame(width: geo[proxy.plotAreaFrame].size.width, height: 78)
                                     .offset(x: 35, y: 10)
                                 
                                 VStack(spacing: 0) {
                                     Text("HIGH")
                                         .padding()
                                         .foregroundColor(Color(hex: "#FF2E2E"))
                                         .font(.custom("Oswald-Regular", size: 10))
                                 }
                                 .position(x: languageCode == "ja" ? 50 : 60, y: (geo[proxy.plotAreaFrame].size.height / 2) - 25)

                                // YELLOW - Moderate
                                Rectangle()
                                    .fill(Color(hex: "#FFF4D4"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: 21)
                                    .offset(x: 35, y: (geo[proxy.plotAreaFrame].size.height / 2) + 22)
                                
                                VStack(spacing: 0) {
                                    Text("MODERATE")
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -10)
                                }
                                .position(x: languageCode == "ja" ? 60 : 80, y: (geo[proxy.plotAreaFrame].size.height / 2) + 33)

                                // GREEN - Low
                                Rectangle()
                                    .fill(Color(hex: "#E7F1E0"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: geo[proxy.plotAreaFrame].size.height - 85)
                                    .offset(x: 35, y: 107)
                                
                                VStack(spacing: 0) {
                                    Text("NORMAL")
                                        .padding()
                                        .foregroundColor(Color(hex: "#90BF70"))
                                        .font(.custom("Oswald-Regular", size: 10))
                                        .offset(x: 6)
                                }
                                .position(x: languageCode == "ja" ? 60 : 60, y: geo[proxy.plotAreaFrame].size.height - 8)
                            }

                        }
                        else {
                            if (modelData.userPrefsData.useUnits == "1") {
                                // RED - High
                                 Rectangle()
                                     .fill(Color(hex: "#FFD4D4"))
                                     .frame(width: geo[proxy.plotAreaFrame].size.width, height: 80)
                                     .offset(x: 40, y: 10)
                                 
                                 VStack(spacing: 0) {
                                     Text("HIGH")
                                         .padding()
                                         .foregroundColor(Color(hex: "#FF2E2E"))
                                         .font(.custom("Oswald-Regular", size: 10))
                                 }
                                 .position(x: 60, y: (geo[proxy.plotAreaFrame].size.height / 2) - 60)

                                // YELLOW - Moderate
                                Rectangle()
                                    .fill(Color(hex: "#FFF4D4"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: 25)
                                    .offset(x: 40, y: (geo[proxy.plotAreaFrame].size.height / 2) - 10)
                                
                                VStack(spacing: 0) {
                                    Text("MODERATE")
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -10)
                                }
                                .position(x: languageCode == "ja" ? 60 : 80, y: (geo[proxy.plotAreaFrame].size.height / 2))

                                // GREEN - Low
                                Rectangle()
                                    .fill(Color(hex: "#E7F1E0"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: 90)
                                    .offset(x: 40, y: 100)

                                VStack(spacing: 0) {
                                    Text("NORMAL")
                                        .padding()
                                        .foregroundColor(Color(hex: "#90BF70"))
                                        .font(.custom("Oswald-Regular", size: 10))
                                        .offset(x: 6)
                                }
                                .position(x: languageCode == "ja" ? 60 : 60, y: geo[proxy.plotAreaFrame].size.height - 30)
                            }
                            else {
                                // RED - High
                                 Rectangle()
                                     .fill(Color(hex: "#FFD4D4"))
                                     .frame(width: geo[proxy.plotAreaFrame].size.width, height: 104)
                                     .offset(x: 40, y: 10)
                                 
                                 VStack(spacing: 0) {
                                     Text("HIGH")
                                         .padding()
                                         .foregroundColor(Color(hex: "#FF2E2E"))
                                         .font(.custom("Oswald-Regular", size: 10))
                                 }
                                 .position(x: 60, y: (geo[proxy.plotAreaFrame].size.height / 2) - 45)

                                // YELLOW - Moderate
                                Rectangle()
                                    .fill(Color(hex: "#FFF4D4"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: 28)
                                    .offset(x: 40, y: (geo[proxy.plotAreaFrame].size.height / 2) + 25)
                                
                                VStack(spacing: 0) {
                                    Text("MODERATE")
                                    .padding()
                                    .foregroundColor(Color(hex: "#FFC103"))
                                    .font(.custom("Oswald-Regular", size: 10))
                                    .offset(x: -12)
                                }
                                .position(x: languageCode == "ja" ? 60 : 80, y: (geo[proxy.plotAreaFrame].size.height / 2) + 39)

                                // GREEN - Low
                                Rectangle()
                                    .fill(Color(hex: "#E7F1E0"))
                                    .frame(width: geo[proxy.plotAreaFrame].size.width, height: geo[proxy.plotAreaFrame].size.height - 122)
                                    .offset(x: 40, y: 137)
                                
                                VStack(spacing: 0) {
                                    Text("NORMAL")
                                        .padding()
                                        .foregroundColor(Color(hex: "#90BF70"))
                                        .font(.custom("Oswald-Regular", size: 10))
                                        .offset(x: 6)
                                }
                                .position(x: languageCode == "ja" ? 60 : 60, y: geo[proxy.plotAreaFrame].size.height - 18)
                            }
                        }
                    }
                }
            }
            
            Spacer()

        }
    }
    
    private func findSkinTempElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> SkinTempChartData? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for chartDataIndex in skinTempSChart.indices {
                let nthChartDataDistance = skinTempSChart[chartDataIndex].timeStamp.distance(to: date)
                if abs(nthChartDataDistance) < minDistance {
                    minDistance = abs(nthChartDataDistance)
                    index = chartDataIndex
                }
            }
            if let index {
                return skinTempSChart[index]
            }
        }
        return nil
    }
        
    func getLollipopFrameWidth() -> CGFloat {
        var boxWidth: CGFloat = languageCode == "ja" ? 180.0 : 140.0
        if selectedSkinTempElement!.bodyTemperatureSkinInF > 100.0 {
            boxWidth += 10.0
            return boxWidth
        }

        return boxWidth
    }
}
