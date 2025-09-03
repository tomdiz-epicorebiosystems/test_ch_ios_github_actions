//
//  VerifyPhysioloyInfoView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/5/24.
//

import SwiftUI
import BLEManager

struct VerifyPhysioloyInfoView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var isPhysiologyPresent = true
    @State var showNetworkProgressView = false
    @State var currentWeightValue = ""
    
    @State private var showPhysiologyConfirmAlert = false

    @State private var oldUserHeightFeet = ""
    @State private var oldUserHeightInch = ""
    @State private var oldUserHeightCm = ""
    @State private var oldUserWeight = ""
    @State private var oldUserGender = ""

    var body: some View {
        ZStack {
            VStack {
                Text("PERSONALIZE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .padding(.top, 20)
                
                Rectangle()
                    .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(height: 1.0)
                    .edgesIgnoringSafeArea(.horizontal)
                
                Text("This information helps tailor a hydration recommendation specific to you. It is not shared.")
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                
                Text("Please verify that your physiology information is correct.")
                    .font(.custom("Roboto-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                
                if self.modelData.networkAPIError {
                    Text("Unable to update user data on server.")
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.red)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .onAppear() {
                            self.modelData.networkAPIError = false
                            showNetworkProgressView = false
                        }
                }
                else {
                    Text("")
                        .onAppear() {
                            showNetworkProgressView = false

                            oldUserHeightFeet = modelData.userPrefsData.getUserHeightInFt()
                            oldUserHeightInch = modelData.userPrefsData.getUserHeightIn()
                            oldUserHeightCm = modelData.userPrefsData.getUserHeightCm()
                            oldUserWeight = modelData.userPrefsData.getUserWeight()
                            //print("oldUserWeight = \(oldUserWeight)")
                            oldUserGender = modelData.userPrefsData.getUserGender()
                        }
                }
                
                PhysiologyInformationView(showHeader: false, isEditing: true, showOKCancelOption: false, isPhysiologyShowing: $isPhysiologyPresent, currentWeightValue: $currentWeightValue)
                    .environmentObject(modelData)
                
                Spacer()
                
                Button(action: {
                    if oldUserHeightFeet != modelData.userPrefsData.getUserHeightInFt() || oldUserHeightInch != modelData.userPrefsData.getUserHeightIn() ||  oldUserWeight != currentWeightValue || oldUserGender != modelData.userPrefsData.getUserGender() || oldUserHeightCm != modelData.userPrefsData.getUserHeightCm() {
                        modelData.userPrefsData.setUserWeight(weight: currentWeightValue)
                        showPhysiologyConfirmAlert = true
                    }
                    else {
                        if (modelData.sensorNavigation && (modelData.onboardingStep == 6)) {
                            modelData.sensorNavigation = false
                            navigate(.unwind(.settingsSensor))
                        }
                        else {
                            modelData.sensorNavigation = false
                            modelData.isOnboardingComplete = true
                        }

                    }

                }) {
                    Text("CONTINUE")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .padding(.bottom, 40)
                .alert(isPresented: $showPhysiologyConfirmAlert) {
                    Alert(
                        title: Text("Confirm"),
                        message: Text("Are you sure you want to update your physiology information?"),
                        primaryButton: .destructive(Text("Cancel"), action: {                            
                            modelData.userPrefsData.setUserHeightFeet(feet: oldUserHeightFeet)
                            modelData.userPrefsData.setUserHeightInch(inches: oldUserHeightInch)
                            modelData.userPrefsData.setUserHeightCm(cm: UInt8(oldUserHeightCm) ?? 125)
                            modelData.userPrefsData.setUserWeight(weight: oldUserWeight)
                            modelData.userPrefsData.setUserGender(gender: oldUserGender)

                            // close view after setting to old values
                            modelData.sensorNavigation = false
                            modelData.isOnboardingComplete = true
                        }),
                        secondaryButton: .default(Text("OK"), action: {
                            updateDevice()

                            let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                            modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                            if (modelData.sensorNavigation && (modelData.onboardingStep == 6)) {
                                navigate(.unwind(.settingsSensor))
                            }
                            else {
                                modelData.isOnboardingComplete = true
                            }
                            
                            modelData.sensorNavigation = false

                        })
                    )
                }

                if showNetworkProgressView == true {
                    NetworkGetUserInfoProgressView()
                }
                
            }   // VStack
        }   // ZStack
        .trackRUMView(name: "VerifyPhysioloyInfoView")
        .onAppear() {
            self.modelData.networkAPIError = false
            showNetworkProgressView = true
            modelData.networkManager.GetUserInfo()
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
    
    func updateDevice() {
        // Check sensor connected
        guard BLEManager.bleSingleton.sensorConnected == true else { return }
        guard BLEManager.bleSingleton.peripheralToConnect != nil else { return }

        if modelData.unitsChanged == "0" {
            modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
        }
        
        else {
            modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
        }
    }
    
}

struct NetworkGetUserInfoProgressView: View {

    @State private var isRotating = 0.0

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("Progress Spinner")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .rotationEffect(.degrees(isRotating))
                    .onAppear {
                        withAnimation(.linear(duration: 1)
                            .speed(0.1).repeatForever(autoreverses: false)) {
                                isRotating = 360.0
                            }
                    }
                
                Text("Getting user data...")
                    .font(.custom("Oswald-Regular", size: 24))
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.white))
                
                Spacer()
            }
            //.zIndex(0)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all))
    }
}
