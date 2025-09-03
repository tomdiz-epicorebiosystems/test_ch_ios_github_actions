//
//  TodayView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/14/23.
//

import SwiftUI
import BLEManager
import CoreBluetooth

struct TodayView: View {

    @EnvironmentObject var modelData: ModelData

    @State private var isOnboardingPresented = false
    @State private var peripheralToConnect: CBPeripheral?
    @State var skinTempSChart: [SkinTempChartData] = []
    @State var exertionSChart: [ExertionChartData] = []
    @State var skinTempData = [Entry]()
    @State var activityData = [Entry]()

    @Binding var tabNothing: Tab
    @Binding var showBluetoothNotAuthorized: Bool
    @Binding var showBluetoothPoweredOff: Bool

    let fontSizeCount = 5
    let fluidBottleIncremental = 0.25
    let sodiumPackIncremental = 1.0
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        NavigationStack {
            ZStack {
                BgStatusView() {}
                    .clipped()
                
                ScrollView(.vertical, showsIndicators: true) {
                    SuggestedIntakeView(tabSelection: $tabNothing)
                    
                    StatsChartsView(skinTempSChart: $skinTempSChart, exertionSChart: $exertionSChart, skinTempData: $skinTempData, activityData: $activityData)
                    
                    WorkDaySummaryView(skinTempData: $skinTempData, activityData: $activityData)
                        .padding(.bottom, 45)
                    
                }   // ScrollView
                .clipped()
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
                
                BgTabIntakeExtensionView(tabSelection: $tabNothing)
                    .clipped()
                
            }   // ZStack
            .addToolbar()
        }
        .trackRUMView(name: "TodayView")
        .onAppear() {
            // Make sure bluetooth is ok
            if isBluetoothPermissionGranted == false && showBluetoothNotAuthorized == false {
                logger.info("isBluetoothPermissionGranted (TodayView) == false")
                showBluetoothNotAuthorized = true
            }
            else if isBluetoothPoweredOn && showBluetoothPoweredOff == false {
                showBluetoothPoweredOff = true
            }

            modelData.rootViewId = UUID()
            
            modelData.networkManager.modelData = modelData

            if modelData.updateUserSuccess == false {
                // Update new values to server side
                let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)
            }
            else {
                // Pull latest user info from server
                modelData.networkManager.GetUserInfo()
            }

            if self.modelData.csvFileIsUploading == true {
                return
            }

            /*
            //UserDefaults.standard.removeObject(forKey: lastAppUpdateNotificationDateKey)    // debug - force check
            // Check for an AppStore update
            if let lastAlertDate = UserDefaults.standard.object(forKey: lastAppUpdateNotificationDateKey) as? Date {
                if Calendar.current.isDateInToday(lastAlertDate) {
                    print("App Update notification was shown today!")
                } else {
                    modelData.newAppVersionAvail.checkForAppUpdate(showLink: true)
                }
            } else {
                UserDefaults.standard.set(Date(), forKey: lastAppUpdateNotificationDateKey)
                modelData.newAppVersionAvail.checkForAppUpdate(showLink: true)
            }
            */
            
            if modelData.isCHDeviceConnected == false {
                return
            }
            
            if modelData.deviceUserInfoFailed == true {
                setUserInfoFailedDevicePairing()
            }

            // NOTE: The following code section is EXTREMELY critical, please DON'T MAKE ANY CHANGE!
            // Connect to the previously connected sensor if it's disconnected.
            if !BLEManager.bleSingleton.sensorConnected {
                // CH_ConnectedSensorUUID is set inn BLEManager
                guard let pairedSensorUUIDString = UserDefaults.standard.string(forKey: "CH_ConnectedSensorUUID") else {
                    
                    // TODO: Need to present pair screen
                    return
                }

                let pairedSensorUUID = UUID(uuidString: pairedSensorUUIDString)
                
                var connectedSensorUUIDList = [UUID]()
                connectedSensorUUIDList.append(pairedSensorUUID!)
                
                // Note: BLEManager takes some time to start and establish itself before the following function can be called, so start it in the next screen.
                let connectedSensorList = BLEManager.bleSingleton.centralManager.retrievePeripherals(withIdentifiers: connectedSensorUUIDList)
                
                // Note: Have to get a STRONG REFERENCE of the peripheral to make connection call, this is MUST HAVE!
                self.peripheralToConnect = connectedSensorList[0]
                
                BLEManager.bleSingleton.centralManager.stopScan()
                BLEManager.bleSingleton.centralManager.connect(self.peripheralToConnect!, options: nil)
            }
            else {
                // Pull system information right after the sensor connection,
                guard BLEManager.bleSingleton.sensorConnected == true else { return }
                guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
                
                let sensorFirmwareRev = Data(hexString: "50")
                peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
                peripheralConnected.writeValue(sensorFirmwareRev!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
                
                // Set timestamp on a sensor which is runnning already.
                modelData.ebsMonitor.setSweatSensingStartTimestamp()
                
                // Update sensor status immediately after screen switch.
                let sensorStatusUpdateOnDemand = Data(hexString: "51")
                peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
                peripheralConnected.writeValue(sensorStatusUpdateOnDemand!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
                
                // Start sweat data log downloading (from sensor) and uploading (to cloud) right after the screen appears the first time or screen switch.
                // Limit the frequency/rate of data sync while switching back to Today view to once per 30 seconds.
                let timeSinceLastFileUploading = (modelData.syncDate == nil) ? 3600 : Date().timeIntervalSince(modelData.syncDate!)
                print("Time since last data sync: \(timeSinceLastFileUploading)")
                if timeSinceLastFileUploading > 20.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        uploadCSVFileBackground()
                    }
                }
            }
        }
    }
    
    func setUserInfoFailedDevicePairing() {
        let gender = modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female"
        
        if modelData.unitsChanged == "0" {
            modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: modelData.userPrefsData.getUserWeight(), gender: gender, clothTypeCode: 0)
        }
        
        else {
            modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: modelData.userPrefsData.getUserWeight(), gender: gender, clothTypeCode: 0)
        }
    }
    
    func uploadCSVFileBackground() {
        if(modelData.sweatDataMultiDaySyncWithSensorCompleted && modelData.historicalSweatDataDownloadCompleted) {
            modelData.networkUploadSuccess = false
            modelData.networkManager.getNewRefreshToken()
            modelData.ebsMonitor.scanDeviceCurrentDayData()
        }
    }

}
