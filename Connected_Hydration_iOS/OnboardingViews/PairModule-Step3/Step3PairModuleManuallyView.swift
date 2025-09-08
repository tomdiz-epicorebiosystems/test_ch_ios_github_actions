//
//  Step3PairModuleManuallyView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/26/23.
//

import SwiftUI
import BLEManager

struct Step3PairModuleManuallyView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var deviceSN = ""
    @State private var isRotating = 0.0
    @State private var isScanning = false
    @State private var isValidSN = false
    @State private var deviceScanningErrors = ""
    
    @State var notificationSensorPaired: Any? = nil

    @State private var navigateOnce = false

    var body: some View {
        GeometryReader { geoMain in
            VStack {
                PairManuallyTopViews()
                
                VStack {
                    Image("Pair Module - Device SN")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geoMain.size.width)
                        .padding(.top, 10)
                        .accessibility(identifier: "image_step3pairmodulemanuallyview_device")

                    Text("Locate the serial number on the back of your module and enter it below.")
                        .font(.custom("Roboto-Regular", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibility(identifier: "text_step3pairmodulemanuallyview_locate")

                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Serial Number:")
                        .font(.custom("Roboto-Regular", size: 18))
                        .foregroundColor(.white)
                        .accessibility(identifier: "text_step3pairmodulemanuallyview_sn")

                    TextField("", text: $deviceSN)
                        .textFieldStyle(.roundedBorder)
                        .font(.custom("Roboto-Bold", size: 20))
                        .multilineTextAlignment(.center)
                        .frame(height: 50, alignment: .center)
                        .keyboardType(.alphabet)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled(true)
                        .submitLabel(.done)
                        .accessibility(identifier: "textfield_step3pairmodulemanuallyview_devicesn")

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                    
                Text(deviceScanningErrors)
                    .font(.custom("Roboto-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.red)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_step3pairmodulemanuallyview_locate")

                Spacer()
                
                Button(action: {
                    if isValidDeviceSerialNumber(deviceSN) == false {
                        deviceScanningErrors = "Serial number should be 8 characters long\nDo not include dashes."
                    }
                    else {
                        deviceScanningErrors = ""
                        modelData.pairCHDeviceSN = deviceSN
                        connectToCHDevice()
                    }
                }) {
                    if isScanning {
                        Image("Progress Button Spinner")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .rotationEffect(.degrees(isRotating))
                            .onAppear {
                                withAnimation(.linear(duration: 1)
                                    .speed(0.1).repeatForever(autoreverses: false)) {
                                        isRotating = 360.0
                                    }
                            }
                            .frame(width: 180, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "image_step3pairmodulemanuallyview_spinner")
                    }
                    else {
                        Text("SUBMIT")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 180, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "text_step3pairmodulemanuallyview_submit")
                    }
                }
                .padding(.bottom, 20)
                .accessibility(identifier: "button_step3pairmodulemanuallyview_submit")

                Button(action: {
                    navigate(.push(.step3PairModuleScanView))
                }) {
                    Text("Scan QR Code Instead")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .accessibility(identifier: "text_step3pairmodulemanuallyview_scan")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibility(identifier: "button_step3pairmodulemanuallyview_scan")

            }
            .onAppear() {
                if (notificationSensorPaired == nil) {
                    notificationSensorPaired = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.ConnectEvent), object: nil, queue: OperationQueue.main) { _ in self.sensorPaired() }
                }
            }
            .onDisappear() {
                NotificationCenter.default.removeObserver(notificationSensorPaired!)
                notificationSensorPaired = nil
                isRotating = 0.0
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))
        }
        .trackRUMView(name: "Step3PairModuleManuallyView")
        //.onTapGesture {
        //    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //}
    }
    
    func sensorPaired() {
        print("Sensor paired!")
        logger.info("sensor_paired")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if navigateOnce == false {
                navigateOnce = true
                navigate(.push(.step3PairModuleIdentifyView))
            }
            isScanning = false
        }
        
    }
    
    func connectToCHDevice() {
        var deviceFound = false
        
        // Use specific test serial number to bypass pairing for App Store review since the reviewer doesn't have physical module to use for review.
        let isArmBandTesting = modelData.pairCHDeviceSN == "CHTEST01"
        if modelData.pairCHDeviceSN == "CHTEST00" || isArmBandTesting {
            if (isArmBandTesting) {
                modelData.firmwareRevText = "v6.1"
            }
            deviceFound = true
            if navigateOnce == false {
                navigateOnce = true
                navigate(.push(.step3PairModuleIdentifyView))
            }
            isScanning = false
            return
        }
        
        // Add some delay here so that the sensor can appear on the BLE scan list to be detected and connected
        isScanning = true
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            for device in modelData.CHDeviceArray {
                if device.name == modelData.pairCHDeviceSN {
                    modelData.pairedCHDevice = device
                    deviceFound = true
                    break
                }
            }
            
            if deviceFound == true {
                print("Found Device: " + modelData.pairCHDeviceSN)
                logger.info("Found Device: " + modelData.pairCHDeviceSN)
                print("Connecting to CH Device...")
                
                // Move onto identify page after successful pairing
                //                isScanning = true
                if(BLEManager.bleSingleton.sensorConnected) {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if navigateOnce == false {
                            navigateOnce = true
                            navigate(.push(.step3PairModuleIdentifyView))
                        }
                        isScanning = false
                    }
                }
                else {
                    modelData.ebsMonitor.connectToPeripheral()
                    
                    count += 1
                    print(count)
                    
                    if (count > 30) {
                        logger.error("device_not_connected" + modelData.pairCHDeviceSN)
                        deviceScanningErrors = "Module could not connect. Please make sure module is powered on and try again."
                        isScanning = false

                        timer.invalidate()
                    }
                    
                }
            }
            else {
                count += 1
                print(count)
                
                if (count > 30) {
                    logger.error("device_not_found" + modelData.pairCHDeviceSN)
                    deviceScanningErrors = "Serial number not found. Please make sure module is powered on and try again."
                    isScanning = false

                    timer.invalidate()
                }
            }
            
        }
    }
    
    func isValidDeviceSerialNumber(_ serialNumber: String) -> Bool {
        let snRegEx = "^[A-Z0-9]{8}(?!.*-)"

        let snPred = NSPredicate(format:"SELF MATCHES %@", snRegEx)
        
        if snPred.evaluate(with: serialNumber) == false {
            isValidSN = false
        }
        return snPred.evaluate(with: serialNumber)
    }

}

struct PairManuallyTopViews: View {
    var body: some View {
        Text("PAIR MODULE")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .accessibility(identifier: "text_pairmanuallytopviews_pairmodule")

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)
        
        Image("PairModule - Dots 3")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .accessibility(identifier: "image_pairmanuallytopviews_progress_3")
    }
}
