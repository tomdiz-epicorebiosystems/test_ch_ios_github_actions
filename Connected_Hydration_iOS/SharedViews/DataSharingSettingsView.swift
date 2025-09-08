//
//  DataSharingSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/24/23.
//

import SwiftUI

struct DataSharingSettingsView: View {

    @EnvironmentObject var modelData: ModelData

    var showHeading: Bool

    var body: some View {
        if showHeading {
            Text("DATA SHARING")
                .frame(height: settingsSectionGrayHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
                .foregroundColor(.white)
                .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
        }

        Toggle("", isOn: $modelData.shareAnonymousDataEnterprise)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .toggleStyle(
                ColoredToggleStyle(label: String(localized:"Share anonymous data with") + " " + modelData.CH_EnterpriseName + " " + String(localized:"occupational hygienists / medical staff  (for safety)"),
                                   labelFontSize: settingsInfoTextFontSize,
                                   onColor: Color(hex: generalCHAppColors.settingsSliderOnColor),
                                   offColor: .gray,
                                   thumbColor: Color(UIColor.white),
                                   isShowHeading: showHeading)
                )
        
        if showHeading {
            Toggle("", isOn: $modelData.shareAnonymousDataEpicore)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .toggleStyle(
                    ColoredToggleStyle(label: String(localized:"Share anonymous data with Epicore\nBiosystems"),
                                       labelFontSize: settingsInfoTextFontSize,
                                       onColor: Color(hex: generalCHAppColors.settingsSliderOnColor),
                                       offColor: .gray,
                                       thumbColor: Color(UIColor.white)))
            
            Text("Unchecking this will disable historical views, insights,\nand preparation & recovery suggestions")
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(.leading, 20)
                .font(.custom("Roboto-Regular", size: settingsHeaderTextFontSize - 4))
        }
    }
}
