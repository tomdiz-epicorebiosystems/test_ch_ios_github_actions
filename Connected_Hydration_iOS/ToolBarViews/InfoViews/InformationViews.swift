//
//  InformationViews.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

enum InfoScreen {
    case appOverview
    case patchApp
    case modulePairing
    case sodiumEq
    case urineColorChart
    case hydrationGuides
    case support
}

struct InformationViews: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation
    @State var currInfoScreen: InfoScreen
    @Binding var isAppOverviewPresented: Bool
    @Binding var isPatchApplicationPresented: Bool
    @Binding var isModulePairingPresented: Bool
    @Binding var isUrineColorChartPresented: Bool
    @Binding var isHydrationGuidesPresented: Bool
    @Binding var isSodiumEqPresented: Bool
    @Binding var isSupportPresented: Bool

    var body: some View {

            VStack {
                HStack {
                    Image("Info Epicore Logo")
                        .padding(.top, 50)
                        .padding(.leading, 32)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                        self.isAppOverviewPresented = false
                        self.isPatchApplicationPresented = false
                        self.isModulePairingPresented = false
                        self.isUrineColorChartPresented = false
                        self.isHydrationGuidesPresented = false
                        self.isSodiumEqPresented = false
                        self.isSupportPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.white)
                    }
                    .trackRUMTapAction(name: "info-close")
                    .padding(.trailing, 10)
                    .padding(.top, 20)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.system(size: 24))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                ScrollView(.vertical, showsIndicators: true) {

                    if currInfoScreen == .appOverview {
                        AppOverviewView(currInfoScreen: $currInfoScreen, isAppOverviewPresented: $isAppOverviewPresented)
                            .environmentObject(modelData)
                    }
                    else if currInfoScreen == .patchApp {
                        if (modelData.isCHArmBandConnected) {
                            ModuleApplicationView(currInfoScreen: $currInfoScreen)
                        }
                        else {
                            PatchApplicationView(currInfoScreen: $currInfoScreen)
                        }
                    }
                    else if currInfoScreen == .modulePairing {
                        ModulePairingView(currInfoScreen: $currInfoScreen)
                    }
                    else if currInfoScreen == .sodiumEq {
                        SodiumEqView(currInfoScreen: $currInfoScreen)
                    }
                    else if currInfoScreen == .urineColorChart {
                        UrineColorChartView(currInfoScreen: $currInfoScreen)
                    }
                    else if currInfoScreen == .hydrationGuides {
                        HydrationGuidesView(currInfoScreen: $currInfoScreen)
                    }
                    else if currInfoScreen == .support {
                        SupportView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex:"#4A4A4D"))
            .edgesIgnoringSafeArea(.all)
    }
}
