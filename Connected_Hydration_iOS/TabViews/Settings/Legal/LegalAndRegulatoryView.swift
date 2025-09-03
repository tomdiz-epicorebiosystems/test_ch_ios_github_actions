//
//  LegalAndRegulatoryView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI

struct LegalAndRegulatoryView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack {
            BgStatusView() {}
            VStack {
                Text("LEGAL & REGULATORY")
                    .foregroundColor(Color.gray)
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Oswald-SemiBold", size: settingsTitleFontSize))
                        
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                
                        ConnectedHydrationView()
                        
                        Text("REGULATORY CERTIFICATION")
                            .frame(height: settingsSectionGrayHeight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                            .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
                            .foregroundColor(.white)
                            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                        
                        HStack {
                            Text("Model")
                                .font(.custom("Roboto-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                                .padding(.leading, 20)
                                .padding(.trailing, 5)
                            Text("ASY-0215")
                                .font(.custom("RobotoCondensed-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                                .padding(.leading, -25)
                        }
                        .padding(.top, 20)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1.0)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .edgesIgnoringSafeArea(.horizontal)
                        
                        FCCLocalView()
                        
                        VStack {
                            Text("810 Memorial Drive Suite 100")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex: "#818385"))
                            Text("Cambridge, MA 02139")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex: "#818385"))
                            Text("USA")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(hex: "#818385"))
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        Spacer()
                    }
                    
                }
            }
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 60)
            .padding(.top, 50)
        }
        .trackRUMView(name: "LegalAndRegulatoryView")
        .toolbar(.hidden, for: .tabBar)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("", displayMode: .inline)
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
            .trackRUMTapAction(name: "tap_legal_view_back_settings")
        )

    }
}

struct FCCLocalView: View {
        
    var body: some View {
        VStack {
            HStack {
                Text("United States")
                    .font(.custom("Roboto-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .padding(.leading, 20)
                    .padding(.trailing, 5)
                Text("FCC ID: 2BANDCHASY0215")
                    .font(.custom("RobotoCondensed-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .padding(.leading, -25)
            }
            .padding(.top, 20)

            Image("FCC Logo")
                .frame(width: 80, height: 60)
                .padding(5)
        }
        .frame(height:110)

        DividerView()

        HStack {
            Text("Canada")
                .font(.custom("Roboto-Regular", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(.leading, 20)
                .padding(.trailing, 5)

            Text("IC: 31273-CHASY0215")
                .font(.custom("RobotoCondensed-Regular", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(.leading, -25)
        }
        .frame(height: 50)

        DividerView()
    }
}

struct DividerView: View {

    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(height: 1.0)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct ConnectedHydrationView: View {

    @State private var isCompliancePresented = false
    @State private var isLicensePresented = false

    var body: some View {
        Text("CONNECTED HYDRATION")
            .frame(height: settingsSectionGrayHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
            .foregroundColor(.white)
            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))

        Button(action: {
            self.isCompliancePresented = true
        }) {
            HStack {
                Text("Compliance")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                    .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
            }
            .padding(20)
        }
        .trackRUMTapAction(name: "tap_compliance")

        DividerView()

        Button(action: {
            self.isLicensePresented = true
        }) {
            HStack {
                Text("License")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                    .font(.custom("Roboto-Bold", size: settingsInfoTextFontSize))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
            }
            .padding(20)
        }
        .trackRUMTapAction(name: "tap_license")
        .navigationDestination(isPresented: $isCompliancePresented) {
            ComplianceView().navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $isLicensePresented) {
            LicenseView().navigationBarBackButtonHidden(true)
        }
    }
}
