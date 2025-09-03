//
//  PrivacyView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        ZStack {
            BgStatusView() {}
            VStack {
                Text("PRIVACY")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Oswald-Regular", size: 20))

                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1.0)

                if (languageCode == "ja") {
                    WebView(url: Bundle.main.url(forResource: "privacy-policy-jap", withExtension:"pdf") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                }
                else {
                    WebView(url: Bundle.main.url(forResource: "PrivacyPolicy", withExtension:"html") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 20)
                        .background(Color(hex:"#FFFFFF"))
                }
                
                Spacer()
            }
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 20)
            .padding(.top, 50)
        }
        .trackRUMView(name: "PrivacyView")
        .navigationBarItems(leading:
            Button(action : {
                self.presentation.wrappedValue.dismiss()
            }){
                HStack {
                    Text("< SETTINGS")
                        .font(.custom("Oswald-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
            }
            .trackRUMTapAction(name: "tap_privacy_back_settings")
        )
    }
}
