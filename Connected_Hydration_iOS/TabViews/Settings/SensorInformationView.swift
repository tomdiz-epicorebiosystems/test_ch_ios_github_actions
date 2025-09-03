//
//  SensorInformationView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI
import DGCharts
import BLEManager
import AudioToolbox

struct SensorInformationView: View {
    
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var showConnectivity: ConnectivityData?
    @State var showInfoPopover: InfoPopoverData?

    @State var batteryLvl = 30
    @State private var showSensorWaveform = false
    @State private var sweatWaveformChannelSelect = 6   // Show fluidic encoder channel (channel 6) waveform first after load

    // Custom binding for the `selection`
    var binding: Binding<Int> {
        .init(get: {
            sweatWaveformChannelSelect
        }, set: {
            sweatWaveformChannelSelect = $0
            modelData.sensorWaveformChartData.clearValues()
            modelData.ebsMonitor.setChlorideWaveformChannel(channel: UInt8(sweatWaveformChannelSelect))
        })
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BgStatusView() {}
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        DeviceStatusView(batteryLvl: $batteryLvl, firmwareRevText: $modelData.firmwareRevText, deviceStatusText: $modelData.deviceStatusText)
                        
                        Toggle("Sensor Waveform:", isOn: $showSensorWaveform)
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1.0)
                            .edgesIgnoringSafeArea(.horizontal)
                        
                        if showSensorWaveform {
                            Picker("", selection: binding) {
                                Text("CL").tag(1)
                                Text("R1").tag(2)
                                Text("R2").tag(3)
                                Text("R3").tag(4)
                                Text("R4").tag(5)
                                Text("ENC").tag(6)
                            }
                            .padding(.trailing, 20)
                            .padding(.leading, 20)
                            .pickerStyle(.segmented)
                            .onAppear() {
                                self.sweatWaveformChannelSelect = 6
                                modelData.sensorWaveformChartData.clearValues()
                                modelData.ebsMonitor.setChlorideWaveformChannel(channel: UInt8(self.sweatWaveformChannelSelect))
                            }
                            
                            DataLineChartIMUView(imuData: $modelData.sensorWaveformChartData)
                                .frame(height: 160)
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                        }
                        
                        if modelData.networkUploadSuccess == true {
                            Text("Data CSV file upload success")
                                .foregroundColor(.green)
                                .padding(5)
                        }
                        
                        if modelData.networkUploadFailed == true {
                            Text("Upload Failed: " + self.modelData.networkUploadFailedMsg)
                                .foregroundColor(.red)
                                .padding(5)
                        }
                        
                        BottomButtonView(isInternetConnectivityAlertShowing: $modelData.isInternetConnectivityAlertShowing, isLongPressShare: $modelData.isLongPressShare)
                        
                        Spacer()
                    }   // VStack
                    .frame(height: showSensorWaveform ? 850 : 650)
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    .onDisappear() {
                        NotificationCenter.default.removeObserver(self)
                    }
                    .alert(isPresented: $modelData.isSweatDataDownloadProgressAlertShowing) {
                        Alert(title: Text("Data Upload In Progress"), message: Text("\nPlease wait until it's completed"), dismissButton: .default(Text("OK")))
                    }
                    .alert(isPresented: $modelData.isInternetConnectivityAlertShowing) {
                        Alert(title: Text("No Internet"), message: Text("Please check your network and try again!"), dismissButton: .default(Text("OK")))
                    }
                    .sheet(isPresented: $modelData.isShareSheetPresented) {
                        let textToShare = [modelData.shareDataLogFileURL]
                        ShareSheetView(activityItems: textToShare as [Any])
                    }
                    
                }
                .clipped()

            }   // ZStack
            .trackRUMView(name: "SensorInformationView")
            .toolbar(.hidden, for: .tabBar)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(leading:
                Button(action : {
                    self.presentation.wrappedValue.dismiss()
                }){
                    HStack {
                        Text("< SETTINGS")
                            .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    }
                }
                .trackRUMTapAction(name: "tap_sensor_back_settings")
            )
        }
    }
}

struct BottomButtonView: View {

    @EnvironmentObject var modelData: ModelData
    @Binding var isInternetConnectivityAlertShowing: Bool
    @Binding var isLongPressShare: Bool

    var body: some View {
        Button(action: {
            // File is already uploading in background on Today Vieew
            if self.modelData.csvFileIsUploading == true {
                return
            }

            // Check if the internet connectivity is available before uploading starts. If yes, go ahead and start the uploading, if not remind user to get internet connectivity before they can upload.
            if modelData.isNetworkConnected == true {

                // This would start the multi-day data sync with sensor and cloud.
                if(modelData.sweatDataMultiDaySyncWithSensorCompleted && modelData.historicalSweatDataDownloadCompleted) {
                    modelData.networkUploadSuccess = false
                    modelData.networkManager.getNewRefreshToken()
                    modelData.ebsMonitor.scanDeviceCurrentDayData()
                }
            }
            else {
                isInternetConnectivityAlertShowing = true
            }
        }) {
            Text("SYNC NOW")
                .font(.custom("Oswald-Regular", size: 18))
                .frame(width: 150, height: 20)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                    .shadow(color: .gray, radius: 1, x: 0, y: 2))
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 3.0)
                .onEnded { _ in
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                    modelData.isLongPressShare = true
                }
        )

        Spacer()
    }
}

struct DeviceStatusView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @Binding var batteryLvl: Int
    @Binding var firmwareRevText: String
    @Binding var deviceStatusText: String
    
    @State var isStep3Presented = false

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {

        VStack {
            SensorTitleView()
            
            HStack {
                Text("Sensor Status")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(width: 200, alignment: .leading)
                    .padding(.leading, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                
                Text(BLEManager.bleSingleton.sensorConnected ? "PAIRED" : "UNPAIRED")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
            }
            
            Button(action: {
                //isStep3Presented = true
                navigate(.push(.step3PairModuleMainView))
                modelData.onboardingStep = 6
                modelData.sensorNavigation = true
                guard BLEManager.bleSingleton.peripheralToConnect != nil else {
                    return
                }
                
                // Force disconnect from sensor to re-pair. Reset the pairCHDeviceSN to empty to prevent the automatic connection after disconnection.
                self.modelData.pairCHDeviceSN = ""
                self.modelData.ebsMonitor.forceDisconnectFromPeripheral()
                
            }) {
                Text("PAIR TO NEW MODULE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: languageCode == "ja" ? 290 : 150, height: 20)
                    .padding(10)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            
            Button(action: {
                guard BLEManager.bleSingleton.peripheralToConnect != nil else {
                    return
                }
                // Force disconnect from sensor to re-pair. Reset the pairCHDeviceSN to empty to prevent the automatic connection after disconnection.
                self.modelData.pairCHDeviceSN = ""
                self.modelData.ebsMonitor.forceDisconnectFromPeripheral()
                
            }) {
                Text("UNPAIR")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: languageCode == "ja" ? 290 : 150, height: 20)
                    .padding(10)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            .disabled(!BLEManager.bleSingleton.sensorConnected)
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                Text("Firmware Rev")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(width: 200, alignment: .leading)
                    .padding(.leading, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                
                Text(BLEManager.bleSingleton.firmwareRevString)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                Text("Battery Left")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                
                Text("\(modelData.chDeviceBatteryLvl) DAYS")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                Text("RF Signal Strength")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                
                Image(uiImage: modelData.pairedCHDevice.SignalBar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                Text("Device Status")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
                
                Text(deviceStatusText)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 10)
                    .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct SensorTitleView: View {
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    @EnvironmentObject var modelData: ModelData
    
    @State var isStep3Presented = false

    var body: some View {
        
        HStack {
            Text("SENSOR INFORMATION")
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .padding(.top, 15)
                .padding(.bottom, 5)
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("Oswald-Regular", size: 20))
        }
        
        Rectangle()
            .fill(Color.gray)
            .frame(height: 1.0)

        HStack {
            Text("Serial Number")
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))

            Text(modelData.pairCHDeviceSN)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
                .font(.custom("Oswald-Regular", size: settingsSensorTextFontSize))
        }
        
        Button(action: {
            guard BLEManager.bleSingleton.sensorConnected == true else { return }
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
            let identifySensor = Data(hexString: "5A")
            peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected.writeValue(identifySensor!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
        }) {
            Text("FIND MY \(Image("Pair Module - Device Buzz"))")
                .font(.custom("Oswald-Regular", size: 18))
                .frame(width: languageCode == "ja" ? 290 : 150, height: 20)
                .padding(10)
                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                    .shadow(color: .gray, radius: 1, x: 0, y: 2))
        }
//        .frame(maxWidth: .infinity, alignment: .trailing)
//        .padding(.trailing, 10)

        Rectangle()
            .fill(Color.gray)
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct DataLineChartIMUView : UIViewRepresentable {

    var dataLineChartIMU = LineChartView()

    @Binding var imuData: LineChartData

    func makeUIView(context: Context) -> LineChartView {

        dataLineChartIMU.noDataText = "Loading..."
        dataLineChartIMU.noDataTextColor = .systemBlue
        dataLineChartIMU.noDataFont = UIFont(name: "Helvetica", size: 20.0)!
        dataLineChartIMU.clearValues()

        dataLineChartIMU.leftAxis.drawLabelsEnabled = true      // Draw the left y-axis
        dataLineChartIMU.rightAxis.drawLabelsEnabled = false    // Don't draw the right y-axis
        dataLineChartIMU.xAxis.drawGridLinesEnabled = true      // Draw x-axis grid lines
        dataLineChartIMU.leftAxis.drawGridLinesEnabled = true   // Draw y-axis grid lines
        dataLineChartIMU.rightAxis.drawGridLinesEnabled = false // Don't draw y-axis grid lines
        
        dataLineChartIMU.leftAxis.setLabelCount(6, force: false)
        dataLineChartIMU.leftAxis.axisMinimum = 0.0
        dataLineChartIMU.leftAxis.axisMaximum = 3.0
        
        dataLineChartIMU.isUserInteractionEnabled = false
        
        dataLineChartIMU.legend.textColor = UIColor.label

        return dataLineChartIMU
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {

        // is there a refresh?
        uiView.data = addData()
    }
    
    func addData() -> LineChartData {
        return imuData
    }

    typealias UIViewType = LineChartView
    
}
