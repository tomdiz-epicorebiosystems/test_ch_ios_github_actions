//
//  Step3PairModuleUnresponsive.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/26/23.
//

import SwiftUI

struct Step3PairModuleUnresponsive: View {
 
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            PairUnresponsiveTopView()
            
            PairStepsView()

            Spacer()

            Button(action: {
                modelData.allowDeviceRescan = true
                navigate(.unwind(.step3PairModuleScanView))
                self.modelData.ebsMonitor.forceDisconnectFromPeripheral()
            }) {
                Text("TRY AGAIN")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: (languageCode == "ja" ? 250 : 180), height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step3pairmoduleunresponsive_tryagain")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
            .accessibility(identifier: "button_step3pairmoduleunresponsive_tryagain")

            Button(action: {
                guard let number = URL(string: "tel://+1-617-397-3756") else { return }
                if UIApplication.shared.canOpenURL(number) {
                    UIApplication.shared.open(number)
                } else {
                    print("Can't open url on this device")
                }
            }) {
                Text(languageCode == "ja" ? "" : "Call for support")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_step3pairmoduleunresponsive_call")

            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step3pairmoduleunresponsive_call")

            Spacer()
        }
        .trackRUMView(name: "Step3PairModuleUnresponsive")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct PairUnresponsiveTopView: View {
    var body: some View {
        Text("UNRESPONSIVE MODULE")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .accessibility(identifier: "text_pairunresponsivetopview_unresponive")

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        Text("If your module is unresponsive when tested:")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_pairunresponsivetopview_tested")

    }
}

struct PairStepsView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Text("STEP 1:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .accessibility(identifier: "text_pairstepsview_step1")

            Text("App may be paired to the wrong module")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 10)
                .accessibility(identifier: "text_pairstepsview_app")

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 5)
        
        Text("• Try pairing again by scanning the QR code.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
            .accessibility(identifier: "text_pairstepsview_pairing")

        Text("• If manually entering the serial number, double-check that you’re entering the correct number.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .accessibility(identifier: "text_pairstepsview_manually")

        HStack(alignment: .top, spacing: 5) {
            Text("STEP 2:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .accessibility(identifier: "text_pairstepsview_step2")

            Text("App may not be recognizing Bluetooth")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 10)
                .accessibility(identifier: "text_pairstepsview_recognize")

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 5)
        
//        Text("STEP 2: App may not be recognizing Bluetooth")
//            .font(.custom("Roboto-Regular", size: 18))
//            .foregroundColor(.white)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.bottom, 10)
//            .padding(.leading, 20)
//            .padding(.trailing, 20)

        Text("• If the test fails after Step 1, restart your phone. Return to the Connected Hydration app, which will open on the pairing step. Try to pair again.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .accessibility(identifier: "text_pairstepsview_restart")

        HStack(alignment: .top, spacing: 5) {
            Text("STEP 3:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .accessibility(identifier: "text_pairstepsview_step3")

            Text("Depleted battery or damaged module")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 10)
                .accessibility(identifier: "text_pairstepsview_battery")

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 5)

//        Text("STEP 3: Depleted battery or damaged module")
//            .font(.custom("Roboto-Regular", size: 18))
//            .foregroundColor(.white)
//            .fixedSize(horizontal: false, vertical: true)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.bottom, 10)
//            .padding(.leading, 20)
//            .padding(.trailing, 20)

        Text("• If Step 2 is unsuccessful, request a new module.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
            .accessibility(identifier: "text_pairstepsview_unsuccessful")

    }
}
