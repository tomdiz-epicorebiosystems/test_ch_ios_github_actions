//
//  UserSweatProfileView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/19/24.
//

import SwiftUI

let chartHeight = 20.0

enum SweatConcentrationState {
    case low, medium, high
}

enum SodiumConcentrationState {
    case low, medium, high
}

struct UserSweatProfileView: View {

    @EnvironmentObject var modelData: ModelData

    @State var isExpanded = false

    @State var sodiumConcentrationState = SodiumConcentrationState.low
    @State var sweatConcentrationState = SweatConcentrationState.low

    @State var sweatConcentrationGraph = 0.0
    @State var sodiumConcentrationGraph = 0.0

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        ZStack {
            VStack {
                
                Text("YOUR SWEAT PROFILE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .padding(.leading, 10)
                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                
                SweatLossRate(sweatConcentrationState: $sweatConcentrationState, sweatConcentrationGraph: $sweatConcentrationGraph)

                SodiumConcentration(sodiumConcentrationState: $sodiumConcentrationState, sodiumConcentrationGraph: $sodiumConcentrationGraph)
                
                Spacer()
                
                if isExpanded {
                    ZStack {
                        
                        Rectangle()
                            .fill(Color(hex: generalCHAppColors.insightLtGrayColor))
                            .frame(height: 200.0)
                            .edgesIgnoringSafeArea(.horizontal)

                        VStack {
                            Text("TYPE \(getSweatConcentrationString(state: sweatConcentrationState))/\(getSodiumConcentrationString(state: sodiumConcentrationState))")
                                .font(.custom("Roboto-Black", size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 40)
                                .padding(.bottom, 5)

                            Text(.init(getExplorerYourTypeString(sweat: sweatConcentrationState, sodium: sodiumConcentrationState)))
                                .font(.custom("Roboto-Regular", size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 40)
                                .padding(.trailing, 40)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }

                }
                
            }
            .trackRUMView(name: "UserSweatProfileView")
            .frame(height: isExpanded ? 580 : 380)
            .background(Color(.white))
            .cornerRadius(10)
            .padding(.top, languageCode == "ja" ? ((modelData.sweatDashboardViewStatus == 1) ? 70 : 50) : 50)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .onReceive(self.modelData.$userAvgSweatSodiumConcentrationSuccess) { state in
                if state {
                    let sweatConcentration = modelData.userAvgSweatSodiumConcentration?.data.sweatVolumeMl ?? 0.0
                    // sweat
                    // Low (<=0.6)
                    // Medium (0.6 - 1.8)
                    // High (>1.8)
                    let mlConversionToL = sweatConcentration / 1000

                    sweatConcentrationGraph = scaleSweatLowValue(mlConversionToL)

                    // choride
                    // Low (<= 24)
                    // Medium (24 - 64)
                    // High (>64)
                    let sodiumConcentration = modelData.userAvgSweatSodiumConcentration?.data.sodiumConcentrationMm ?? 0.0

                    sodiumConcentrationGraph = scaleSodiumLowValue(sodiumConcentration)

                    if mlConversionToL <= 0.6 {
                        sweatConcentrationState = .low
                    }
                    else if mlConversionToL > 0.6 && mlConversionToL <= 1.8 {
                        sweatConcentrationState = .medium
                    }
                    else {
                        sweatConcentrationState = .high
                    }

                    if sodiumConcentration <= 24 {
                        sodiumConcentrationState = .low
                    }
                    else if sodiumConcentration > 24 && sodiumConcentration <= 64 {
                        sodiumConcentrationState = .medium
                    }
                    else {
                        sodiumConcentrationState = .high
                    }
                }
            }

            Button(action: {
                isExpanded.toggle()
            }) {
                if isExpanded {
                    languageCode == "ja" ? Image("sweat_profile_down_jp") : Image("sweat_profile_down")
                }
                else {
                    languageCode == "ja" ? Image("sweat_profile_up_jp") : Image("sweat_profile_up")
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: isExpanded ? -180 : 20)
        }
    }
}

// 0.0 - 3.0 (3.1 so doesn't go off chart) to a X position for moving arrow under sweat chart
func scaleSweatLowValue(_ x: Double) -> Double {
    let clamped = min(max(x, 0.0), 3.1)
    
    let barWidth = (UIScreen.main.bounds.width - 40.0) / 3.0 - 7.0
    
    if (clamped <= 0.6) {
        return (clamped / 0.65) * barWidth + 8.0
    }
    
    else if (clamped <= 1.8 ) {
        return barWidth + 2.0 + ((clamped - 0.6) / 1.25 * barWidth) + 4.0
    }
    
    else {
        return 2.0 * barWidth + 4.0 + ((clamped - 1.8) / 1.35 * barWidth) + 2.0
    }
}

// 0 - 120 for sodium values mapped 0 - 360 for chart arrow position
func scaleSodiumLowValue(_ x: Double) -> Double {
    
    let barWidth = (UIScreen.main.bounds.width - 40.0) / 3.0 - 7.0
    let clamped = min(max(x, 0.0), 120.0)
    
    if (clamped <= 24) {
        return (clamped / 26) * barWidth + 8.0
    }
    
    else if (clamped <= 64 ) {
        return barWidth + 2.0 + ((clamped - 24) / 42 * barWidth) + 4.0
    }
    
    else {
        return 2.0 * barWidth + 4.0 + ((clamped - 64) / 58 * barWidth) + 2.0
    }
    
}

func getSweatConcentrationString(state: SweatConcentrationState) -> String {
    switch (state) {
    case .low:
        return String(localized: "LOW")
    case .medium:
        return String(localized: "MEDIUM")
    case .high:
        return String(localized: "HIGH")
    }
}

func getSweatConcentrationColor(state: SweatConcentrationState) -> String {
    switch (state) {
    case .low:
        return chYourSweatProfileColors.waterLow
    case .medium:
        return chYourSweatProfileColors.waterMedium
    case .high:
        return chYourSweatProfileColors.waterHigh
    }
}

func getSodiumConcentrationString(state: SodiumConcentrationState) -> String {
    switch (state) {
    case .low:
        return String(localized: "LOW")
    case .medium:
        return String(localized: "MEDIUM")
    case .high:
        return String(localized: "HIGH")
    }
}

func getSodiumConcentrationColor(state: SodiumConcentrationState) -> String {
    switch (state) {
    case .low:
        return chYourSweatProfileColors.sodiumLow
    case .medium:
        return chYourSweatProfileColors.sodiumMedium
    case .high:
        return chYourSweatProfileColors.sodiumHigh
    }
}

func getExplorerYourTypeString(sweat: SweatConcentrationState, sodium: SodiumConcentrationState) -> String {
    switch (sweat, sodium) {
    case (.low, .low):
        return String(localized: "With a low sweat rate and low sodium concentration, your hydration needs are typically modest. You likely won’t need to replace as much fluid or electrolytes during normal activity as your peers might. Your diet will typically cover your sodium losses, but supplement with electrolytes if needed. Despite a low sweat rate, take care to hydrate throughout the day.")
    case (.low, .medium):
        return String(localized: "Even though you’re not a heavy sweater, your body still may lose a fair amount of sodium on more intense days. While your sodium losses may typically be covered by your diet, consider additional electrolyte supplementation on particularly active days, especially if you start to feel like your energy is draining. Despite a low sweat rate, take care to hydrate throughout the day.")
    case (.low, .high):
        return String(localized: "Despite sweating less than most of your peers, your sweat sodium concentration is high, meaning your total sodium loss can add up quickly. This is especially true on more intense or hotter days. You should consider electrolyte supplementation, even during short sessions of activity. Despite a low sweat rate, take care to hydrate throughout the day.")
    case (.medium, .low):
        return String(localized: "Make sure to rehydrate throughout the day through frequent water intake. Despite a lower concentration of sodium, your moderate sweat rate may result in more sodium loss than you think, especially on more intense or hotter days. Consider electrolyte supplementation if you start to feel particularly drained.")
    case (.medium, .medium):
        return String(localized: "You should aim to replenish fluids and electrolytes at a steady pace throughout your day. A balanced hydration approach of water with occasional electrolytes will serve you well. On more demanding days, increase both your fluid and electrolyte intake to match your increased sweat loss.")
    case (.medium, .high):
        return String(localized: "**You lose a similar amount of water as your peers**, but likely lose more sodium than others. Make sure to stop and hydrate frequently throughout the day, but also make sure you’re getting electrolytes throughout the day. With a higher sodium concentration than your peers, your diet alone is unlikely to replenish all the sodium you lose through sweat.")
    case (.high, .low):
        return String(localized: "Due to your high water loss through sweat, make sure you keep hydration and electrolyte needs a priority each day. Consider pre-hydrating heading into activity, and make sure to rehydrate whenever you get a chance. Despite a low sweat sodium concentration, your high rate of sweat loss can lead to higher sodium losses than you may expect.")
    case (.high, .medium):
        return String(localized: "With high sweat output and medium sodium levels, your fluid and sodium losses are substantial and should be replaced consistently. For you, water alone won’t be enough, and electrolyte supplementation will be key. Your sodium needs likely won’t be met through diet alone. On more intense days, increase your intake of both fluids and electrolytes to keep up.")
    case (.high, .high):
        return String(localized: "Your heavy sweat rate and high sodium concentration makes you one of the highest-risk profiles for dehydration and electrolyte imbalance. Make sure to prioritize both your water and sodium needs at all times. Pay close attention for signs of dehydration or fatigue and **don’t hesitate to take action if you start to feel off**.")
    }
}

struct SweatLossRate: View {

    @EnvironmentObject var modelData: ModelData
    @Binding var sweatConcentrationState: SweatConcentrationState
    @Binding var sweatConcentrationGraph: Double
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 5.0) {
                
                HStack() {
                    Image("sweat_loss_drop")
                    
                    Text("SWEAT LOSS RATE")
                        .font(.custom("Oswald-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                }
                .padding(.leading, 10)
                
                Text(getSweatConcentrationString(state: sweatConcentrationState))
                    .font(.custom("Roboto-Black", size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(hex: getSweatConcentrationColor(state: sweatConcentrationState)))
                    .padding(.leading, 10)
                
                HStack(spacing: 2.0) {
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.waterLow))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("LOW")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.waterMedium))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("MEDIUM")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.waterHigh))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("HIGH")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                }
                
                Image("sweat_profile_arrow")
                    .position(x: (8.5 + sweatConcentrationGraph), y: 5)
            }
        }
    }
}

struct SodiumConcentration: View {

    @EnvironmentObject var modelData: ModelData
    @Binding var sodiumConcentrationState: SodiumConcentrationState
    @Binding var sodiumConcentrationGraph: Double

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 5.0) {
                
                HStack() {
                    Image("suggested_intake_sodium")
                    
                    Text("SODIUM CONCENTRATION")
                        .font(.custom("Oswald-Regular", size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                }
                .padding(.leading, 10)
                
                Text(getSodiumConcentrationString(state: sodiumConcentrationState))
                    .font(.custom("Roboto-Black", size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(hex: getSodiumConcentrationColor(state: sodiumConcentrationState)))
                    .padding(.leading, 10)
                
                HStack(spacing: 2.0) {
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.sodiumLow))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("LOW")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.sodiumMedium))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("MEDIUM")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(hex: chYourSweatProfileColors.sodiumHigh))
                            .frame(width: proxy.size.width / 3.0 - 7.0, height: chartHeight)
                        
                        Text("HIGH")
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    
                }
                
                Image("sweat_profile_arrow")
                    .position(x: 8.5 + sodiumConcentrationGraph, y: 5)
            }
        }
    }
}
