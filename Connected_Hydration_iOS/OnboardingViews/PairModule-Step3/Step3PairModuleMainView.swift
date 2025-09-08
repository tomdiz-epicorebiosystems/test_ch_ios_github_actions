//
//  Step3PairModuleMainView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/24/23.
//

import SwiftUI

struct Step3PairModuleMainView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var showBluetoothNotAuthorized = false
    @State private var showBluetoothPoweredOff = false

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            Text("PAIR MODULE")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
            
            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            Image("PairModule - Dots 1")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
            
            PairModuleShareInfo1View()
            
            Spacer()
            
            Button(action: {
                // Make sure bluetooth is ok
                if isBluetoothPermissionGranted == false {
                    logger.info("isBluetoothPermissionGranted == false")
                    showBluetoothNotAuthorized = true
                }
                else if isBluetoothPoweredOn {
                    showBluetoothPoweredOff = true
                }
                else {
                    navigate(.push(.step3PairModuleScanView))
                }
            }) {
                Text("MY MODULE IS ON")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: languageCode == "ja" ? 300 : 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .padding(.bottom, 40)
            
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showBluetoothPoweredOff) {
            Alert(title: Text("Bluetooth"),
                  message: Text("Please turn on your iPhone's bluetooth."),
                  dismissButton: .default(Text("OK"), action: {
                    showBluetoothPoweredOff = false
            }))
        }
        .alert(isPresented: $showBluetoothNotAuthorized) {
            Alert(
                title: Text("Bluetooth"),
                message: Text("Epicore CH needs access to bluetooth to function properly."),
                primaryButton: .default(Text("Settings"), action: {
                    showBluetoothNotAuthorized = false
                    let url = URL(string: UIApplication.openSettingsURLString)
                    let app = UIApplication.shared
                    app.open(url!, options: [:], completionHandler: nil)
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                    showBluetoothNotAuthorized = false
                }))
        }
        .trackRUMView(name: "Step3PairModuleMainView")
    }
}

struct PairModuleShareInfo1View: View {
    var body: some View {
        Text("Press the power button on the module.")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 10)

        Text("A light will flash on startup, then blink green every 10 sec.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 40)
        
        Image("Pair Module - On-Off")
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
