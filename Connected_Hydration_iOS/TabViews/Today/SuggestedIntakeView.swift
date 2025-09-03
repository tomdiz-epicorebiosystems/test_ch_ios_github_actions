//
//  SuggestedIntakeView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 12/5/24.
//

import SwiftUI

struct SuggestedIntakeView: View {

    @EnvironmentObject var modelData: ModelData

    @State var isExpanded = false
    @State var isWaterView = true

    @Binding var tabSelection: Tab

    let fontSizeCountImperial = 4
    let fontSizeCountMetric = 3
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        ZStack {
            VStack {
                Text("SUGGESTED INTAKE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                
                VStack(spacing: -10) {

                    // Top row - title and line
                    HStack {
                        VStack {
                            HStack {
                                Text("WATER (\(modelData.userPrefsData.getUserSweatUnitString()))")
                                    .font(.custom("Oswald-Regular", size: 16))
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                
                                Image("suggested_intake_water")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Rectangle()
                                .fill(Color(hex: generalCHAppColors.grayStandardText))
                                .frame(width: 120, height: 1.0)
                                .padding(.top, -10)
                                .padding(.bottom, -10)
                        }
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("SODIUM (\(modelData.userPrefsData.getUserSodiumUnitString()))")
                                    .font(.custom("Oswald-Regular", size: 16))
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                
                                Image("suggested_intake_sodium")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Rectangle()
                                .fill(Color(hex: generalCHAppColors.grayStandardText))
                                .frame(width: 120, height: 1.0)
                                .padding(.top, -10)
                                .padding(.bottom, -10)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Middle row - intake and icons
                    HStack {
                        Spacer()

                        VStack(spacing: -10) {
                            if (modelData.fluidTotalLossToDisplayInMl != 0 || modelData.fluidTotalIntakeInMl != 0) && (modelData.fluidTotalLossToDisplayInMl - modelData.fluidTotalIntakeInMl < 0) {
                            }
                            else {
                                Text(" ")
                                    .font(.custom("Roboto-Light", size: 9))
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    .padding(.top, 3)
                            }

                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                if modelData.fluidDeficitToDisplayInOz >= 338.14 || (modelData.fluidDeficitToDisplayInMl >= 10000) {
                                    Text(modelData.userPrefsData.getFuildDeficitString())
                                        .font(.custom("TenbyEight", size: modelData.userPrefsData.useUnits == "1" ? 40 : 30))
                                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                                        .onAppear() {
                                            if modelData.showNotification == false {
                                                modelData.notificationData = NotificationModifier.NotificationData(id: maxDeficitIntakeNotification, title: "Warning", detail: modelData.userPrefsData.getFuildDeficitAlertString(), type: .Error, notificationLocation: .Top, showOnce: true, showSeconds: ShowOptions.showClose)
                                                modelData.showNotification = true
                                            }
                                        }
                                }
                                else {
                                    if (modelData.fluidTotalLossToDisplayInMl != 0 || modelData.fluidTotalIntakeInMl != 0) && (modelData.fluidTotalLossToDisplayInMl - modelData.fluidTotalIntakeInMl < 0) {
                                        Image("suggested_intake_drop")
                                    }
                                    else {
                                        Text(modelData.userPrefsData.useUnits == "1" ? modelData.sweatVolumeDeficit : "\(modelData.fluidDeficitToDisplayInMl)")
                                            .font(.custom("TenbyEight", size: modelData.userPrefsData.useUnits == "1" ? (modelData.sweatVolumeDeficit.count > fontSizeCountImperial ? 40 : 48) : ("\(modelData.fluidDeficitToDisplayInMl)".count > fontSizeCountMetric ? 40 : 48)))
                                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                                    }
                                }
                            }
                            else {
                                Text("0.0")
                                    .font(.custom("TenbyEight", size: 48))
                                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            }
                        }
                        .padding(.trailing, 20)

                        Spacer()
                        
                        VStack(spacing: -10) {
                            Text("Adjust per diet")
                                .font(.custom("Roboto-Light", size: 9))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                .padding(.top, 3)

                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
//                                if ((modelData.capSodiumValue != 0) && (modelData.sodiumDeficitToDisplayInMg >= modelData.capSodiumValue)) {
                                if (modelData.sodiumDeficitToDisplayInMg >= 8000) {
//                                    Text("\(modelData.capSodiumValue)+")
//                                        .font(.custom("TenbyEight", size: "\(modelData.capSodiumValue)".count > fontSizeCountMetric ? 40 : 48))
                                    Text("8000+")
                                        .font(.custom("TenbyEight", size: 40))
                                        .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                }
                                else {
                                    Text(modelData.sweatSodiumDeficit)
                                        .font(.custom("TenbyEight", size: modelData.sweatSodiumDeficit.count > fontSizeCountMetric ? 40 : 48))
                                        .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                }
                            }
                            else {
                                Text("0.0")
                                    .font(.custom("TenbyEight", size: 48))
                                    .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                                //.padding(.bottom, 5)
                            }
                        }
                        .padding(.trailing, ((modelData.fluidTotalLossToDisplayInMl != 0 || modelData.fluidTotalIntakeInMl != 0) && (modelData.fluidTotalLossToDisplayInMl - modelData.fluidTotalIntakeInMl < 0)) ? -30 : 0)
                        .padding(.leading, ((modelData.userPrefsData.useUnits == "0") && ("\(modelData.fluidDeficitToDisplayInMl)".count < fontSizeCountMetric))  ? 50 : 20)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Bottom row - lost / consumed
                    HStack {

                        Spacer()

                        VStack {
                            Text("LOST")
                                .font(.custom("Oswald-Light", size: (languageCode == "ja" ? 12 : 14)))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                Text(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.fluidTotalLossToDisplayInMl))))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .font(.custom("TenbyEight", size: "\(modelData.fluidTotalLossToDisplayInMl)".count >= 4 ? 12 : 16))
                                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            }
                            else {
                                Text("0.0")
                                    .font(.custom("TenbyEight", size: 16))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            }
                        }
                        .padding(.trailing, 20)

                        VStack {
                            Text("CONSUMED")
                                .font(.custom("Oswald-Light", size: (languageCode == "ja" ? 12 : 14)))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                Text(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.fluidTotalIntakeInMl))))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                   .font(.custom("TenbyEight", size: "\(modelData.fluidTotalLossToDisplayInMl)".count >= 4 ? 12 : 16))
                                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            }
                            else {
                                Text("0.0")
                                    .font(.custom("TenbyEight", size: 16))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            }
                        }
                        .padding(.trailing, 20)

                        Spacer()

                        VStack {
                            Text("LOST")
                                .font(.custom("Oswald-Light", size: (languageCode == "ja" ? 12 : 14)))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                           if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                               Text(modelData.sweatSodiumTotalLoss)
                                   .font(.custom("TenbyEight", size: "\(modelData.sweatSodiumTotalLoss)".count >= 4 ? 12 : 16))
                                   .lineLimit(1)
                                   .fixedSize(horizontal: true, vertical: false)
                                   .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                            }
                            else {
                                Text("0")
                                    .font(.custom("TenbyEight", size: 16))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                        VStack {
                            Text("CONSUMED")
                                .font(.custom("Oswald-Light", size: (languageCode == "ja" ? 12 : 14)))
                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                            
                            if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                Text(String(modelData.sodiumTotalIntakeInMg))
                                    .font(.custom("TenbyEight", size: "\(modelData.sweatSodiumTotalLoss)".count >= 4 ? 12 : 16))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                             }
                             else {
                                 Text("0")
                                     .font(.custom("TenbyEight", size: 16))
                                     .fixedSize(horizontal: true, vertical: false)
                                     .foregroundColor(Color(hex: chHydrationColors.sodiumFull))
                             }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)

                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Image(modelData.isCHArmBandConnected ? "Today Info Button Blue" : "Today Info Button")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                }   // Main VStack Intake values

                if isExpanded {
                    VStack {

                        HStack {
                            Button(action: {
                                isWaterView = true
                            }) {
                                VStack {
                                    HStack {
                                        Text("WATER (\(modelData.userPrefsData.getUserSweatUnitString()))")
                                            .font(.custom("Oswald-Regular", size: 16))
                                            .foregroundColor(isWaterView ? Color(hex: chHydrationColors.waterFull) : Color(hex: generalCHAppColors.grayStandardText))
                                        
                                        Image("suggested_intake_water")
                                            .renderingMode(.template)
                                            .foregroundColor(isWaterView ?  Color(hex: chHydrationColors.waterFull) : Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Rectangle()
                                        .fill(isWaterView ? Color(hex: chHydrationColors.waterFull) : Color(hex: generalCHAppColors.grayStandardText))
                                        .frame(width: 120, height: 1.0)
                                        .padding(.top, -10)
                                        .padding(.bottom, -10)
                                }
                            }

                            Spacer()
                            
                            Button(action: {
                                isWaterView = false
                            }) {
                                VStack {
                                    HStack {
                                        Text("SODIUM (\(modelData.userPrefsData.getUserSodiumUnitString()))")
                                            .font(.custom("Oswald-Regular", size: 16))
                                            .foregroundColor(!isWaterView ? Color(hex: chHydrationColors.sodiumFull) : Color(hex: generalCHAppColors.grayStandardText))
                                        
                                        Image("suggested_intake_sodium")
                                            .renderingMode(.template)
                                            .foregroundColor(!isWaterView ?  Color(hex: chHydrationColors.sodiumFull) : Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Rectangle()
                                        .fill(!isWaterView ? Color(hex: chHydrationColors.sodiumFull) : Color(hex: generalCHAppColors.grayStandardText))
                                        .frame(width: 120, height: 1.0)
                                        .padding(.top, -10)
                                        .padding(.bottom, -10)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)

                        if self.isWaterView {
                            HStack {
                                Text("\u{00B7}")
                                Text("Consider **pre-hydrating** to get ahead until your next break.")
                                    .font(.custom("Roboto-Regular", size: 10))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 20)

                            HStack {
                                Text("\u{00B7}")
                                Text("However, don’t exceed **6 cups per hour** (1.5L or 48oz) of water intake. This can dilute your body’s sodium balance.")
                                    .font(.custom("Roboto-Regular", size: 10))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 20)


                            HStack(spacing: 10) {
                                if self.isWaterView {
                                    Text(String(localized: "WATER LOSS") + (modelData.passiveWaterLoss ? "*" : ""))
                                        .font(.custom("Oswald-Light", size: 12))
                                        .padding(.top, 15)
                                        .padding(.leading, 13)
                                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))

                                    if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                        Text(self.isWaterView ? String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.fluidTotalLossToDisplayInMl))) : modelData.sweatSodiumTotalLoss)
                                            .font(.custom("TenbyEight", size: 18))
                                            .padding(.top, 15)
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }
                                    else {
                                        Text("0.0")
                                            .font(.custom("TenbyEight", size: 18))
                                            .padding(.top, 15)
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }
 
                                    Text(modelData.userPrefsData.getUserSweatUnitString())
                                        .font(.custom("TenbyEight", size: 12))
                                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                                        .padding(.top, 20)
                                }
                            }
                            .frame(maxWidth: 220, alignment: .bottom)

                            HStack(spacing: 10) {
                                if self.isWaterView {
                                    Text("TRACKED INTAKE")
                                        .font(.custom("Oswald-Light", size: 12))
                                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))

                                    if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                        Text(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f": "%.0f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.fluidTotalIntakeInMl))))
                                            .font(.custom("TenbyEight", size: 18))
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }
                                    else {
                                        Text("0.0")
                                            .font(.custom("TenbyEight", size: 18))
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }

                                    Text(modelData.userPrefsData.getUserSweatUnitString())
                                        .font(.custom("TenbyEight", size: 12))
                                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                                        .padding(.top, 3)
                                }
                            }
                            .frame(maxWidth: 220, alignment: .bottom)

                            Rectangle()
                                .fill(isWaterView ? Color(hex: chHydrationColors.waterFull) : Color(hex: chHydrationColors.sodiumFull))
                                .frame(width: 190, height: 1.0)

                            HStack(spacing: 10) {
                                if self.isWaterView {
                                    Text("SHIFT DEFICIT")
                                        .font(.custom("Oswald-Light", size: 12))
                                        .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                        .padding(.leading, 13)

                                    if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                        Text(modelData.userPrefsData.useUnits == "1" ? String(format: "%.1f", modelData.fluidDeficitToDisplayInOz) : String(format: "%.0f", Double(modelData.fluidDeficitToDisplayInMl)))
                                            .font(.custom("TenbyEight", size: 18))
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }
                                    else {
                                        Text("0.0")
                                            .font(.custom("TenbyEight", size: 18))
                                            .foregroundColor(Color(hex:chHydrationColors.waterFull))
                                    }

                                    Text(modelData.userPrefsData.getUserSweatUnitString())
                                        .font(.custom("TenbyEight", size: 12))
                                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                                        .padding(.top, 3)
                                }
                            }
                            .frame(maxWidth: 220, alignment: .bottom)

                            VStack {
                                if (modelData.passiveWaterLoss) {
                                    if modelData.isUserSessionToDisplay == true && modelData.isCurrentUserSession == true {
                                        if (modelData.fluidTotalLossFromSweatInMl > 0) {
                                            Text("* Sweat loss: **\(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f ": "%.0f ", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.fluidTotalLossFromSweatInMl))))\(modelData.userPrefsData.getUserSweatUnitString())** / Passive loss: **\(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f ": "%.0f ", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.currentTEWLInMl))))\(modelData.userPrefsData.getUserSweatUnitString())**\nPassive loss consists of trans epidermal water loss and\nmetabolic water production to maintain fluid balance during activity.")
                                                .font(.custom("Roboto-Regular", size: 10))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 40)
                                                .padding(.trailing, 40)
                                                .padding(.top, 10)
                                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        else {
                                            Text("* Sweat loss: **\(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f ": "%.0f ", modelData.userPrefsData.handleUserSweatConversion(ml: Double(0.0))))\(modelData.userPrefsData.getUserSweatUnitString())** / Passive loss: **\(String(format: modelData.userPrefsData.useUnits == "1" ? "%.1f ": "%.0f ", modelData.userPrefsData.handleUserSweatConversion(ml: Double(modelData.currentTEWLInMl))))\(modelData.userPrefsData.getUserSweatUnitString())**\nPassive loss consists of trans epidermal water loss and\nmetabolic water production to maintain fluid balance during activity.")
                                                .font(.custom("Roboto-Regular", size: 10))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 40)
                                                .padding(.trailing, 40)
                                                .padding(.top, 10)
                                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    else {
                                        Text("* Sweat loss: **0.0 \(modelData.userPrefsData.getUserSweatUnitString())** / Passive loss: **0.0 \(modelData.userPrefsData.getUserSweatUnitString())**\nPassive loss consists of trans epidermal water loss and\nmetabolic water production to maintain fluid balance during activity.")
                                            .font(.custom("Roboto-Regular", size: 10))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 40)
                                            .padding(.trailing, 40)
                                            .padding(.top, 10)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }

                                Text("Note: Always consult with your physician for any dietary restrictions or medical concerns.")
                                    .font(.custom("Roboto-Bold", size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 40)
                                    .padding(.trailing, 40)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(alignment: .center) {
                                    
                                    Button {
                                        self.tabSelection = .history
                                    } label: {
                                            Text("Intake & Loss History")
                                                .font(.custom("Roboto-Bold", size: 9))
                                                .frame(width: 140, height: 25)
                                                .padding(5)
                                                .foregroundColor(.white)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                    .fill(Color(hex: generalCHAppColors.suggestedIntakeButtonBackground))
                                                )
                                    }

                                    Button {
                                        self.tabSelection = .settings
                                        modelData.suggestIntakeExpandedButtonPressed = true
                                    } label: {
                                            Text("Passive Loss Settings")
                                                .font(.custom("Roboto-Bold", size: 9))
                                                .frame(width: 140, height: 25)
                                                .padding(5)
                                                .foregroundColor(.white)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                    .fill(Color(hex: generalCHAppColors.suggestedIntakeButtonBackground))
                                                )
                                    }

                                }

                                Text("Disclaimer: Connected Hydration is not used for any diagnosis, treatment, or monitoring of a patient or for compensation or alleviation of disease, injury or disability. Users should seek a doctor’s advice before making any medical decisions.")
                                    .font(.custom("Roboto-Bold", size: 10))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 40)
                                    .padding(.trailing, 40)
                                    .padding(.top, 10)
                                    .foregroundColor(Color(hex: generalCHAppColors.suggestedIntakeDisclaimerRed))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                        }
                        else {
                            VStack {
                                HStack {
                                    Text("\u{00B7}")
                                    Text("Rate of sodium loss is determined from your sweat\nmeasurements. Typically your sweat shows: \(modelData.getSweatSodiumString())")
                                        .font(.custom("Roboto-Regular", size: 10))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.black)
                                }
                                .padding(.leading, 20)

                                HStack {
                                    Text("\u{00B7}")
                                    Text("If you are on a unrestricted diet, some of your sodium\ndeficit will be replenished through your food intake.")
                                        .font(.custom("Roboto-Regular", size: 10))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .foregroundColor(.black)
                                }
                                .padding(.leading, 20)
                                .padding(.trailing, 20)

                                Text("Note: Always consult with your physician for any dietary restrictions or medical concerns.")
                                    .font(.custom("Roboto-Bold", size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 40)
                                    .padding(.trailing, 40)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                    .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(alignment: .center) {
                                    
                                    Button {
                                        self.tabSelection = .insights
                                        modelData.suggestIntakeExpandedButtonPressed = true
                                    } label: {
                                        Text("Your Sweat vs. Others")
                                            .font(.custom("Roboto-Bold", size: 9))
                                            .frame(width: 140, height: 25)
                                            .padding(5)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                    .fill(Color(hex: generalCHAppColors.suggestedIntakeButtonBackground))
                                            )
                                    }
                                }

                                Text("Disclaimer: Connected Hydration is not used for any diagnosis, treatment, or monitoring of a patient or for compensation or alleviation of disease, injury or disability. Users should seek a doctor’s advice before making any medical decisions.")
                                    .font(.custom("Roboto-Bold", size: 10))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 40)
                                    .padding(.trailing, 40)
                                    .padding(.top, 10)
                                    .foregroundColor(Color(hex: generalCHAppColors.suggestedIntakeDisclaimerRed))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(!isWaterView ? Color(hex: generalCHAppColors.suggestedIntakeExpandedSodiumBackground) : Color(hex: generalCHAppColors.suggestedIntakeExpandedWaterBackground))

                }

            }
            .frame(height: isExpanded ? (languageCode == "ja" ? (isWaterView ? 740 : 560) : (isWaterView ? 720 : 560)) : 220)
            .background(Color(.white))
            .cornerRadius(7)
            .padding(.top, languageCode == "ja" ? ((modelData.sweatDashboardViewStatus == 1) ? 70 : 50) : 50)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
            Button(action: {
                isExpanded.toggle()
            }) {
                if isExpanded {
                    Image("Today Arrow Up Button")
                }
                else {
                    Image("Today Arrow Down Button")
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: 10)
        }
    }

}
