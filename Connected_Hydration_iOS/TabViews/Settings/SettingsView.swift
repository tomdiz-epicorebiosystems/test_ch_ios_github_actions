//
//  SettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//

import SwiftUI
import BLEManager

struct SettingsView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var navigationPath: [MainOnboardingRoute] = []
    @State private var isStep3Presented = false

    @Binding var tabNothing: Tab

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                BgStatusView() {}
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { reader in
                        MainSettingsView(scrollTo: reader)
                            .environmentObject(modelData)
                            .padding(.top, 40)
                            .navigationDestination(for: MainOnboardingRoute.self) { screen in
                                switch screen {
                                case .settingsSensor:
                                    SensorInformationView().navigationBarBackButtonHidden(true)
                                case .settingsLegal:
                                    LegalAndRegulatoryView().navigationBarBackButtonHidden(true)
                                case .settingsTerms:
                                    TermsAndConditionsView().navigationBarBackButtonHidden(true)
                                case .settingsPrivacy:
                                    PrivacyView().navigationBarBackButtonHidden(true)
                                case .step3PairModuleMainView:
                                    Step3PairModuleMainView().navigationBarBackButtonHidden(false)
                                        .environmentObject(modelData)
                                case .step3PairModuleScanView:
                                    Step3PairModuleScanView().navigationBarBackButtonHidden(false)
                                        .environmentObject(modelData)
                                case .step3PairModuleIdentifyView:
                                    Step3PairModuleIdentifyView().navigationBarBackButtonHidden(true)
                                        .environmentObject(modelData)
                                case .step3PairModuleManuallyView:
                                    Step3PairModuleManuallyView().navigationBarBackButtonHidden(true)
                                        .environmentObject(modelData)
                                case .step3PairModuleUnresponsive:
                                    Step3PairModuleUnresponsive().navigationBarBackButtonHidden(true)
                                        .environmentObject(modelData)
                                case .verifyPhysioloyInfoView:
                                    VerifyPhysioloyInfoView().navigationBarBackButtonHidden(true)
                                        .environmentObject(modelData)
                                default:
                                    EmptyView()
                                }
                            }

                        Text("\u{00A9}2025 Epicore Biosystems Inc.")
                            .font(.custom("Oswald-Bold", size: 12))
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Version " + Bundle.main.releaseVersionNumber! + " Build " + Bundle.main.buildVersionNumber!)
                            .font(.custom("Oswald-Regular", size: 12))
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 40)
                            .onAppear() {
                                if (modelData.suggestIntakeExpandedButtonPressed) {
                                    modelData.scrollToPassive += 1
                                }
                            }
                    }
                }
                .clipped()
                
                BgTabIntakeExtensionView(tabSelection: $tabNothing)
                    .clipped()
            }
            .addToolbar()
            .trackRUMView(name: "SettingsView")

        } // NavigationStack
        .onNavigate { navType in
            switch navType {
                case .push(let route):
                    navigationPath.append(route)
                case .unwind(let route):
                if route == .settingsLegal || route == .settingsSensor {
                        navigationPath = []
                    } else {
                        guard let index = navigationPath.firstIndex(where: { $0 == route })  else { return }
                        navigationPath = Array(navigationPath.prefix(upTo: index + 1))
                    }
            }
        }
    }
}
