//
//  ios14Step3PairModuleIdentify.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/21/23.
//

import SwiftUI
import BLEManager

struct ios14Step3PairModuleIdentify: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    @Binding var isStep3Presented: Bool
    @Binding var isStep3EnterManuallyPresented: Bool
    @Binding var isStep3ScanPresented: Bool
    @Binding var isStep3PairModuleIdentifyPresented: Bool

    @State private var isBuzzPressed = false
    @State private var isStep3EnterUnresponsivePresented = false

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
                if #available(iOS 14.0, *) {
                    Text("BUZZ ME \(Image("Pair Module - Device Buzz"))")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                else {
                    Text("BUZZ ME")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
            }
            .padding(.bottom, 10)

            Text("Was your module responsive?")
                .font(.custom("Roboto-Regular", size: 18))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.white)
                .padding(.bottom, 10)

            Spacer()
            
            HStack {
                NavigationLink(destination: ios14Step3PairModuleUnresponsive(isStep3Presented: $isStep3Presented, isStep3ScanPresented: $isStep3ScanPresented, isStep3EnterManuallyPresented: $isStep3EnterManuallyPresented, isStep3PairModuleIdentifyPresented: $isStep3PairModuleIdentifyPresented).navigationBarBackButtonHidden(true), isActive: $isStep3EnterUnresponsivePresented) {
                    
                    Button(action: {
                        self.isStep3EnterUnresponsivePresented = true
                    }) {
                        Text("NO")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 70, height: 50)
                            .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    .disabled(self.isBuzzPressed ? false : true)
                }

                Button(action: {
                    modelData.onboardingStep = 4
                    modelData.savedOnboardingStep = 4
                    self.isStep3EnterManuallyPresented = false
                    self.isStep3ScanPresented = false
                    self.isStep3Presented = false
                }) {
                    Text("YES")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 70, height: 50)
                        .foregroundColor(self.isBuzzPressed ? Color(hex: generalCHAppColors.onboardingLtBlueColor) : Color.gray)
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .disabled(self.isBuzzPressed ? false : true)
            }
            .padding(.bottom, 40)

        }
        .onAppear() {
            let weight = modelData.userPrefsData.getUserWeight()
            let feet = modelData.userPrefsData.getUserHeightInFt()
            let inches = modelData.userPrefsData.getUserHeightIn()
            let gender = modelData.UserGender == "M" ? "Male" : "Female"
            
            // Add delay here to give time for BLEManager to update connection status.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                modelData.ebsMonitor.saveUserInfo(feet: feet, inches: inches, weight: weight, gender: gender, clothTypeCode: modelData.userWorkClothingTypeCode)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingDarkBackground)
            .edgesIgnoringSafeArea(.all))
        .navigationBarItems(leading: Button(action : {
            self.presentation.wrappedValue.dismiss()
        }){
            Text("< BACK")
                .font(.system(size: 14))
                .foregroundColor(Color.white)
        })
        .background(Color(hex: generalCHAppColors.onboardingDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}
/*
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
            .font(.custom("Roboto-Bold", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 20)

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
            .font(.custom("Roboto-Regular", size: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.white)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}
*/
