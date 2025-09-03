//
//  MainSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI

struct MainSettingsView: View {

    @EnvironmentObject var modelData: ModelData

    @State var isPhysiologyPresent = false
    @State var currentWeightValue = ""

    var scrollTo: ScrollViewProxy

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            Text("ACCOUNT & SETTINGS")
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(.top, 10)
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("Oswald-Regular", size: settingsTitleFontSize))

            AccountSettingsView()
                .environmentObject(modelData)

            DataSharingSettingsView(showHeading: true)
                .environmentObject(modelData)

            MeasurementUnitSettingsView()
                .environmentObject(modelData)

            PhysiologyInformationView(showHeader: true, isEditing: false, showOKCancelOption: false, isPhysiologyShowing: $isPhysiologyPresent, currentWeightValue: $currentWeightValue)
                .environmentObject(modelData)

            ModuleSettingsView()
                .environmentObject(modelData)

            LegalView()
                .id(100)
                .onReceive(modelData.$scrollToPassive, perform: { _ in
                    if (modelData.suggestIntakeExpandedButtonPressed) {
                        DispatchQueue.main.async {
                            scrollTo.scrollTo(100, anchor: .center)
                            modelData.suggestIntakeExpandedButtonPressed = false
                        }
                    }
                })

            if modelData.userEmailAddress.contains("epicorebiosystems.com") {
                DebugSettingsView()
            }

            Spacer()
            
            if modelData.networkAPIError == true {
                if let serverError = modelData.networkManager.serverError {
                    Text(/*serverError.error ??*/"Unknown server API issue")
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.red)
                }
            }

            Button(action: {
                modelData.userPrefsData.resetUserPrefs()
                modelData.networkManager.logOutUser()
                self.modelData.pairCHDeviceSN = ""
                
                // Need to reset published variables used in onboarding navigation
                self.modelData.enterpriseNameAvailable = 0
                self.modelData.userExists = 0
                self.modelData.networkSendCodeAPIError = 0
                self.modelData.userAuthenticated = 0
                self.modelData.sendCodeSuccess = 0
                self.modelData.updatedUserSuccess = 0
            }) {
                Text("LOGOUT")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 100, height: 20)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            .trackRUMTapAction(name: "tap_log_out")
            .padding(.bottom, 20)

        }
        .trackRUMView(name: "MainSettingsView")
        .onDisappear() {
            // Save user privacy settings when leave Settings tab
            modelData.networkManager.SetUserInfo(epicore: modelData.shareAnonymousDataEpicore, site: modelData.shareAnonymousDataEnterprise)
        }
        .frame(height : (modelData.userEmailAddress.contains("epicorebiosystems.com") ? 1300 : 1250) + (modelData.buttonPressForWaterIntake ? 40 : 0))
        .background(Color.white)
        .cornerRadius(7.0)
        .padding(10)
        .padding(.top, languageCode == "ja" ? ((modelData.sweatDashboardViewStatus == 1) ? 20 : 0) : 0)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
