//
//  QRCodeScannerView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/18/23.
//

import SwiftUI
import CodeScanner
import AVFoundation

struct QRCodeScannerView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentationMode

    @Binding var isCodeScannerPresented: Bool
    @Binding var qrScanCode: String
    @Binding var scanErrorString: String

    @State private var showCameraNotAuthorized = false

    var isEnterpriseIdScan: Bool

    var body: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr, .ean13, .code128], scanMode: .once , scanInterval: 0.5, showViewfinder: true) { response in
                if case let .success(result) = response {
                    print("QR Scanned Code = " + result.string)
                    qrScanCode = result.string
                }
                if case .failure(.permissionDenied) = response {
                    scanErrorString = "Camera permissions denied"
                    if (modelData.onboardingStep == 6 && modelData.isOnboardingComplete) {
                        return
                    }
                }
                if case .failure(.badInput) = response {
                    scanErrorString = "Camera failed to read QR code or barcode"
                }
                if case .failure(.badOutput) = response {
                    scanErrorString = "Camera does not support reading QR code or barcode"
                }
                logger.info("QRScan", attributes: ["error" : scanErrorString])
                self.presentationMode.wrappedValue.dismiss()
                self.isCodeScannerPresented = false
            }
            .trackRUMView(name: "CodeScannerView-enterprise")

            VStack {
                if isEnterpriseIdScan {
                    Text("SCAN ENTERPRISE CODE")
                        .font(.custom("Oswald-Regular", size: 20))
                        .foregroundColor(Color.white)
                        .padding(.top, 40)
                }
                else {
                    Text("SCAN MODULE QR CODE")
                        .font(.custom("Oswald-Regular", size: 20))
                        .foregroundColor(Color.white)
                        .padding(.top, 40)
                }
                
                Rectangle()
                    .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(height: 1.0)
                    .edgesIgnoringSafeArea(.horizontal)

                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    self.isCodeScannerPresented = false
                }) {
                    Text("CANCEL")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .trackRUMTapAction(name: "qrscan-CANCEL")
                .padding(.bottom, 80)

            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showCameraNotAuthorized) {
            Alert(
                title: Text("Camera"),
                message: Text("Epicore CH needs access to your camera to scan QR code."),
                primaryButton: .default(Text("Settings"), action: {
                    showCameraNotAuthorized = false
                    //let url = URL(string: UIApplication.openSettingsURLString)
                    //let app = UIApplication.shared
                    //app.openURL(url!)
                    DispatchQueue.main.async {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                    showCameraNotAuthorized = false
                    scanErrorString = "Camera permissions denied"
                    logger.info("QRScan", attributes: ["error" : scanErrorString])
                    self.presentationMode.wrappedValue.dismiss()
                    self.isCodeScannerPresented = false
                }))
        }
        .onAppear() {
            if (modelData.onboardingStep == 6 && modelData.isOnboardingComplete) {
                if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                    //already authorized
                } else {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            //access allowed
                        } else {
                            showCameraNotAuthorized = true
                        }
                    })
                }
            }
        }
    }
}
