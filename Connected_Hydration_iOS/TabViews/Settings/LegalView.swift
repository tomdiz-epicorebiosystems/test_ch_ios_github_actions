//
//  LegalRegulatoryView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI

struct LegalView: View {

    let agreements: [LocalizedStringKey] = ["Legal & Regulatory", "Terms & Conditions", "Privacy Policy"]

    @Environment(\.navigate) private var navigate

    var body: some View {

        Text("TERMS, LEGAL & REGULATORY")
            .frame(height: settingsSectionGrayHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
            .foregroundColor(.white)
            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))

        VStack {

            Button(action: {
                navigate(.push(.settingsLegal))
            }) {
                HStack {
                    Text(agreements[0])
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                        .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                .padding(10)
            }
            .trackRUMTapAction(name: "tap_legal_reg_view")

            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .edgesIgnoringSafeArea(.horizontal)
            
            Button(action: {
                navigate(.push(.settingsTerms))
            }) {
                HStack {
                    Text(agreements[1])
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                        .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                        .font(.body)
                }
                .padding(10)
            }
            .trackRUMTapAction(name: "tap_terms_view")

            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .edgesIgnoringSafeArea(.horizontal)
            
            Button(action: {
                navigate(.push(.settingsPrivacy))
            }) {
                HStack {
                    Text(agreements[2])
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                        .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                        .font(.body)
                }
                .padding(10)
            }
            .trackRUMTapAction(name: "tap_privacy_view")

            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .edgesIgnoringSafeArea(.horizontal)
            
        }
        .trackRUMView(name: "LegalRegulatoryView")
    }
}
