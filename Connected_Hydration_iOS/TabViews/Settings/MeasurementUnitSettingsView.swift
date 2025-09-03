//
//  MeasurementUnitSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 9/7/23.
//

import SwiftUI

struct MeasurementUnitSettingsView: View {

    @EnvironmentObject var modelData: ModelData

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
/*
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color(hex: generalCHAppColors.settingsSliderOnColor))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }
*/
    var body: some View {
        VStack {
            Text("MEASUREMENT UNIT")
                .frame(height: settingsSectionGrayHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
                .foregroundColor(.white)
                .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))

            HStack {
                Text("Unit")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                    .padding(.leading, languageCode == "ja" ? 10 : 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker(selection: $modelData.unitsChanged.onChange(unitsChanged), label: Text("")) {
                    Text("METRIC").tag("0")
                    Text("IMPERIAL").tag("1")
                }
                .frame(width: languageCode == "ja" ? 260 : 200)
                .colorMultiply(Color(hex: generalCHAppColors.settingsSliderOnColor))
                .clipped()
                .onTapGesture {
                    if modelData.unitsChanged == "0" {
                        modelData.unitsChanged = "1"

                        modelData.userPrefsData.useUnits = "1"
                        logger.info("units", attributes: ["unit": "imperial"])
                        if (languageCode == "ja") {
                            modelData.bottle_list = load("preset_bottle_list_jap.json")
                        }
                        else {
                            modelData.bottle_list = load("preset_bottle_list.json")
                        }
                        
                    } else {
                        modelData.unitsChanged = "0"
                        
                        modelData.userPrefsData.useUnits = "0"
                        logger.info("units", attributes: ["unit": "metrics"])
                        if (languageCode == "ja") {
                            modelData.bottle_list = load("preset_bottle_list_jap.json")
                        }
                        else {
                            modelData.bottle_list = load("preset_bottle_list_metric.json")
                        }
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.bottom, 10)
        }
        .trackRUMView(name: "MeasurementUnitSettingsView")
    }
    
    func unitsChanged(_ tag: String) {
        //print("tag: \(tag)")
        modelData.unitsChanged = tag
        modelData.userPrefsData.useUnits = tag

        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

        if modelData.userPrefsData.useUnits == "1" {
            logger.info("units", attributes: ["unit": "imperial"])
            if (languageCode == "ja") {
                modelData.bottle_list = load("preset_bottle_list_jap.json")
            }
            else {
                modelData.bottle_list = load("preset_bottle_list.json")
            }
        }
        else {
            logger.info("units", attributes: ["unit": "metrics"])
            if (languageCode == "ja") {
                modelData.bottle_list = load("preset_bottle_list_jap.json")
            }
            else {
                modelData.bottle_list = load("preset_bottle_list_metric.json")
            }
        }
    }
}
