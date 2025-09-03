//
//  Step3PairModuleIdentifyView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/26/23.
//

import SwiftUI
import BLEManager

struct Step3PairModuleIdentifyView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var isBuzzPressed = false

    var body: some View {
        VStack {
            PairIdentityTopView()

            Spacer()

            Button(action: {
                self.isBuzzPressed = true
                guard BLEManager.bleSingleton.sensorConnected == true else { return }
                guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
                let identifySensor = Data(hexString: "5A")
                peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
                peripheralConnected.writeValue(identifySensor!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
            }) {
                Text("BUZZ ME \(Image("Pair Module - Device Buzz"))")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "buzz_me")
            .padding(.bottom, 10)

            Text("Was your module responsive?")
                .font(.custom("Roboto-Regular", size: 18))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.white)
                .padding(.bottom, 10)

            Spacer()
            
            HStack {

                Button(action: {
                    navigate(.push(.step3PairModuleUnresponsive))
                }) {
                    Text("NO")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 70, height: 50)
                        .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .trackRUMTapAction(name: "buzz_me-no")
                .disabled(self.isBuzzPressed ? false : true)

                if modelData.onboardingStep == 6 {
                    Button(action: {
                        navigate(.push(.verifyPhysioloyInfoView))
                    }) {
                        Text("YES")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 70, height: 50)
                            .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                }
                else if modelData.onboardingStep == 7 {
                    Button(action: {
                        modelData.isOnboardingComplete = true
                    }) {
                        Text("YES")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 70, height: 50)
                            .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                }
                else if modelData.onboardingStep == 8 {
                    Button(action: {
                        navigate(.push(.logInPhysioloyInfoView))
                    }) {
                        Text("YES")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 70, height: 50)
                            .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                }
                else {
                    Button(action: {
                        modelData.onboardingStep = 4
                        navigate(.unwind(.initialSetupOnboarding))
                    }) {
                        Text("YES")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 70, height: 50)
                            .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    .trackRUMTapAction(name: "buzz_me-yes")
                    .disabled(self.isBuzzPressed ? false : true)
                }
            }
            .padding(.bottom, 40)

        }
        .trackRUMView(name: "Step3PairModuleIdentify")
        .onAppear() {
            let weightkg = modelData.userPrefsData.getUserWeightKg()
            let weightLb = modelData.userPrefsData.getUserWeightLb()
            
            let gender = modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female"
            
            // Update server physiology user info
            let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
            modelData.networkManager.modelData = self.modelData
            modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

            // Add delay here to give time for BLEManager to update connection status.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                if modelData.unitsChanged == "0" {
                    modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: weightkg, gender: gender, clothTypeCode: 0)
                }
                
                else {
                    modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: weightLb, gender: gender, clothTypeCode: 0)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct PairIdentityTopView: View {
    var body: some View {
        Text("PAIR MODULE")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
        
        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)
        
        Image("PairModule - Dots 4")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)

        Text("Bluetooth connection established!")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 10)

        HStack(alignment: .center) {
            Image("Connex - device")
                .padding(.top, 10)

            Image("Connex - divider ok")
                .padding(.top, 10)

            Image("Connex - phone icon")
                .padding(.top, 10)
        }
        .padding(.bottom, 20)

        Text("To confirm that your phone is paired to the correct module, tap “Buzz Me”. Your module should blink and vibrate.")
            .font(.custom("Roboto-Regular", size: 16))
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color.white)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}
