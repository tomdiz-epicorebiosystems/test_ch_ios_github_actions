//
//  ModuleSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI
import BLEManager

struct ModuleSettingsView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @AppStorage("replishmentAlert") private var replishmentAlert = true

    var body: some View {

        Text("MODULE")
            .frame(height: settingsSectionGrayHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
            .foregroundColor(.white)
            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))

        VStack
        {
            Toggle("", isOn: $replishmentAlert)
                .padding(5)
                .toggleStyle(
                    ColoredToggleStyle(label: String(localized:"Alert me for every 500 ml of sweat loss. (Recommended)"),
                                       labelFontSize: settingsInfoTextFontSize,
                                       onColor: Color(hex: generalCHAppColors.settingsSliderOnColor),
                                       offColor: .gray,
                                       thumbColor: Color(UIColor.white)))

            Toggle("", isOn: $modelData.passiveWaterLoss)
                .padding(5)
                .onChange(of: modelData.passiveWaterLoss) { value in
                    BLEManager.bleSingleton.setPassiveLossOption(isPassiveLossEnabled: value)
                    BLEManager.bleSingleton.clearHistoricalSweatDataBuffer()
                }
                .toggleStyle(
                    ColoredToggleStyle(label: String(localized:"Include Passive Water Loss"),
                                       labelFontSize: settingsInfoTextFontSize,
                                       onColor: Color(hex: generalCHAppColors.settingsSliderOnColor),
                                       offColor: .gray,
                                       thumbColor: Color(UIColor.white)))

            Toggle("", isOn: $modelData.buttonPressForWaterIntake)
                .padding(5)
                .onChange(of: modelData.buttonPressForWaterIntake) { value in
                    modelData.ebsMonitor.setButtonPressWaterIntakeVolumeInMl()
                }
                .toggleStyle(
                    ColoredToggleStyle(label: String(localized:"Enable Button Press for Water Intake"),
                                       labelFontSize: settingsInfoTextFontSize,
                                       onColor: Color(hex: generalCHAppColors.settingsSliderOnColor),
                                       offColor: .gray,
                                       thumbColor: Color(UIColor.white)))
            
            if modelData.buttonPressForWaterIntake {
                Picker(selection: $modelData.buttonPressWaterIntakeVolumeInMl.onChange(volumeToSetChanged), label: Text("")) {
                    Text(modelData.userPrefsData.useUnits == "1" ? "16.9 oz" : "500 ml").tag(500)
                    Text(modelData.userPrefsData.useUnits == "1" ? "11.2 oz" : "330 ml").tag(330)
                }
                .clipped()
                .onTapGesture {
                    if modelData.buttonPressWaterIntakeVolumeInMl == 500 {
                        modelData.buttonPressWaterIntakeVolumeInMl = 330
                        modelData.userPrefsData.buttonPressWaterIntakeMl = 330
                    }
                    
                    else  {
                        modelData.buttonPressWaterIntakeVolumeInMl = 500
                        modelData.userPrefsData.buttonPressWaterIntakeMl = 500
                    }
                    
                    modelData.ebsMonitor.setButtonPressWaterIntakeVolumeInMl()
                }
                .pickerStyle(.segmented)
                .padding(.trailing, 20)
                .padding(.leading, 20)
                .padding(.bottom, 5)
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .edgesIgnoringSafeArea(.horizontal)

            Button(action: {
                navigate(.push(.settingsSensor))
            })
                {
                    HStack {
                        Text("Sensor Information")
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                            .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                       Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                            .font(.body)
                    }
                    .padding(10)
                }
                .trackRUMTapAction(name: "tap_sensor_info")
        }
        .trackRUMView(name: "ModuleSettingsView")
        .onAppear() {
            modelData.isCHDeviceConnected = BLEManager.bleSingleton.sensorConnected
        }
    }
    
    func volumeToSetChanged(_ tag: Int) {
        //print("tag: \(tag)")
        modelData.buttonPressWaterIntakeVolumeInMl = tag
        modelData.userPrefsData.buttonPressWaterIntakeMl = tag
        modelData.ebsMonitor.setButtonPressWaterIntakeVolumeInMl()
    }
}
