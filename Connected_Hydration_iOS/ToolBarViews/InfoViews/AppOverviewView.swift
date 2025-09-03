//
//  AppOverviewView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct AppOverviewView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen
    @Binding var isAppOverviewPresented: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Text("APP OVERVIEW")
                    .font(.custom("Oswald-Regular", size: 24))
                    .foregroundColor(Color(hex: "#68C5EA"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                
                OverviewShareInfo1View()
                    .environmentObject(modelData)

                Rectangle()
                    .fill(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(height: 10.0)
                    .edgesIgnoringSafeArea(.horizontal)

                OverviewShareInfo2View()

                Rectangle()
                    .fill(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(height: 10.0)
                    .edgesIgnoringSafeArea(.horizontal)

                OverviewShareInfo3View()

                Rectangle()
                    .fill(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(height: 10.0)
                    .edgesIgnoringSafeArea(.horizontal)

                OverviewShareInfo4View()

                Rectangle()
                    .fill(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(height: 10.0)
                    .edgesIgnoringSafeArea(.horizontal)

                Button(action: {
                    self.currInfoScreen = .patchApp
                }) {
                    if (modelData.isCHArmBandConnected) {
                        Text("MODULE ATTACHMENT >")
                            .font(.custom("Oswald-Regular", size: 18))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 20)
                            .padding(.trailing, 40)
                            .padding(.bottom, 40)
                    }
                    else {
                        Text("PATCH APPLICATION >")
                            .font(.custom("Oswald-Regular", size: 18))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 20)
                            .padding(.trailing, 40)
                            .padding(.bottom, 40)
                    }
                }
                .trackRUMTapAction(name: "appoverview-patchapp")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: generalCHAppColors.settingsColorCoalText))
        }
    }
}
