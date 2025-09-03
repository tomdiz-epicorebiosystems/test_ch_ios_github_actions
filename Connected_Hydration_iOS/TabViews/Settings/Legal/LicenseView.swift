//
//  LicenseView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/14/23.
//

import SwiftUI

struct LicenseView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack {
            BgStatusView() {}
            VStack {
                Text("LICENSE")
                    .foregroundColor(Color.gray)
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Oswald-SemiBold", size: settingsTitleFontSize))

                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1.0)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        LicenseTextView()
                    }
                    .padding(.bottom, 10)
                }
                .clipped()
            }
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 60)
            .padding(.top, 50)
        }
        .trackRUMView(name: "LicenseView")
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading:
            Button(action : {
                self.presentation.wrappedValue.dismiss()
            }){
                HStack {
                    Text("< LEGAL &\n REGULATORY")
                        .font(.custom("Oswald-Regular", size: 12))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
            }
            .trackRUMTapAction(name: "tap_back_license_view")
        )
    }
}

struct LicenseTextView: View {
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        Text("Legal Notices")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("Epicore Biosystems are registered trademarks of Epicore Biosystems, Inc. Connected Hydration is a trademark of Epicore Biosystems, Inc.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("Font Licenses")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("Orbitron is a font face created by the League of Moveable Type. Licensed under the Open Font License v1.1.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        Text("Oswald is a font face created by Vernon Adams. Licensed under the Open Font License.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        MoreLicenseView()
    }
}

struct MoreLicenseView: View {
    var body: some View {
        Text("Roboto is a font face created by Christian Robertson. Licensed under Apache License, v2.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        Text("Tenby-Eight and Tenby-Eight Light are fonts created by Jan Schmoeger of Paragraph Font Foundry. This set of fonts have been specially licensed for use in all versions or updates of the mobile app without user number or time limits.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}
