//
//  io14Step3PairModuleScanView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/21/23.
//

import SwiftUI
import BLEManager

struct ios14Step3PairModuleScanView: View {

    @EnvironmentObject var modelData: ModelData
    //@Environment(\.presentationMode) var presentation

    @Binding var isStep3Presented: Bool
    @Binding var isStep3ScanPresented: Bool
    
    @State private var isScanning = false
    @State private var scanErrorString = ""
    @State private var isStep3PairModuleIdentifyPresented = false
    @State private var isRotating = 0.0
    
    @State private var isCodeScannerPresented = false
    @State private var isStep3EnterManuallyPresented = false
    @State var qrScanCode = ""
    
    @State var notificationSensorPaired: Any? = nil
    
    @State var deviceFound = true
    
    var body: some View {
        ZStack {
            
            VStack {
                NavigationLink(destination: ios14Step3PairModuleIdentify(isStep3Presented: $isStep3Presented, isStep3EnterManuallyPresented: $isStep3EnterManuallyPresented, isStep3ScanPresented: $isStep3ScanPresented, isStep3PairModuleIdentifyPresented: $isStep3PairModuleIdentifyPresented).navigationBarBackButtonHidden(true), isActive: $isStep3PairModuleIdentifyPresented) {}
                
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
                
                Text("Tap the button below to scan the QR code on the back of the module.")
                    .font(.custom("Roboto-Medium", size: 20))
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

                if #available(iOS 15.0, *) {
                    Button(action: {
                        self.isCodeScannerPresented = true
                    }) {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 180, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    .padding(.bottom, 10)
                    .uiKitFullPresent(isPresented: $isCodeScannerPresented, content: { closeHandler in
                        QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: false)
                    })
                }
                else {  // iOS 14/13
                    Button(action: {
                        self.isCodeScannerPresented = true
                    }) {
                        if #available(iOS 14.0, *) {
                            Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 180, height: 50)
                                .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        }
                        else {
                            Text("SCAN QR CODE")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 180, height: 50)
                                .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        }
                    }
                    .padding(.bottom, 10)
                    .fullScreenCover(isPresented: $isCodeScannerPresented, onDismiss: {
                        // iOS 14 .onAppear() only called once, so added this here
                        if qrScanCode.isEmpty == false {
                            print("CH Device QR Code = " + qrScanCode)
                            // Find scanned device in our array of devices we found when scanning
                            deviceFound = false
                            for device in modelData.CHDeviceArray {
                                if device.name == qrScanCode {
                                    modelData.pairedCHDevice = device
                                    deviceFound = true
                                    break
                                }
                            }
#if SIMULATOR_BUILD
                            // This is for debugging
                            // Also,comment out line below: connectToPeripheral()
                            if qrScanCode == "CH100002" {
                                deviceFound = true
                            }
                            // --------
#endif

                            isCodeScannerPresented = false
                            
                            if deviceFound == true {
                                print("Found Device: " + qrScanCode)
                                print("Step3PairModuleScanView - Connecting to CH Device...")
                                // Move onto identify page after successful pairing
#if !(SIMULATOR_BUILD)
                                isScanning = true
                                if(BLEManager.bleSingleton.sensorConnected) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        //modelData.pairCHDeviceSN = qrScanCode
                                        isStep3PairModuleIdentifyPresented = true
                                        isScanning = false
                                    }
                                }
                                else {
                                    modelData.ebsMonitor.connectToPeripheral()
                                }
#endif
                            }
                        }
                      }, content: {
                          QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: true)
                      })
                    /*
                    .sheet(isPresented: $isCodeScannerPresented) {
                        QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: false)
                    }
                    */
                }
                
                NavigationLink(destination: ios14Step3PairModuleManuallyView(isStep3Presented: $isStep3Presented, isStep3EnterManuallyPresented: $isStep3EnterManuallyPresented, isStep3ScanPresented: $isStep3ScanPresented).navigationBarBackButtonHidden(true), isActive: $isStep3EnterManuallyPresented) {
                    Button(action: {
                        self.isStep3EnterManuallyPresented = true
                    }) {
                        Text("Enter Manually Instead")
                            .underline()
                            .font(.custom("Roboto-Regular", size: 14))
                            .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    }
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
        .onAppear() {
            
            if (notificationSensorPaired == nil) {
                notificationSensorPaired = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.ConnectEvent), object: nil, queue: OperationQueue.main) { _ in self.sensorPaired() }
            }
            
            if qrScanCode.isEmpty == false {
                print("CH Device QR Code = " + qrScanCode)
                // Find scanned device in our array of devices we found when scanning
                deviceFound = false
                for device in modelData.CHDeviceArray {
                    if device.name == qrScanCode {
                        modelData.pairedCHDevice = device
                        deviceFound = true
                        break
                    }
                }
#if SIMULATOR_BUILD
                // This is for debugging
                // Also,comment out line below: connectToPeripheral()
                if qrScanCode == "CH100002" {
                    deviceFound = true
                }
                // --------
#endif
                isCodeScannerPresented = false
                
                if deviceFound == true {
                    print("Found Device: " + qrScanCode)
                    print("Step3PairModuleScanView - Connecting to CH Device...")
                    // Move onto identify page after successful pairing
#if !(SIMULATOR_BUILD)
                    isScanning = true
                    if(BLEManager.bleSingleton.sensorConnected) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            //modelData.pairCHDeviceSN = qrScanCode
                            isStep3PairModuleIdentifyPresented = true
                            isScanning = false
                        }
                    }
                    else {
                        modelData.ebsMonitor.connectToPeripheral()
                    }
#endif
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
        .navigationBarItems(leading: Button(action : {
            //self.presentation.wrappedValue.dismiss()
            self.isStep3ScanPresented = false
        }){
            Text("< BACK")
                .font(.system(size: 14))
                .foregroundColor(Color.white)
        })
        .background(Color(hex: generalCHAppColors.onboardingDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
    
    func sensorPaired() {
        print("Sensor paired!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isStep3PairModuleIdentifyPresented = true
            isScanning = false
        }
        
    }
}
