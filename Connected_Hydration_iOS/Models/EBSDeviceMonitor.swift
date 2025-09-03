//
//  EBSDeviceMonitor.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/5/23.
//

import SwiftUI
import Foundation
import BLEManager
import CoreBluetooth
import CoreNFC
import DGCharts
import AudioToolbox

import CryptoKit  // Required for SHA1 hashing

public struct historicalHydrationInfo {
    public var timeStamp: UInt16
    public var sweatVolumeDeficitInOz: Double
    public var sweatSodiumDeficitInMg: Int16
    public var sweatVolumeLossWholeBodyInOz: Double
    public var sweatSodiumLossWholeBodyInMg: UInt16
    public var fluidTotalIntakeInOz: Double
    public var sodiumTotalIntakeInMg: UInt16
    public var bodyTemperatureSkinInC: Double
    public var bodyTemperatureAirInC: Double
    public var activityCounts: UInt8
    
    // Initializer to create a historical record from a connectedHydrationInfo record.
    public init(_ info: connectedHydrationInfo) {
        self.timeStamp = info.timeStamp
        self.sweatVolumeDeficitInOz = info.sweatVolumeDeficitInOz
        self.sweatSodiumDeficitInMg = info.sweatSodiumDeficitInMg
        self.sweatVolumeLossWholeBodyInOz = info.sweatVolumeLossWholeBodyInOz
        self.sweatSodiumLossWholeBodyInMg = info.sweatSodiumLossWholeBodyInMg
        self.fluidTotalIntakeInOz = info.fluidTotalIntakeInOz
        self.sodiumTotalIntakeInMg = info.sodiumTotalIntakeInMg
        self.bodyTemperatureSkinInC = info.bodyTemperatureSkinInC
        self.bodyTemperatureAirInC = info.bodyTemperatureAirInC
        self.activityCounts = info.activityCounts
    }
    
    // Custom initializer
    public init(timeStamp: UInt16,
                sweatVolumeDeficitInOz: Double,
                sweatSodiumDeficitInMg: Int16,
                sweatVolumeLossWholeBodyInOz: Double,
                sweatSodiumLossWholeBodyInMg: UInt16,
                fluidTotalIntakeInOz: Double,
                sodiumTotalIntakeInMg: UInt16,
                bodyTemperatureSkinInC: Double,
                bodyTemperatureAirInC: Double,
                activityCounts: UInt8) {
        self.timeStamp = timeStamp
        self.sweatVolumeDeficitInOz = sweatVolumeDeficitInOz
        self.sweatSodiumDeficitInMg = sweatSodiumDeficitInMg
        self.sweatVolumeLossWholeBodyInOz = sweatVolumeLossWholeBodyInOz
        self.sweatSodiumLossWholeBodyInMg = sweatSodiumLossWholeBodyInMg
        self.fluidTotalIntakeInOz = fluidTotalIntakeInOz
        self.sodiumTotalIntakeInMg = sodiumTotalIntakeInMg
        self.bodyTemperatureSkinInC = bodyTemperatureSkinInC
        self.bodyTemperatureAirInC = bodyTemperatureAirInC
        self.activityCounts = activityCounts
    }
}

public struct CHNotifications {
    public static let SweatDataAvailable = "com.epicorebiosystems.connected-hydration.sweatdataavailable"
}

final class EBSDeviceMonitor: NSObject, ObservableObject {
    
    public var modelData: ModelData?
    
    let sweatUartServiceUUID = CBUUID(string: "4C570001-3033-4843-2045-524F43495045")
    let sweatUartRXCharacteristicUUID = CBUUID(string: "4C570002-3033-4843-2045-524F43495045")
    let sweatUartTXCharacteristicUUID = CBUUID(string: "4C570003-3033-4843-2045-524F43495045")
    
    let fluidBottleIncremental = 0.25
    let sodiumPackIncremental = 1.0
    
    var prevSweatDashboardViewStatus: UInt8 = 3
    
    // Set the data log file header before downloading starts in case there is an out of order packet which break the
    var sweatDataLogCSVText: String?
    var sweatDataLogStartEpochTimeString: String?
    var locationManager = LocationManager()
    
    var dataUploadTimoutWorkItem: DispatchWorkItem?
    
    /// Fast loading of chart data using sweat packets
    private var connectedHydrationHistoricalData : [historicalHydrationInfo] = []
    private var sweatDataAdded = false

    // Battery life in days lookup table
    // --------------------------- 0     1     2     3     4     5     6     7     8     9    10     11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35
    let batteryLifeLookUpTable = [1.90, 2.04, 2.27, 2.36, 2.42, 2.49, 2.53, 2.57, 2.59, 2.62, 2.64, 2.66, 2.67, 2.68, 2.69, 2.70, 2.71, 2.72, 2.73, 2.73, 2.74, 2.75, 2.75, 2.76, 2.77, 2.78, 2.79, 2.79, 2.80, 2.80, 2.80, 2.80, 2.80, 2.80, 2.81, 2.95]
    
    override init() {
        print("EBSDeviceMonitor init()")

        sweatDataAdded = false

        sweatDataLogCSVText = "TimeStamp(s),Data Type,Sweat Volume Loss Local (uL),Sweat Sodium Level (mM),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Ambient Temp (C),Activity Score,Batt Level(mV)\n"
    }
    
    public func start() {
        
        if (!modelData!.deviceMonitorStarted) {
            BLEManager.bleSingleton.startCentralManager()
            //BLEDataManager.shared.modelData = self.modelData!
            //BLEDataManager.shared.ebsMonitor = self
            //BLEDataManager.shared.start()

            // Clear the duplicates cache
            modelData!.uploadDataDuplicateHashDict.removeAll()

            connectedHydrationHistoricalData.removeAll()

            // Enable observers in GCD
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.DeviceStatusPacket), object: nil, queue: OperationQueue.main) { _ in self.printDeviceStatus() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SensorFwSysInfoPayload), object: nil, queue: OperationQueue.main) { _ in self.printFWRevision() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatDataLogDownloadResponse), object: nil, queue: OperationQueue.main) { _ in self.startSweatDataLogDownload() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatSensingStatusPayload), object: nil, queue: OperationQueue.main) { notification in self.updateSweatSensingInfo(notification) }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.ReportPeripheral), object: nil, queue: OperationQueue.main) { notification in self.updatePeripheralTable(notification) }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.DisconnectEvent), object: nil, queue: OperationQueue.main) { _ in self.peripheralDisconnected() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.ConnectEvent), object: nil, queue: OperationQueue.main) { _ in self.peripheralConnected() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.BLEPowerOnEvent), object: nil, queue: OperationQueue.main) { _ in self.autoDeviceScan() }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatDataWaveformPayload), object: nil, queue: OperationQueue.main) { notification in self.updateSweatDataWaveform(notification) }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatDataLogPayload), object: nil, queue: OperationQueue.main) { notification in self.updateSweatDataLog(notification) }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.IntakeLogResponse), object: nil, queue: OperationQueue.main) { _ in self.intakeLogged() }
            
            autoDeviceScan()
            
            dataUploadTimoutWorkItem = DispatchWorkItem {
                self.dataUploadTimeoutHandler()
            }
            
            modelData!.deviceMonitorStarted = true
            
        }
    }
    
    public func stop() {
        modelData!.deviceMonitorStarted = false
    }
    
    func saveFuildIntakeToDevice() {
        let fluidIntakeToRecordInMl = UInt16(truncatingIfNeeded: Int(modelData!.fluidIntakeInBottle * Double(modelData!.totalWaterAmount)))
        let sodiumIntakeToRecordInMg = UInt16(truncatingIfNeeded: Int(modelData!.sodiumIntakeInPack * Double(modelData!.totalSodiumAmount)))
        
        // Record the fluid and/or sodium intake to the sensor if they are not 0
        if (fluidIntakeToRecordInMl != 0 || sodiumIntakeToRecordInMg != 0) {
            
            let recordDataType = BLEManager.CH_RECORD_DATA_TYPE.EVENT_HYDRATION_INTAKE.rawValue
            let recordDataTyptData = withUnsafeBytes(of: recordDataType.littleEndian, Array.init)
            let fluidIntakeToRecordInMlData = withUnsafeBytes(of: fluidIntakeToRecordInMl.littleEndian, Array.init)
            let sodiumIntakeToRecordInMgData = withUnsafeBytes(of: sodiumIntakeToRecordInMg.littleEndian, Array.init)
            
            var recordIntakeCommand = Data(hexString: "57")!
            recordIntakeCommand += recordDataTyptData
            recordIntakeCommand += fluidIntakeToRecordInMlData
            recordIntakeCommand += sodiumIntakeToRecordInMgData
            
            guard BLEManager.bleSingleton.sensorConnected == true else { return }
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
            guard let rxCharacteristic = BLEManager.bleSingleton.rxCharacteristic else { return }
            peripheralConnected.setNotifyValue(true, for: rxCharacteristic)
            peripheralConnected.writeValue(recordIntakeCommand, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
        }
    }
    
    func saveUserInfo(feet: String, inches: String, weight: String, gender: String, clothTypeCode: Int) {
        if feet != "" && inches != "" && weight != "" {   // If the text is not blank
            
            let paddedSize = 16
            let paddedHexZeros = [UInt8](repeating: 0xFF, count: paddedSize)   // Create the padded array of trailing 0x00's
            
            let userHeightInInches : UInt8 = UInt8(round(Double(feet)!)) * 12 + UInt8(round(Double(inches)!))
            
            let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))
            
            let userHeightInCmData = withUnsafeBytes(of: userHeightInCms, Array.init)
            
            var userWeightInLbs : UInt16 = UInt16(truncatingIfNeeded: Int(round(Double(weight)!)))
            
            // Limit the minimum user weight to 50lb to prevent unexpected behavior.
            if userWeightInLbs < 50 {
                userWeightInLbs = 50
            }
            
            let userWeightInKgs : UInt16 = UInt16(truncatingIfNeeded: Int(round(Double(userWeightInLbs)*0.453592)))
            
            let userWeightInKgData = withUnsafeBytes(of: userWeightInKgs.littleEndian, Array.init)
            
            let userGenderData = gender == "Male" ? [UInt8(0)] : [UInt8(1)]
            
            let userAge : UInt8 = 0
            
            let userAgeData = [userAge]
            
            let userClothTypeCode = UInt8(clothTypeCode)
            let userClothTypeCodeData = [userClothTypeCode]
            
            var setUserInfoCommand = Data(hexString: "55")! /*+ subjectIDData!*/ + paddedHexZeros
            
            setUserInfoCommand += userGenderData
            setUserInfoCommand += userHeightInCmData
            setUserInfoCommand += userWeightInKgData
            setUserInfoCommand += userAgeData
            setUserInfoCommand += userClothTypeCodeData

            BLEManager.bleSingleton.setSubjectBSA(heightCm: Int(userHeightInCms), weightKg: Int(userWeightInKgs))
            
            guard BLEManager.bleSingleton.sensorConnected == true else {
                modelData?.deviceUserInfoFailed = true
                logger.error("EBSDeviceMonitor", attributes: ["error": "saveUserInfo_imperial_failed"])
                return
            }
            
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
            guard let txCharacteristic = BLEManager.bleSingleton.txCharacteristic else { return }
            print("To write: " + " " + feet + " " + inches + " " + weight + " " + gender +  " " + "\(userClothTypeCode)")
            peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected.writeValue(setUserInfoCommand, for: txCharacteristic, type: .withoutResponse)
            print("Saving User Information Command")
        }
    }
    
    func saveUserInfoMetric(heightInCm: String, weightInKg: String, gender: String, clothTypeCode: Int) {
        if heightInCm != "" && weightInKg != "" {   // If the text is not blank
            
            let paddedSize = 16
            let paddedHexZeros = [UInt8](repeating: 0xFF, count: paddedSize)   // Create the padded array of trailing 0x00's
            
            let userHeightInCms : UInt8 = UInt8(heightInCm) ?? 170
            
            let userHeightInCmData = withUnsafeBytes(of: userHeightInCms, Array.init)
            
            // Limit the minimum user weight to 50lb to prevent unexpected behavior.
            let userWeightInKgs : UInt16 = UInt16(weightInKg) ?? 60
            
            let userWeightInKgData = withUnsafeBytes(of: userWeightInKgs.littleEndian, Array.init)
            
            let userGenderData = gender == "Male" ? [UInt8(0)] : [UInt8(1)]
            
            let userAge : UInt8 = 0
            
            let userAgeData = [userAge]
            
            let userClothTypeCode = UInt8(clothTypeCode)
            let userClothTypeCodeData = [userClothTypeCode]
            
            var setUserInfoCommand = Data(hexString: "55")! /*+ subjectIDData!*/ + paddedHexZeros
            
            setUserInfoCommand += userGenderData
            setUserInfoCommand += userHeightInCmData
            setUserInfoCommand += userWeightInKgData
            setUserInfoCommand += userAgeData
            setUserInfoCommand += userClothTypeCodeData
            
            BLEManager.bleSingleton.setSubjectBSA(heightCm: Int(userHeightInCms), weightKg: Int(userWeightInKgs))
            
            guard BLEManager.bleSingleton.sensorConnected == true else {
                modelData?.deviceUserInfoFailed = true
                logger.error("EBSDeviceMonitor", attributes: ["error": "saveUserInfo_metric_failed"])
                return
            }
            
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
            print("To write: " + " " + heightInCm + " " + weightInKg + " " + gender +  " " + "\(userClothTypeCode)")
            peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected.writeValue(setUserInfoCommand, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
            print("Saving User Information Command")
        }
    }
    
    public func scanDeviceCurrentDayData() {
        // Already downloading
        if BLEManager.bleSingleton.sweatDataLogDownloadCompleted == false {
            return
        }
            
        // This would start the multi-day data sync between sensor, app and cloud, start with the current day's data.
        guard BLEManager.bleSingleton.sensorConnected == true else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "scandevicedata_sensor_not_connected"])
            return
        }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "scandevicedata_lost_connection"])
            return
        }
        
        // Set the header of data file based on type of module connected and get ready for data download.
        sweatDataAdded = false
        
        if(modelData!.isCHArmBandConnected) {
            // Before starting a new multi-day data sync, reset the data log file header to get ready for next upload in case the previous data downloading is not completed due to abrupt disconnection or timeout.
            sweatDataLogCSVText = "TimeStamp(s),Data Type,Large Skin Electrode Voltage (scaled mV),Zero Depth Electrode Voltage (mV),Sweat Sodium Level (mM),Well Voltage (scaled mV),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Activity Score,Batt Level(mV)\n"
        }
        
        else {
            // Before starting a new multi-day data sync, reset the data log file header to get ready for next upload in case the previous data downloading is not completed due to abrupt disconnection or timeout.
            sweatDataLogCSVText = "TimeStamp(s),Data Type,Sweat Volume Loss Local (uL),Sweat Sodium Level (mM),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Ambient Temp (C),Activity Score,Batt Level(mV)\n"
        }

        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        //peripheralConnected.writeValue(Data([0x52, 0xA5]), for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
        peripheralConnected.writeValue(Data([0x52, 0x00]), for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)

        modelData!.sweatDataPreviousDayDownloadingCompleted = false
        modelData!.sweatDataMultiDaySyncWithSensorCompleted = false
        
        print("Data uploading start time: " + generateCurrentTimeStamp())
        
        // Add a timeout here for the data downloading/uploading so that it won't hang the system.
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: dataUploadTimoutWorkItem!)
    }
    
    public func scanDeviceData() {
        // Already downloading
        if BLEManager.bleSingleton.sweatDataLogDownloadCompleted == false {
            return
        }

        guard BLEManager.bleSingleton.sensorConnected == true else { return }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        peripheralConnected.writeValue(Data([0x52, 0xA5]), for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
    }

    func setSweatSensingStartTimestamp() {
        guard BLEManager.bleSingleton.sensorConnected == true else { return }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
            print("Lost connection.")
            logger.error("EBSDeviceMonitor", attributes: ["error": "setSweatSensingStartTimestamp_lost_connection"])
            return
        }

        // Send the current unix epoch timestamp (in seconds) in UInt32 format to the device
        let byteCommand = UInt32(NSDate().timeIntervalSince1970)
        let byteCommandIntBigEndian = UInt32(bigEndian: byteCommand)
        let byteCommandHex = "54" + String(format: "%08X", byteCommandIntBigEndian)     // Little Endian format on the peripheral device
                
        // Add user ID and site ID here in the command as session meta data
        let userIDShort = ((modelData?.CH_UserID)!.count < 8) ? "        " : (modelData?.CH_UserID)!.prefix(8)
        let userIDData = userIDShort.data(using: .ascii) // Convert string into Data type with ascii values
        

        let siteIDData = (modelData?.enterpriseSiteCode)!.data(using: .ascii)
        let siteIDPaddedSize = siteIDData!.count < 12 ? 12-siteIDData!.count : 0  // Calculating size of the trailing 0x00's
        let siteIDPaddedHexZeros = [UInt8](repeating: 0, count: siteIDPaddedSize)   // Create the padded array of trailing 0x00's

        let timeStampUpdate = Data(hexString: byteCommandHex)! + userIDData! + siteIDData! + siteIDPaddedHexZeros
        
        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        peripheralConnected.writeValue(timeStampUpdate, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
    }
    
    func autoDeviceScan() {
        if (BLEManager.bleSingleton.centralManager.state != .poweredOn)
        {
            print("Bluetooth Radio is OFF.")
            logger.error("EBSDeviceMonitor", attributes: ["error": "autoDeviceScan_bluetooth_off"])
            return
        }
        
        // Perform BLE scan in the background thread
        DispatchQueue.global(qos: .background).sync {
            BLEManager.bleSingleton.centralManager.scanForPeripherals(withServices: [sweatUartServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(value: true)])
        }
    }
    
    // Brief: method to perforam BLE scanning with error handling if BLE is not enabled
    func deviceScan() {
        if (BLEManager.bleSingleton.centralManager.state != .poweredOn)
        {
            print("Bluetooth Radio is OFF.")
            logger.error("EBSDeviceMonitor", attributes: ["error": "deviceScan_bluetooth_off"])
            return
        }
        
        // Perform BLE scan in the background thread
        DispatchQueue.global(qos: .background).sync {
            BLEManager.bleSingleton.centralManager.scanForPeripherals(withServices: [sweatUartServiceUUID])
        }
    }
    
    // Brief: Updates the table of available BLE peripherals
    func updatePeripheralTable(_ notification: Notification) {
        print("updatePeripheralTable()")
        if let data = notification.userInfo as? [String: Int] {
            if let deviceIndex = data["TableRowIndex"] {
                if deviceIndex >= 0 {
                    /*
                     print("data[TableRowIndex] == \(deviceIndex)")
                     print("BLEManager.bleSingleton.peripheralTableCellArray.count == \(BLEManager.bleSingleton.peripheralTableCellArray.count)")
                     print("Device name: " + BLEManager.bleSingleton.peripheralTableCellArray[0].name)
                     if BLEManager.bleSingleton.peripheralTableCellArray[0].MAC.count > 0 {
                     print("Device MAC: " + BLEManager.bleSingleton.peripheralTableCellArray[0].MAC)
                     }
                     else {
                     print("No MAC address advertisment data")
                     }
                     print("Device RSSI: " + BLEManager.bleSingleton.peripheralTableCellArray[0].RSSI)
                     print("Device SweatVolumeLoss: " + BLEManager.bleSingleton.peripheralTableCellArray[0].SweatVolumeLoss)
                     print("Device SweatSodiumLoss: " + BLEManager.bleSingleton.peripheralTableCellArray[0].SweatSodiumLoss)
                     
                     // Put devices found into published array in modelData object
                     //modelData!.CHDeviceArray.append(contentsOf: BLEManager.bleSingleton.peripheralTableCellArray)
                     */
                    modelData!.CHDeviceArray = BLEManager.bleSingleton.peripheralTableCellArray
                    //print("modelData!.CHDeviceArray == \(modelData!.CHDeviceArray.count)")
                }
            }
        }
    }
    
    // Brief: Displays UI alert when the peripheral disconnects (either through BLE disconnect even or peripheral turns off)
    func peripheralDisconnected() {
        print("CH Sensor Disconnected...")
        modelData!.isCHDeviceConnected = false
        
        // Clear historical sweat data buffer
        DispatchQueue.global(qos: .background).sync {
            BLEManager.bleSingleton.clearHistoricalSweatDataBuffer()
        }
        
        // This is a user forced disconnect action
        if(BLEManager.bleSingleton.forcedDisconnect) {
            print("Disconnected by user!")
            logger.error("EBSDeviceMonitor", attributes: ["error": "peripheralDisconnected_forced_diconnected"])

            BLEManager.bleSingleton.forcedDisconnect = false
            
            autoDeviceScan()
        }
        
        // This is a disconnection due to poor signal, try to reconnct to the sensor previously connected
        else {
            print("Disconnected due to poor signal, attemp to reconnect!")
            logger.error("EBSDeviceMonitor", attributes: ["error": "peripheralDisconnected_diconnected_poor_signal"])

            let peripheralReference = BLEManager.bleSingleton.peripheralToConnect
            BLEManager.bleSingleton.centralManager.connect(peripheralReference!)
        }
        
        // Clear all the flags for downloading and uploading upon disconnection.
        modelData!.sweatDataPreviousDayDownloadingCompleted = true
        modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
        
        modelData!.historicalSweatDataDownloadCompleted = true
        
        // Clear duplciates cache when device disconnects
        modelData!.uploadDataDuplicateHashDict.removeAll()

        sweatDataAdded = false

        // Reset the data log file header to get ready for next upload in case of abrupt disconnection while downloading is ongoing.
        if(modelData!.isCHArmBandConnected) {
            sweatDataLogCSVText = "TimeStamp(s),Data Type,Large Skin Electrode Voltage (scaled mV),Zero Depth Electrode Voltage (mV),Sweat Sodium Level (mM),Well Voltage (scaled mV),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Activity Score,Batt Level(mV)\n"
        }
        
        else {
            sweatDataLogCSVText = "TimeStamp(s),Data Type,Sweat Volume Loss Local (uL),Sweat Sodium Level (mM),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Ambient Temp (C),Activity Score,Batt Level(mV)\n"
        }
        modelData!.csvFileIsUploading = false
        BLEManager.bleSingleton.sweatDataLogDownloadCompleted = true
        
    }
    
    // Brief: Displays UI alert when the peripheral disconnects (either through BLE disconnect even or peripheral turns off)
    func peripheralConnected() {
        print("CH Sensor Connected!")
        modelData!.isCHDeviceConnected = true
        let peripheralReference = BLEManager.bleSingleton.peripheralToConnect
        modelData!.pairCHDeviceSN = peripheralReference?.name ?? ""
        print("Paired Device Name: " + modelData!.pairCHDeviceSN)
        
//        // Check sensor firmware revision and user info
        let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect
        let getFirmwareRevisionCommand = Data(hexString: "50")
        peripheralConnected?.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        peripheralConnected?.writeValue(getFirmwareRevisionCommand!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
        print("Sent Get FW Rev Command")
        
        if(modelData!.isOnboardingComplete)
        {
//            let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect
//            let getFirmwareRevisionCommand = Data(hexString: "50")
//            peripheralConnected?.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
//            peripheralConnected?.writeValue(getFirmwareRevisionCommand!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
//            print("Sent Get FW Rev Command")
            
            // Set sweat sensing start timestamp right after connection.
            setSweatSensingStartTimestamp()
            print("Set start timestamp on sensor")
            
            // Update user physiology info after connection is established in case a different return user uses the same module. This is necessary after each session has its separate user physiology info.
            let gender = modelData!.userPrefsData.getUserGender() == "M" ? "Male" : "Female"
            
            if modelData!.unitsChanged == "0" {
                modelData!.ebsMonitor.saveUserInfoMetric(heightInCm: modelData!.userPrefsData.getUserHeightCm(), weightInKg: modelData!.userPrefsData.getUserWeight(), gender: gender, clothTypeCode: 0)
            }
            
            else {
                modelData!.ebsMonitor.saveUserInfo(feet: modelData!.userPrefsData.getUserHeightInFt(), inches: modelData!.userPrefsData.getUserHeightIn(), weight: modelData!.userPrefsData.getUserWeight(), gender: gender, clothTypeCode: 0)
            }
            
            // Set button press water intake volume
            setButtonPressWaterIntakeVolumeInMl()
            
            // Update sensor status immediately after connection or re-connection.
            let sensorStatusUpdateOnDemand = Data(hexString: "51")
            peripheralConnected?.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected?.writeValue(sensorStatusUpdateOnDemand!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
            
//            // Clear duplciates cache when device re-connects in case the cashe was not cleared after prior disconnection if the disconnection event was not captured due to unexpected reasons.
//            // This would also clear the cache when connected to a new sensor.
//            modelData!.uploadDataDuplicateHashDict.removeAll()
//            
//            // Reset all data downloading flags upon connection/reconnection in case these flags were not reset due to unexpected exit or abruupt disconnection.
//            modelData!.sweatDataPreviousDayDownloadingCompleted = true
//            modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
//            modelData!.historicalSweatDataDownloadCompleted = true
//            BLEManager.bleSingleton.sweatDataLogDownloadCompleted = true
//
//            // Start data sync right after sensor is connected.
////            if(modelData!.sweatDataMultiDaySyncWithSensorCompleted && modelData!.historicalSweatDataDownloadCompleted) {
//                modelData!.networkManager.getNewRefreshToken()
//                modelData!.ebsMonitor.scanDeviceCurrentDayData()
////            }
            
        }
    }
    
    // Brief: Method to stop BLE scanning and perform a BLE eonnection to the peripheral selected in the table
    func connectToPeripheral() {
        if(!BLEManager.bleSingleton.sensorConnected) {
            
            if BLEManager.bleSingleton.peripheralNextFlex.count < 1 {
                return
            }
            for peripheral in BLEManager.bleSingleton.peripheralNextFlex {
                if peripheral.name == modelData?.pairedCHDevice.name {
                    BLEManager.bleSingleton.centralManager.stopScan()
                    BLEManager.bleSingleton.centralManager.connect(peripheral)
                    break
                }
            }
        }
    }
    
    func forceDisconnectFromPeripheral() {
        // Force disconnect from sensor to re-pair
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "forceDisconnectFromPeripheral_lost_connection"])
            return
        }
        BLEManager.bleSingleton.centralManager.cancelPeripheralConnection(peripheralConnected)   //Disconnect from peripheral
        BLEManager.bleSingleton.forcedDisconnect = true
    }
    
    // Brief: Method to update the sensor system status
    func updateSweatSensingInfo(_ notification : Notification) {

        if let data = notification.userInfo as? [String: sweatStatusPacket] {
            
            let sweatSensingStatus = data["sweatStatusPacket"]!
            
            modelData!.chDeviceBatteryLvl = getBatteryLifeLeftInDays(battLevelInV: sweatSensingStatus.batteryVoltageInV)
            
            // Check water bottle size and sodium pack size before updating display with new sweat status
            if modelData!.CH_FluidBottleSizeInMl == 0 {
                modelData!.CH_FluidBottleSizeInMl = 500
            }
            
            if modelData!.CH_SodiumPackSizeInMg == 0 {
                modelData!.CH_SodiumPackSizeInMg = 220
            }
            
            modelData!.fluidTotalIntakeInMl = Int16(sweatSensingStatus.fluidTotalIntakeInMl)
            modelData!.sodiumTotalIntakeInMg = Int16(sweatSensingStatus.sodiumTotalIntakeInMg)
            
            // Limit the deficit display to only non-negative numbers.
            if(sweatSensingStatus.fluidDeficitInOz <= 0) {
                modelData!.fluidDeficitToDisplayInBottle = 0.0
                modelData!.fluidDeficitToDisplayInOz = 0.0
                modelData!.sweatVolumeDeficit = "0.0"
                
                modelData!.fluidDeficitToDisplayInMl = 0
            }
            else {
                modelData!.fluidDeficitToDisplayInOz = sweatSensingStatus.fluidDeficitInOz
                modelData!.fluidDeficitToDisplayInBottle = round((Double(Int(Double(sweatSensingStatus.sweatVolumeDeficitInMl) / (Double(modelData!.CH_FluidBottleSizeInMl) * fluidBottleIncremental)) + 1) / 4.0) * 100) / 100
                modelData!.sweatVolumeDeficit = String(format: "%.1f", modelData!.fluidDeficitToDisplayInOz)
                
                modelData!.fluidDeficitToDisplayInMl = sweatSensingStatus.sweatVolumeDeficitInMl
            }
            
            // Sodium deficit
            if (sweatSensingStatus.sweatSodiumDeficitInMg <= 0) {
                modelData!.sodiumDeficitToDisplayInPack = 0
                modelData!.sodiumDeficitToDisplayInMg = 0
                modelData!.sweatSodiumDeficit = "0.0"
            }
            else {
                modelData!.sodiumDeficitToDisplayInMg = sweatSensingStatus.sweatSodiumDeficitInMg
                modelData!.sodiumDeficitToDisplayInPack = round((Double(Int(Double(sweatSensingStatus.sweatSodiumDeficitInMg) / (Double(modelData!.CH_SodiumPackSizeInMg) * sodiumPackIncremental)) + 1)) * 10) / 10
                modelData!.sweatSodiumDeficit = "\(modelData!.sodiumDeficitToDisplayInMg)"
            }
            
            modelData!.sweatVolumeTotalLoss = String(format: "%.1f", sweatSensingStatus.sweatVolumeTotalLossInOz)
            modelData!.sweatSodiumTotalLoss = "\(sweatSensingStatus.sweatSodiumTotalLossInMg)"
            
            modelData!.fluidTotalLossToDisplayInMl = Int16(sweatSensingStatus.sweatVolumeTotalLossInMl)
            
            modelData!.currentTEWLInMl = sweatSensingStatus.currentTEWLInMl
            modelData!.fluidTotalLossFromSweatInMl = Int(modelData!.fluidTotalLossToDisplayInMl) - modelData!.currentTEWLInMl
            
            if((modelData!.fluidTotalLossToDisplayInMl >= 10000) && (modelData!.capSodiumValue == 0)) {
                modelData!.capSodiumValue = Int(sweatSensingStatus.sweatSodiumTotalLossInMg)
            }

            // If total sweat volume loss is less than 10L and the sodium was set before, this mean that a new session started and the sodium cap needs to be reset
            else if((sweatSensingStatus.sweatVolumeTotalLossInMl  < 10000) && modelData!.capSodiumValue != 0) {
                modelData!.capSodiumValue = 0
            }

            checkStatusChange(status: sweatSensingStatus.hydrationStatus)
            
            switch sweatSensingStatus.hydrationStatus {
            case 0:
                modelData!.sweatDashboardViewStatus = 0
            case 1:
                modelData!.sweatDashboardViewStatus = 1
            case 2:
                modelData!.sweatDashboardViewStatus = 2
            default:
                modelData!.sweatDashboardViewStatus = 0
            }
            
            modelData!.alarmCount = Int(sweatSensingStatus.alertStatus)
            
            if(modelData!.isOnboardingComplete)
            {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    
                    // Retrieve logged historical sweat data from sensor when there is no ongoing data retrival process.
                    if (self.modelData!.historicalSweatDataDownloadCompleted && self.modelData!.sweatDataMultiDaySyncWithSensorCompleted) {
                                                
                        guard BLEManager.bleSingleton.sensorConnected == true else {
                            logger.error("EBSDeviceMonitor", attributes: ["error": "updateSweatSensingInfo_sensor_disconnected"])
                            return
                        }
                        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
                            logger.error("EBSDeviceMonitor", attributes: ["error": "updateSweatSensingInfo_lost_connection"])
                            return
                        }
                        
                        let byteCommandIntBigEndian = UInt16(bigEndian: BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex)
                        let byteCommandHex = "525A" + String(format: "%04X", byteCommandIntBigEndian)     // Little Endian format on the peripheral device
                        let startHisoricalDataDownload = Data(hexString: byteCommandHex)
                        //                let startHisoricalDataDownload = Data(hexString: "525A0000")
                        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
                        peripheralConnected.writeValue(startHisoricalDataDownload!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
                        
                        self.modelData!.historicalSweatDataDownloadCompleted = false
                        
                        print(BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex)
                        
                        // Add a timeout here for the data downloading/uploading so that it won't hang the system.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            if(self.modelData!.historicalSweatDataDownloadCompleted == false) {
                                self.modelData!.historicalSweatDataDownloadCompleted = true
                            }
                        }
                        
                    }
                }
                
            }
            
            modelData!.deviceStatusText = "OK"
        }
    }
    
    func checkStatusChange(status: UInt8) {
        if prevSweatDashboardViewStatus != status {

            switch status {
            case 0:
                logger.info("Hydration status OK")
            case 1:
                logger.info("Hydration status AT RISK")
            case 2:
                logger.info("Hydration status DEHYDRATED")
            default:
                print()
            }

            prevSweatDashboardViewStatus = status
        }
    }

    // Brief: Method to display the IMU data (i.e. Accel) on the appropriate LineChart object
    func updateSweatDataWaveform(_ notification : Notification)
    {
        if let data = notification.userInfo as? [String: sweatDataWaveformPacket] {
            if let packet = data["sweatDataWaveformPacket"] {
                
                /**** Functional Code ****/
                let waveformSamples = packet.sweatDataWaveformSamplesInMv
                
                // Defining chart line arrays
                var lineChartEntrySweatSamples = [ChartDataEntry]()
                
                var waveformSamplesAvg : Double = 0.0
                var waveformSampleMin: Int = 3000
                var waveformSampleMax: Int = 0
                
                /**** Adding datapoints to line arrays ****/
                for i in 0...(sweatDataWaveformSampleCount-1) {
                    waveformSamplesAvg += (Double(waveformSamples[i])/Double(sweatDataWaveformSampleCount))
                    
                    if waveformSamples[i] > waveformSampleMax  {
                        waveformSampleMax = waveformSamples[i]
                    }
                    
                    if waveformSamples[i] < waveformSampleMin {
                        waveformSampleMin = waveformSamples[i]
                    }
                    
                    lineChartEntrySweatSamples.append(ChartDataEntry(x: Double(i), y: Double(waveformSamples[i])/1000.0))
                }
                
                // Update sensing status based on the waveform data
                if waveformSamplesAvg < 1550.0 && waveformSamplesAvg > 1450.0 && waveformSampleMin > 100 && waveformSampleMax < 2900 {
                    //sensingStatusLabel.text = "OK"
                }
                
                /******************************************/
                modelData!.sensorWaveformChartData = LineChartData() // Declaring data for Chart
                
                let lineX = LineChartDataSet(entries: lineChartEntrySweatSamples, label: "V")
                lineX.drawCirclesEnabled = false;
                lineX.colors = [NSUIColor.blue]
                modelData!.sensorWaveformChartData.append(lineX)    // Adds the line to the dataSet
                
                /**** Plot Data ****/
                modelData!.sensorWaveformChartData.setDrawValues(false) // Adds chart data to the chart and causes an update
            }
        }
    }

    func startSweatDataLogDownload() {
        modelData!.sweatDataLogStartEpochTimeString = generateTimeStampStringFromEpoch(epochTime: Double(BLEManager.bleSingleton.sweatDataLogStartEpochTime))
        modelData!.isSweatDataDownloadProgressAlertShowing = true
    }

    func updateSweatDataLog(_ notification : Notification) {
        if let data = notification.userInfo as? [String: sweatDataLogPacket] {
            if let sweatDataLogPacket = data["sweatDataLogPacket"] {
/*
                //BLEManager.bleSingleton.sensorResetReason = 11    // used to test notification for Error Type 11
                // Handle letting user know there is an Event Type 11 (Error) on device and they need to change out there patch
                if (BLEManager.bleSingleton.sensorResetReason != 0xFFFFFFFF && BLEManager.bleSingleton.sensorResetReason == 11) {
                    if (modelData!.showNotification == false) {
                        modelData!.notificationData = NotificationModifier.NotificationData(id: bleErrorCode_11_Notification, title: "Error", detail: "The CH BLE Device has detected an issue. The currently attached patch already has sweat in it. Either dry off completely and apply a new patch or start again tomorrow.", type: .Error, notificationLocation: .Top, showOnce: false, showSeconds: ShowOptions.showNoClose)
                        modelData!.showNotification = true
                    }
                }
                else {
                    if modelData!.notificationData.id == bleErrorCode_11_Notification {
                        modelData!.showNotification = false
                    }
                }
*/
                var sweatDataString = ""

                // End of sweat data log is reached, save all the buffered data from downloading to a CSV file
                if (sweatDataLogPacket.timeStamp == 0xFFFF && (!BLEManager.bleSingleton.sweatDataLogDownloadCompleted)) {
                    
                    BLEManager.bleSingleton.sweatDataLogDownloadCompleted = true

                    if modelData!.sweatDataPreviousDayDownloadingCompleted == false && modelData!.isCurrentUserSession && BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex <= 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CHNotifications.SweatDataAvailable), object: nil)
                    }

                    let v2FileFormatHeader = "CH3 DataFile Revision,,,,,,,,,,,\n" + (modelData!.isCHArmBandConnected ? "4" : "3") + ",,,,,,,,,,,\n" + ",,,,,,,,,,,\n"

                    // Add the log start Epoch time at the end of the data file
                    let startEpochTimeHeaderString = "\nSweat Log Start Epoch Time (s),Sweat Log Start Local Time,Log Duration (s)"
                    let startEpochTimeString = "\(BLEManager.bleSingleton.sweatDataLogStartEpochTime)" + "," + (modelData!.sweatDataLogStartEpochTimeString ?? "0") + "," + "\(BLEManager.bleSingleton.logDurationInSeconds)"
                    
                    let sensorSubjectSiteIDHeaderString = "Sensor ID,User ID,Enterprise and Site Code"
                    let enterpriseAndSiteID = modelData!.enterpriseSiteCode

                    let userID = (modelData?.CH_UserID)!
                    let sendsorSubjectSiteIDString = modelData!.pairCHDeviceSN + "," + userID + "," + enterpriseAndSiteID
                        
                    let subjectLocationHeaderStringV2 = "Current location latitude,Current location longtitude,,,,,,,,,,\n"
                    let subjectLocationStringV2 = "\(locationManager.lastLocation?.coordinate.latitude ?? 0)" + "," + "\(locationManager.lastLocation?.coordinate.longitude ?? 0)" + ",,,,,,,,,,\n"

                    let subjectLocationHeaderString = "Location latitude,Location longtitude"
                    let subjectLocationString = "\(locationManager.lastLocation?.coordinate.latitude ?? 0)" + "," + "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"

                    let subjectPhysiologyDataHeaderString = "Clothing,Height (cm),Weight (kg),Biological Sex"
                    let subjectClothingType = "N/A"
                    let subjectPhysiologyDataString = subjectClothingType + "," + "\(BLEManager.bleSingleton.sweatDataLogSessionUserHeigthtInCm)" + "," + "\(BLEManager.bleSingleton.sweatDataLogSessionUserWeightInKg)" + "," + BLEManager.bleSingleton.sweatDataLogSessionUserGender
                    
                    // Firmware and app version/build information
                    let versionHeader = "Sensor hardware version,Sensor firmware version,App version,Phone model,Phone OS version"
                    let sensorHardwareVersionString = "3"
                    let sensorFirmwareVersionString = BLEManager.bleSingleton.firmwareRevString
                    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                    let appBuildVersionString = "v" + appVersion + " build " + buildNumber
                    let phoneModelString = UIDevice.modelName
                    let phoneOSString = UIDevice.current.systemName + UIDevice.current.systemVersion
                    
                    let versionString = sensorHardwareVersionString + "," + sensorFirmwareVersionString + "," + appBuildVersionString + "," + phoneModelString + "," + phoneOSString
                    
                    // Append sensor reset reason at the end if an unexpected reset occured during recording
                    var sensorResetDebugHeader = ""
                    var sensorResetDebugString = ""
                    if (BLEManager.bleSingleton.sensorResetReason != 0xFFFFFFFF) {
                        sensorResetDebugHeader = "Sensor Reset Reason Code"
                        sensorResetDebugString = "\(BLEManager.bleSingleton.sensorResetReason)"
                        
                        if (BLEManager.bleSingleton.sensorResetErrorId != 0xFFFFFFFF) {
                            sensorResetDebugHeader += "," + "Reset Error ID"
                            sensorResetDebugString += "," + "\(BLEManager.bleSingleton.sensorResetErrorId)"
                            
                            if (BLEManager.bleSingleton.sensorResetErrorCode != 0xFFFFFFFF) {
                                sensorResetDebugHeader += "," + "Reset Error Code" + "," + "Reset Line Number" + "," + "Reset File Name"
                                sensorResetDebugString += "," + "\(BLEManager.bleSingleton.sensorResetErrorCode)" + "," + "\(BLEManager.bleSingleton.sensorResetErrorLineNum)" + "," + BLEManager.bleSingleton.sensorResetErrorFileName
                                
                            }
                        }
                    }

                    //print("*** versionString = \(versionString)")
                    //print("*** startEpochTimeString = \(startEpochTimeString)")

                    let sweatLogMetaDataString = v2FileFormatHeader + subjectLocationHeaderStringV2 +
                    subjectLocationStringV2 + ",,,,,,,,,,," + startEpochTimeHeaderString + "," + sensorSubjectSiteIDHeaderString + "," + subjectLocationHeaderString + "," + subjectPhysiologyDataHeaderString + "\n" +
                    startEpochTimeString + "," + sendsorSubjectSiteIDString + "," + subjectLocationString + "," + subjectPhysiologyDataString + "\n" +
                    versionHeader + "," + sensorResetDebugHeader + "\n" +
                    versionString + "," + sensorResetDebugString + "\n" + ",,,,,,,,,,,\n"

                    // Remove new line at end of file
                    let removeNewline = Array(sweatDataLogCSVText!)[sweatDataLogCSVText!.count - 1]
                    if removeNewline == "\n" {
                        sweatDataLogCSVText!.remove(at: sweatDataLogCSVText!.index(before: sweatDataLogCSVText!.endIndex))
                    }

                    // **** Handle file upload to server
                    let sweatDataLogFileIDString = BLEManager.bleSingleton.subjectID + "_" + modelData!.pairCHDeviceSN
                    modelData!.sweatDataLogFileName = "sweatLog_" + sweatDataLogFileIDString + "_" + generateCurrentTimeStamp() + ".csv"
                    modelData!.sweatDataLogFileURL = getLocalDocumentsDirectory().appendingPathComponent(modelData!.sweatDataLogFileName)
                    let fullSweatDataLogCSVText = sweatLogMetaDataString + sweatDataLogCSVText!
                    do {
                        try fullSweatDataLogCSVText.write(to: modelData!.sweatDataLogFileURL, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        print("Failed to create/write sweat upload file")
                        print("\(error)")
                        logger.error("updateSweatDataLog", attributes: ["issue" : "Failed to create/write sweat upload file", "fileName": modelData!.sweatDataLogFileName , "error" : error.localizedDescription])
                    }
                    // **********

//                    // ***** Sharing file - Has to be separate file now that background uploading
//                    let shareDataLogFileIDString = BLEManager.bleSingleton.subjectID + "_" + modelData!.pairCHDeviceSN
//                    let shareDataLogFileName = "shareLog_" + shareDataLogFileIDString + "_" + generateCurrentTimeStamp() + ".csv"
//                    modelData!.shareDataLogFileURL = getLocalDocumentsDirectory().appendingPathComponent(shareDataLogFileName)
//                    let shareDataLogCSVText = sweatLogMetaDataString + sweatDataLogCSVText!
//                    do {
//                        try shareDataLogCSVText.write(to: modelData!.shareDataLogFileURL, atomically: true, encoding: String.Encoding.utf8)
//                    } catch {
//                        print("Failed to create/write share file")
//                        print("\(error)")
//                        logger.error("updateSweatDataLog", attributes: ["issue" : "Failed to create/write share file", "fileName": modelData!.sweatDataLogFileName , "error" : error.localizedDescription])
//                    }
//                    // **********
                        
                    // Reset the data log file header to get ready for next upload.
                    if(modelData!.isCHArmBandConnected) {
                        // Before starting a new multi-day data sync, reset the data log file header to get ready for next upload in case the previous data downloading is not completed due to abrupt disconnection or timeout.
                        sweatDataLogCSVText = "TimeStamp(s),Data Type,Large Skin Electrode Voltage (scaled mV),Zero Depth Electrode Voltage (mV),Sweat Sodium Level (mM),Well Voltage (scaled mV),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Activity Score,Batt Level(mV)\n"
                    }
                    
                    else {
                        // Before starting a new multi-day data sync, reset the data log file header to get ready for next upload in case the previous data downloading is not completed due to abrupt disconnection or timeout.
                        sweatDataLogCSVText = "TimeStamp(s),Data Type,Sweat Volume Loss Local (uL),Sweat Sodium Level (mM),Recommended fluid intake (mL),Recommended sodium intake (mg),Total sweat loss (mL),Total sodium loss (mg),TEWL (mL), Body Temp (C),Ambient Temp (C),Activity Score,Batt Level(mV)\n"
                    }
                    
                    /*
                    print("sweatDataLogSessionUserID = \(BLEManager.bleSingleton.sweatDataLogSessionUserID)")
                    print("sweatDataLogSessionSiteID = \(BLEManager.bleSingleton.sweatDataLogSessionSiteID)")
                    print("sweatDataLogStartEpochTime = \(NSDate(timeIntervalSince1970:TimeInterval(BLEManager.bleSingleton.sweatDataLogStartEpochTime)))")
                    print("modelData!.CH_UserID.prefix(8) = \(modelData!.CH_UserID.prefix(8))")
                    print("modelData!.syncDate = \(String(describing: modelData!.syncDate))")
                    print("sweatDataLogDownloadCompleted = \(BLEManager.bleSingleton.sweatDataLogDownloadCompleted)")
                    */
                    if (BLEManager.bleSingleton.sweatDataLogDownloadCompleted) {

//                        // Clear duplicates cache after upload first file (previous session)
//                        if self.modelData!.clearDuplicateCacheAfterPreviousUpload == false {
//                            self.modelData!.clearDuplicateCacheAfterPreviousUpload = true
//                            self.modelData!.uploadDataDuplicateHashDict.removeAll()
//                        }

                        if ((modelData!.CH_UserID.prefix(8) != BLEManager.bleSingleton.sweatDataLogSessionUserID) || (modelData!.enterpriseSiteCode != BLEManager.bleSingleton.sweatDataLogSessionSiteID)) {
                            
                            // Force disconnetion if the current ongoing logged session profile does not match the current user profile
                            if (!modelData!.sweatDataPreviousDayDownloadingCompleted)
                            {
                                modelData!.ebsMonitor.forceDisconnectFromPeripheral()
                                
                                modelData!.isCurrentUserSession = false
                                modelData!.isUserSessionToDisplay = true
                                if (modelData!.showNotification == false) {
                                    modelData!.notificationData = NotificationModifier.NotificationData(id: bleSessionRunningNotification, title: "Error", detail: "The module is currently recording another user session.", type: .Error, notificationLocation: .Top, showOnce: false, showSeconds: ShowOptions.showNoClose)
                                    modelData!.showNotification = true
                                }
                                
                            }
                            
                            // No match, remove the data file just downloaded, no need to upload to cloud
                            let fm = FileManager.default
                            do {
                                if fm.fileExists(atPath: modelData!.sweatDataLogFileURL.path) {
                                    // file uploaded so remove it
                                    print("Session information not match, removing uploaded CSV file")
                                    logger.info("urlSession-removeCSV", attributes: ["fileName" : modelData!.sweatDataLogFileURL])
                                    try fm.removeItem(at: modelData!.sweatDataLogFileURL)
                                }
                            } catch {
                            }
                            
                            self.modelData!.sweatDataPreviousDayDownloadingCompleted = true
                            self.modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
                            
                            self.modelData!.ebsMonitor.stopDataUploadTimeoutHandler()
                            
                            self.modelData!.csvFileIsUploading = false
                            self.modelData!.networkUploadSuccess = true
                                                        
                        }
                    
                        // Match, the current ongoing logged session belongs to the current user, go ahead to enable display and upload to cloud
                        else {
                            modelData!.isCurrentUserSession = true
                            modelData!.isUserSessionToDisplay = true
                            if modelData!.notificationData.id == bleSessionRunningNotification {
                                modelData!.showNotification = false
                            }
                            
                            modelData!.syncDate = Date()

                            // Only upload if new data
                            if sweatDataAdded == true
                            {
                                modelData!.networkManager.uploadSensorCSVFile(csvFileURL: modelData!.sweatDataLogFileURL, csvFileName: modelData!.sweatDataLogFileName)
                            }
                            else {
                                print("**** NO DATA TO UPLOAD ****")
                                
                                if(!modelData!.sweatDataPreviousDayDownloadingCompleted) {
                                    modelData!.sweatDataPreviousDayDownloadingCompleted = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        // Even if there is no new current day data to upload to cloud, still go ahead to start downloading previous day data.
                                        self.modelData!.ebsMonitor.scanDeviceData()
                                    }
                                }
                                
                                else {
                                    modelData!.sweatDataMultiDaySyncWithSensorCompleted = true

                                    modelData!.ebsMonitor.stopDataUploadTimeoutHandler()
                                }
                            }
                            sweatDataAdded = false

                            /* Share the CSV text string */
                            if modelData!.isLongPressShare == true {
                                modelData!.isShareSheetPresented = true
                            }

                            modelData!.isSweatDataDownloadProgressAlertShowing = false
                            
                        }
        
                    }

                }
                
                // The sweat data log packet is still coming, append the data to the existing buffer
                else if (!BLEManager.bleSingleton.sweatDataLogDownloadCompleted)
                {
                    
                    if(modelData!.isCHArmBandConnected) {
                        
                        // This is regular periodic sweat data
                        if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.DATA_SWEAT.rawValue
                        {
                            sweatDataString = "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.gsrLargeSkinElectrodeSignalRawInMv),\(sweatDataLogPacket.gsrZeroDepthElectrodeSignalRawInMv),\(sweatDataLogPacket.localSweatChlorideLevel),\(sweatDataLogPacket.gsrFluidicWellSignalRawInMv),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                        // This is intake event recorded from the app.
                        else if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_HYDRATION_INTAKE.rawValue
                        {
                            sweatDataString = "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.eventWaterIntakeInMl),\(sweatDataLogPacket.eventSodiumInTakeInMg),\(0),\(0),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                            
                        }
                        
                        // This is GPS location event recorded from the app.
                        else if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GPS_LOCATION.rawValue {
                        }
                        
                        // This is one of the events: nudge alert, dehydration alarm.
                        else if((sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_DEHYDRATION_ALARM.rawValue) || (sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_NUDGE_ALERT.rawValue)) {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.localSweatChlorideLevel),\(0),\(0),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                        else if(sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_FLUIDICS_NOT_CLIPPED.rawValue) {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.eventFluidicsNotClippedStatus),\(0),\(0),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                        else if(sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GSR_OFF_BODY.rawValue) {
                             sweatDataString =
                             "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.eventGSROffBodyStatus),\(0),\(0),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }

                        else if ((sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GSR_SWEAT_ONSET.rawValue) || (sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GSR_SODIUM_READING_AVAILABLE.rawValue) || (sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GSR_SODIUM_READING_MAX_UPDATE.rawValue)) {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(0),\(0),\(0),\(0),\(sweatDataLogPacket.eventGSRSweatOnsetChannelRawInMv),\(sweatDataLogPacket.eventGSRSweatFluidicsChannelRawInMv),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                            
                        // This is one of the events: seal break, plateau, saturation, persistent dropout or sweat rate update.
                        else if sweatDataLogPacket.dataType != 0xFF {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.eventLocalSweatRate),\(sweatDataLogPacket.eventDurationForSweatRate),\(sweatDataLogPacket.eventLocalVolumeLossForSweatRateCalculation),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                    }
                    
                    else {
                        // This is regular periodic sweat data
                        if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.DATA_SWEAT.rawValue
                        {
                            sweatDataString = "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.localSweatChlorideLevel),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.bodyTemperatureAirInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                        // This is intake event recorded from the app.
                        else if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_HYDRATION_INTAKE.rawValue
                        {
                            sweatDataString = "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.eventWaterIntakeInMl),\(sweatDataLogPacket.eventSodiumInTakeInMg),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.bodyTemperatureAirInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                            
                        }
                        
                        // This is GPS location event recorded from the app.
                        else if sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_GPS_LOCATION.rawValue {
                        }
                        
                        // This is one of the events: nudge alert, dehydration alarm.
                        else if((sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_DEHYDRATION_ALARM.rawValue) || (sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_NUDGE_ALERT.rawValue)) {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.localSweatChlorideLevel),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.bodyTemperatureAirInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                            
                        }
                        
                        else if(sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.EVENT_FLUIDICS_NOT_CLIPPED.rawValue) {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.eventFluidicsNotClippedStatus),\(sweatDataLogPacket.sweatVolumeDeficitInMl),\(sweatDataLogPacket.sweatSodiumDeficitInMg),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.bodyTemperatureAirInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                        
                        // This is one of the events: seal break, plateau, saturation, persistent dropout or sweat rate update.
                        else if sweatDataLogPacket.dataType != 0xFF {
                            sweatDataString =
                            "\(sweatDataLogPacket.timeStamp),\(sweatDataLogPacket.dataType),\(sweatDataLogPacket.localSweatVolumeInUl),\(sweatDataLogPacket.eventLocalSweatRate),\(sweatDataLogPacket.eventDurationForSweatRate),\(sweatDataLogPacket.eventLocalVolumeLossForSweatRateCalculation),\(sweatDataLogPacket.sweatVolumeTotalLossInMl),\(sweatDataLogPacket.sweatSodiumTotalLossInMg),\(sweatDataLogPacket.currentTEWLInMl),\(sweatDataLogPacket.bodyTemperatureSkinInC),\(sweatDataLogPacket.bodyTemperatureAirInC),\(sweatDataLogPacket.activityCounts),\(sweatDataLogPacket.batteryVoltageInMv)\n"
                        }
                    }

                    if modelData!.sweatDataPreviousDayDownloadingCompleted == false && modelData!.isCurrentUserSession && BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex <= 0 {

                        // Append the new data entry to the historical data buffer, sweat data entry (type 0) only from either CH or Armband, take passive loss settings in the app into consideration
                        // since this is sweat log from device and there is no TEWL recorded on the device.
                        if (sweatDataLogPacket.dataType == BLEManager.CH_RECORD_DATA_TYPE.DATA_SWEAT.rawValue) {
                            let sweatVolumeTotalLossInOz = round ((Double(sweatDataLogPacket.sweatVolumeTotalLossInMl) + (modelData!.passiveWaterLoss ? Double(Int16(sweatDataLogPacket.currentTEWLInMl)) : 0.0)) * 0.033814 * 10) / 10
                            let sweatVolumeDeficitInOz = round ((Double(sweatDataLogPacket.sweatVolumeDeficitInMl) + (modelData!.passiveWaterLoss ? Double(Int16(sweatDataLogPacket.currentTEWLInMl)) : 0.0)) * 0.033814 * 10) / 10
                            let fluidTotalIntakeInOz = Double(Int16(sweatDataLogPacket.sweatVolumeTotalLossInMl + sweatDataLogPacket.eventWaterIntakeInMl) - sweatDataLogPacket.sweatVolumeDeficitInMl) / 29.574
                            let sodiumTotalIntakeInMg = UInt16(Int16(sweatDataLogPacket.sweatSodiumTotalLossInMg) - sweatDataLogPacket.sweatSodiumDeficitInMg + Int16(sweatDataLogPacket.eventSodiumInTakeInMg))
                            let sweatSodiumDeficitInMg = sweatDataLogPacket.sweatSodiumDeficitInMg - Int16(sweatDataLogPacket.eventSodiumInTakeInMg)
                            
                            connectedHydrationHistoricalData.append(historicalHydrationInfo(
                                timeStamp: sweatDataLogPacket.timeStamp,
                                sweatVolumeDeficitInOz: sweatVolumeDeficitInOz,
                                sweatSodiumDeficitInMg: sweatSodiumDeficitInMg,
                                sweatVolumeLossWholeBodyInOz: sweatVolumeTotalLossInOz,
                                sweatSodiumLossWholeBodyInMg: sweatDataLogPacket.sweatSodiumTotalLossInMg,
                                fluidTotalIntakeInOz: fluidTotalIntakeInOz,
                                sodiumTotalIntakeInMg: sodiumTotalIntakeInMg,
                                bodyTemperatureSkinInC: sweatDataLogPacket.bodyTemperatureSkinInC,
                                bodyTemperatureAirInC: sweatDataLogPacket.bodyTemperatureAirInC,
                                activityCounts: sweatDataLogPacket.activityCounts))
                        }
                    }

                    if checkForDuplicate(sweatDataString) {
                        sweatDataLogCSVText! += sweatDataString
                        sweatDataAdded = true
                    }
                    else {
//                        print("*** FOUND DUPLICATE ***")
                    }
                }
            }
        }
    }

    // Brief: Method to print firmware revision number
    func printFWRevision() {
        modelData!.firmwareRevText = BLEManager.bleSingleton.firmwareRevString
        modelData!.isCHArmBandConnected = isCHArmBand(modelData!.firmwareRevText)
        
        // Only start to sync and upload data to cloud after onboarding is completed.
        if(modelData!.isOnboardingComplete && (!modelData!.sensorNavigation))
        {
            // Start data sync and uploading to cloud right after sensor is connected and only after the module type is detected based on firmware revision.
            // Clear duplciates cache when device re-connects in case the cashe was not cleared after prior disconnection if the disconnection event was not captured due to unexpected reasons.
            // This would also clear the cache when connected to a new sensor.
            modelData!.uploadDataDuplicateHashDict.removeAll()
            
            // Reset all data downloading flags upon connection/reconnection in case these flags were not reset due to unexpected exit or abruupt disconnection.
            modelData!.sweatDataPreviousDayDownloadingCompleted = true
            modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
            modelData!.historicalSweatDataDownloadCompleted = true
            BLEManager.bleSingleton.sweatDataLogDownloadCompleted = true
            
            //            if(modelData!.sweatDataMultiDaySyncWithSensorCompleted && modelData!.historicalSweatDataDownloadCompleted) {
            modelData!.networkManager.getNewRefreshToken()
            modelData!.ebsMonitor.scanDeviceCurrentDayData()
            //            }
        }
        
    }

    // Brief: Method to print the BLE peripheral device status
    func printDeviceStatus() {
        let deviceStatus = BLEManager.bleSingleton.deviceStatus
        let deviceName = modelData?.pairCHDeviceSN

        switch deviceStatus {
        case 0:
            modelData!.deviceStatusText = "OK" // 0-0-0 (LSB-MSB)
            break
        case 1:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_ppg_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "PPG FAIL"  // 1-0-0
            break
        case 2:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_imu_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "IMU FAIL"  // 0-1-0
            break
        case 3:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_ppg_imu_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "PPG/IMU FAIL" // 1-1-0
            break
        case 4:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_mem_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "MEM FAIL"  // 0-0-1
            break
        case 5:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_ppg_mem_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "PPG/MEM FAIL"  // 1-0-1
            break
        case 6:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_imu_mem_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "IMU/MEM FAIL"  // 0-1-1
            break
        case 7:
            logger.error("EBSDeviceMonitor", attributes: ["error": "printDeviceStatus_fail", "device_name" : deviceName])
            modelData!.deviceStatusText = "FAIL"  // 1-1-1
            break
        default:
            modelData!.deviceStatusText = " "
            break
        }
    }
    
    func intakeLogged() {
        print("Intake was logged!")
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
        
        // Right after intake is logged, retrieve logged historical sweat data from sensor to update sweat/intake plot if there is no ongoing data retrival process.
        if (self.modelData!.historicalSweatDataDownloadCompleted && self.modelData!.sweatDataMultiDaySyncWithSensorCompleted) {
                        
            guard BLEManager.bleSingleton.sensorConnected == true else {
                logger.error("EBSDeviceMonitor", attributes: ["error": "updateSweatSensingInfo_sensor_disconnected"])
                return
            }
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
                logger.error("EBSDeviceMonitor", attributes: ["error": "updateSweatSensingInfo_lost_connection"])
                return
            }
            
            let byteCommandIntBigEndian = UInt16(bigEndian: BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex)
            let byteCommandHex = "525A" + String(format: "%04X", byteCommandIntBigEndian)     // Little Endian format on the peripheral device
            let startHisoricalDataDownload = Data(hexString: byteCommandHex)
            //                let startHisoricalDataDownload = Data(hexString: "525A0000")
            peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected.writeValue(startHisoricalDataDownload!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
            
            self.modelData!.historicalSweatDataDownloadCompleted = false
            
            print(BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex)
            
            // Add a timeout here for the data downloading/uploading so that it won't hang the system.
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if(self.modelData!.historicalSweatDataDownloadCompleted == false) {
                    self.modelData!.historicalSweatDataDownloadCompleted = true
                }
            }

        }
    }

    private func generateTimeStampStringFromEpoch (epochTime: Double) -> String {
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        return (formatter.string(from: date))
    }

    public func getHistoricalData() -> [historicalHydrationInfo] {
        
        if (BLEManager.bleSingleton.currentHistoricaSweatlDataDownloadIndex > 0) {
            connectedHydrationHistoricalData.removeAll()
            let connectedData = BLEManager.bleSingleton.getHydrationHistoricalData()
            let historicalData: [historicalHydrationInfo] = connectedData.map { historicalHydrationInfo($0) }
            return historicalData
        }
        else {
            connectedHydrationHistoricalData.sort {$0.timeStamp < $1.timeStamp}
            let uniqueHydrationData = connectedHydrationHistoricalData.unique { $0.timeStamp }
            return uniqueHydrationData
        }
    }

    /// Function to hash a string using SHA1 and insert it into the dictionary
    private func checkForDuplicate(_ text: String) -> Bool {
        // Generate SHA1 hash
        let hashedKey = sha1Hash(of: text)

        // Check if the hash exists in dictionary
        if modelData!.uploadDataDuplicateHashDict[hashedKey] != nil {
            return false  // Duplicate, do not insert
        } else {
            modelData!.uploadDataDuplicateHashDict[hashedKey] = true  // Insert new hash
            return true   // New entry, inserted successfully
        }
    }
    
    /// Helper function to generate SHA1 hash of a string
    private func sha1Hash(of input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = Insecure.SHA1.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    func getLocalDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getBatteryLifeLeftInDays(battLevelInV: Double) -> Int {
        
        // If battery data is not available yet right after power up, set battery life to maximum 70 days.
        if (battLevelInV == 0.0) {
            return 70
        }
        
        // Calculate number of days in battery life with lookup table
        let currentBatteryLevelInV = battLevelInV
        var numberOfDaysLeft = 0
        for i in (0...(batteryLifeLookUpTable.count-1)).reversed() {
            if currentBatteryLevelInV > batteryLifeLookUpTable[i] {
                numberOfDaysLeft = i * 2
                break
            }
        }

        return numberOfDaysLeft
    }

    func setChlorideWaveformChannel(channel: UInt8)
    {
        guard BLEManager.bleSingleton.sensorConnected == true else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "setChlorideWaveformChannel_sensor_disconnected"])
            return
        }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "setChlorideWaveformChannel_lost_connection"])
            return
        }
        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        //peripheralConnected.writeValue(Data(bytes: [0x58, channel]), for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
        peripheralConnected.writeValue(Data([0x58, channel]), for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
    }
    
    func setButtonPressWaterIntakeVolumeInMl()
    {
        guard BLEManager.bleSingleton.sensorConnected == true else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "setChlorideWaveformChannel_sensor_disconnected"])
            return
        }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else {
            logger.error("EBSDeviceMonitor", attributes: ["error": "setChlorideWaveformChannel_lost_connection"])
            return
        }
        
        let volumeToSetInMl = UInt16(modelData!.buttonPressForWaterIntake ? modelData!.buttonPressWaterIntakeVolumeInMl : 0)
        
        let waterVolumeToSetData = withUnsafeBytes(of: volumeToSetInMl.littleEndian, Array.init)
        let setButtonPressWaterIntakeVolumeCmd = Data(hexString: "4F")! + waterVolumeToSetData
        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        peripheralConnected.writeValue(setButtonPressWaterIntakeVolumeCmd, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
    }
    
    func dataUploadTimeoutHandler()
    {
        if(self.modelData!.sweatDataPreviousDayDownloadingCompleted == false) {
            self.modelData!.sweatDataPreviousDayDownloadingCompleted = true
        }
        
        if(self.modelData!.sweatDataMultiDaySyncWithSensorCompleted == false) {
            self.modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
        }
        
        if (self.modelData!.csvFileIsUploading == true) {
            self.modelData!.csvFileIsUploading = false
        }
        
        if(BLEManager.bleSingleton.sweatDataLogDownloadCompleted == false) {
            BLEManager.bleSingleton.sweatDataLogDownloadCompleted = true
        }
    }
    
    func stopDataUploadTimeoutHandler()
    {
        dataUploadTimoutWorkItem?.cancel()
    }
    
}

// Brief: Extension of ScanForBLE class to include appropriate methods for NFCNDEFReaderSessionDelegate
extension EBSDeviceMonitor: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        //Do Nothing
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("\(messages)")
    }
}

// Extension to filter an array by unique key
extension Sequence {
    func unique<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return self.filter { seen.insert(key($0)).inserted }
    }
}
