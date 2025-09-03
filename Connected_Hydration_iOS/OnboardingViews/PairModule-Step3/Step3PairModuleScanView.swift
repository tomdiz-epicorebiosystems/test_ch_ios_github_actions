//
//  Step3PairModuleScanView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/24/23.
//

import SwiftUI
import BLEManager

struct Step3PairModuleScanView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate
    
    @State private var isScanning = false
    @State private var scanErrorString = ""
    @State private var isRotating = 0.0
    
    @State private var isCodeScannerPresented = false
    @State private var qrScanCode = ""

    @State var notificationSensorPaired: Any? = nil
    
    @State private var navigateOnce = false
    @State private var deviceFound = true
    
    private let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        ZStack {
            
            VStack {

                Text("PAIR MODULE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                
                Rectangle()
                    .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(height: 1.0)
                    .edgesIgnoringSafeArea(.horizontal)
                
                Image("PairModule - Dots 2")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                
                Text("Locate the label on the back of your module and tap the button below to **scan** the QR code")
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                PairModuleShareInfo2View()
                
                Spacer()
                
                VStack {
                    if scanErrorString.isEmpty == false {
                        Text(scanErrorString)
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                    
                    if deviceFound == false {
                        Text("Not able to pair, please make sure the module is powered on and then try again. Go back to previous page for instruction.")
                            .font(.custom("Roboto-Regular", size: 14))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }

                Button(action: {
                    self.isCodeScannerPresented = true
                }) {
                    if (languageCode == "ja") {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 350, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    else {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 180, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                }
                .trackRUMTapAction(name: "qr-device")
                .padding(.bottom, 10)
                .uiKitFullPresent(isPresented: $isCodeScannerPresented, content: { closeHandler in
                    QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: false)
                        .environmentObject(modelData)
                })
                
                Button(action: {
                    navigate(.push(.step3PairModuleManuallyView))
                }) {
                    Text("Enter Manually Instead")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .trackRUMTapAction(name: "manually-device")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
                
            }
            
            if isScanning {
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
                        
                        Text("PAIRING...")
                            .font(.custom("Oswald-Regular", size: 24))
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(UIColor.white))
                        
                        Spacer()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all))
            }
        
        }
        .trackRUMView(name: "Step3PairModuleScanView")
        .onAppear() {
            
            if (notificationSensorPaired == nil) {
                notificationSensorPaired = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.ConnectEvent), object: nil, queue: OperationQueue.main) { _ in self.sensorPaired() }
            }
            
            if qrScanCode.isEmpty == false {
                print("CH Device QR Code = " + qrScanCode)
                logger.info("device", attributes: ["qrscan": qrScanCode])
                
                // Find scanned device in our array of devices we found when scanning
                var devicePresent = false
                
                // Add some delay here so that the sensor can appear on the BLE scan list to be detected and connected
                isScanning = true
                var count = 0
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    
                    for device in modelData.CHDeviceArray {
                        if device.name == qrScanCode {
                            modelData.pairedCHDevice = device
                            devicePresent = true
                            break
                        }
                    }
                    
                    isCodeScannerPresented = false
                    
                    if devicePresent == true {
                        print("Found Device: " + qrScanCode)
                        print("Step3PairModuleScanView - Connecting to CH Device...")
                        logger.info("device_pair", attributes: ["found_device": qrScanCode])

                        // Move onto identify page after successful pairing
                        if(BLEManager.bleSingleton.sensorConnected) {
                            timer.invalidate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                if navigateOnce == false || modelData.allowDeviceRescan {
                                    navigateOnce = true
                                    modelData.allowDeviceRescan = false
                                    navigate(.push(.step3PairModuleIdentifyView))
                                }
                                isScanning = false
                            }
                        }
                        
                        else {
                            modelData.ebsMonitor.connectToPeripheral()
                        }
                        
                    }
                    
                    count += 1
                    print(count)
                    
                    if (count > 30) {
                        logger.error("device_not_connected" + modelData.pairCHDeviceSN)
                        isScanning = false

                        deviceFound = false
                        
                        timer.invalidate()
                    }

                }
            }

        }
        .onDisappear() {
            NotificationCenter.default.removeObserver(notificationSensorPaired!)
            notificationSensorPaired = nil
            qrScanCode = ""
            isRotating = 0.0
            deviceFound = true
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
    
    func sensorPaired() {
        print("Sensor paired!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if navigateOnce == false || modelData.allowDeviceRescan {
                navigateOnce = true
                modelData.allowDeviceRescan = false
                navigate(.push(.step3PairModuleIdentifyView))
            }
            isScanning = false
        }
        
    }
}

struct PairModuleShareInfo2View: View {
    var body: some View {
        Image("Pair Module - Scan")
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
