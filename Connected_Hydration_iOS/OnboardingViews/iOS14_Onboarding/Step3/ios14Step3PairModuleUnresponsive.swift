//
//  ios14Step3PairModuleUnresponsive.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/21/23.
//

import SwiftUI

struct ios14Step3PairModuleUnresponsive: View {
 
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    @Binding var isStep3Presented: Bool
    @Binding var isStep3ScanPresented: Bool
    @Binding var isStep3EnterManuallyPresented: Bool
    @Binding var isStep3PairModuleIdentifyPresented: Bool

    var body: some View {
        VStack {
            PairUnresponsiveTopView()
            
            PairStepsView()

            Spacer()

            Button(action: {
                //  back to pair module 2
                //self.presentation.wrappedValue.dismiss()
                self.isStep3EnterManuallyPresented = false
                self.isStep3ScanPresented = false
                self.isStep3PairModuleIdentifyPresented = false
                
                self.modelData.ebsMonitor.forceDisconnectFromPeripheral()
            }) {
                Text("TRY AGAIN")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
            
            Button(action: {
                guard let number = URL(string: "tel://+1-617-397-3756") else { return }
                if UIApplication.shared.canOpenURL(number) {
                    UIApplication.shared.open(number)
                } else {
                    print("Can't open url on this device")
                }
            }) {
                Text("Call for support")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)

            Spacer()
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
struct PairStepsView: View {
    var body: some View {
        Text("STEP 1: APP MAY BE PAIRED TO THE WRONG MODULE")
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)

        Text("• Try pairing again by scanning the QR code.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

        Text("• If manually entering the serial number, double-check that you’re entering the correct number.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .fixedSize(horizontal: false, vertical: true)

        Text("STEP 2: APP MAY NOT BE RECOGNIZING BLUETOOTH")
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)

        Text("• If the test fails after Step 1, restart your phone. Return to the Connected Hydration app, which will open on the pairing step. Try to pair again.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .fixedSize(horizontal: false, vertical: true)

        Text("STEP 3: DEPLETED BATTERY OR DAMAGED MODULE")
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)

        Text("• If Step 2 is unsuccessful, request a new module.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }
}
*/
