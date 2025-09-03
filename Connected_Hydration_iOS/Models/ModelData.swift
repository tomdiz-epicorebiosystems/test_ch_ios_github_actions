//
//  ModelData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 2/7/23.
//

import Foundation
import SwiftUI
import Combine
import Network
import BLEManager
import DGCharts

let initialPreviewBottleName = "Preview Icon - Can Water - 9"

class ModelData: ObservableObject {
    var bottles: [BottleData] = load("drinks.json")
    var bottle_list: [BottleData] = load("preset_bottle_list.json")
    var bottlePreviewIcons: [BottleData] = load("preview_bottles.json")
///*
    // Server Info
    // Defaults to Production Server Info
    //var epicoreHost = "ch.epicorebiosystems.com"
    @AppStorage("epicoreHost") var epicoreHost = "ch.epicorebiosystems.com"
    //var ch_phone_api_jwt_secret = "utbc_23p98Zb"
    @AppStorage("ch_phone_api_jwt_secret") var ch_phone_api_jwt_secret = "utbc_23p98Zb"
    //var ch_phone_api_key = "q3m7rvCPykvr3_4"
    @AppStorage("ch_phone_api_key") var ch_phone_api_key = "q3m7rvCPykvr3_4"
    //var clientId = "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT"
    @AppStorage("clientId") var clientId = "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT"
    //var auth0Url = "auth.ch.epicorebiosystems.com"
    @AppStorage("auth0Url") var auth0Url = "auth.ch.epicorebiosystems.com"
//*/
/*
    // Defaults to Staging Server Info
    var epicoreHost = "epicore.dev"
    var ch_phone_api_jwt_secret = "So0e5En79B3T"
    var ch_phone_api_key = "%{UF)43sVG(#ks3"
    var clientId = "&client_id=aHekjFeRi5qHapVK5XX0d6lr5FyrFeB7"
    var auth0Url = "auth.epicore.dev"
*/

    @Published var rootViewId = UUID()          // This is used to clear the NavigationStack of the Intake views
                                                // SwiftUI will destroy/update view and all its subviews if the view.id changes

    @Published var currentUserIntakeItems = [BottleData]() // Array of the user's bottle intake items.
    var currentBottleCounts = [Int: String]()

    var currentBottleListSelections = [Int: String]()

    var CHDeviceArray = [PeripheralDetails]()
    var pairedCHDevice = PeripheralDetails.init(name: "CH100002", MAC: "", RSSI: "", SignalBar: UIImage(), SweatLossAlertImage: UIImage(), BleBeaconIndicator: UIImageView(), SweatVolumeLoss: "", SweatSodiumLoss: "")

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var chDeviceBatteryLvl = 70

    @Published var currentBottleMenuItems = [BottleData]() // Array of the user's bottle menu items.
                                                // Loaded from JSON data stored in userBottleMenuItems

    var ebsMonitor = EBSDeviceMonitor()

    //var newAppVersionAvail = CheckAppUpdateAvail()

    let networkManager = NetworkManager()
    @Published var showNoAccountFound = false
    @Published var gotListOfSites = false
    @Published var networkAPIError = false
    @Published var networkUploadSuccess = false
    @Published var userAvgSweatSodiumConcentrationSuccess = false
    @Published var userHistoryStatsSuccess = false
    @Published var networkUploadFailed = false
    @Published var networkUploadFailedMsg = ""

    // Used for onboarding view change flags
    @Published var enterpriseNameAvailable = 0
    @Published var userExists = 0
    @Published var networkSendCodeAPIError = 0
    @Published var userAuthenticated = 0
    @Published var sendCodeSuccess = 0
    @Published var updatedUserSuccess = 0
    
    @Published var enterpriseSiteCodeUpdated = false

    // Notification system
    @Published var showNotification:Bool = false
    var notificationData: NotificationModifier.NotificationData = NotificationModifier.NotificationData(id: "empty_notification", title: "Notification Title", detail: "Notification text for the user to view.", type: .Error, notificationLocation: .Middle, showOnce: false, showSeconds: ShowOptions.showClose)

    @Published var sweatDashboardViewStatus = 0
    
    @Published var fluidDeficitToDisplayInOz: Double = 0.0
    @Published var sodiumDeficitToDisplayInMg: Int16 = 0
    @Published var fluidDeficitToDisplayInBottle: Double = 0.0
    @Published var sodiumDeficitToDisplayInPack: Double = 0.0
    @Published var fluidDeficitToDisplayInMl: Int16 = 0
    @Published var fluidTotalLossToDisplayInMl: Int16 = 0

    @Published var fluidTotalIntakeInMl: Int16 = 0
    @Published var sodiumTotalIntakeInMg: Int16 = 0

    @Published var fluidTotalLossFromSweatInMl: Int = 0
    @Published var currentTEWLInMl: Int = 0
    
    @Published var sweatVolumeDeficit = "0.0"
    @Published var sweatSodiumDeficit = "0.0"

    @Published var sweatSodiumTotalLoss = "0"
    @Published var sweatVolumeTotalLoss = "0.0"

    @Published var globalIntakeButtonChanged = false

    @Published var sensorWaveformChartData = LineChartData()

    var downloadUserPhysiology = false
    var updateUserSuccess = true           // used to make sure POST update-user is called before GET user-info API

    var okWeight = "0"
    var okFeet = "0"
    var okInches = "0"
    var okGender = "0"

    @Published var totalShiftDurationTime = "0:00"
    @Published var alarmCount = 0

    var shareDataLogFileURL: URL!
    var firmwareRevText  = ""
    var deviceStatusText  = ""
    var isSweatDataDownloadProgressAlertShowing = false
    var isInternetConnectivityAlertShowing = false
    var isShareSheetPresented = false
    var isLongPressShare = false

    var isCurrentUserSession = true
    var isUserSessionToDisplay = false

    // Used for file uploading
    var sweatDataLogFileURL: URL!
    var sweatDataLogFileName: String!
    var csvFileIsUploading = false
    
    var sweatDataPreviousDayDownloadingCompleted = true
    var sweatDataMultiDaySyncWithSensorCompleted = true
    
    var historicalSweatDataDownloadCompleted = true
    var deviceMonitorStarted = false

    var allowDeviceRescan = false

    /// Caching to remove duplicates - supports chart data loading
    var uploadDataDuplicateHashDict: [String: Bool] = [:]  // Stores SHA1 hashes as keys
//    var clearDuplicateCacheAfterPreviousUpload = false

    // Used for new bottle intake border so users know new item
    var newBottlesAdded = [Int]()

    // Suggested intake view button presses
    var suggestIntakeExpandedButtonPressed = false
    @Published var scrollToPassive = 0

    @Published var waterAmountEnterManual = ""
    @Published var sodiumAmountEnterManual = ""
    @Published var manualUserBottle = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: "", sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")
    @Published var isNetworkConnected = false
    @Published var isCHDeviceConnected = false
    var newUserBottle = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: "", sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")

    @Published var totalWaterAmount = 0.0
    @Published var totalSodiumAmount = 0.0
    var fluidIntakeInBottle = 1.0
    var sodiumIntakeInPack = 1.0

    var cancelFromIntakeSubView = false

    // Used for deep linking
    var deepLinkCode = ""

    // User sharing options
    @AppStorage("shareAnonymousDataEnterprise") var shareAnonymousDataEnterprise = true
    @AppStorage("shareAnonymousDataEpicore") var shareAnonymousDataEpicore = true

    @AppStorage("passiveWaterLoss") var passiveWaterLoss = true
    @AppStorage("buttonPressForWaterIntake") var buttonPressForWaterIntake = true

    @Published var buttonPressWaterIntakeVolumeInMl = 500
    
    var userAvgSweatSodiumConcentration: AvgSweatVolumeSodiumConcentration?
    var userHistoryStats: UserHistoryStats?

    var isCHArmBandConnected = false

    @AppStorage("userBottleMenuItems") var userBottleMenuItems = String() // String to read/write JSON of users Bottle Menu Items
    @AppStorage("userTotalBottleMenuItems") var userTotalBottleMenuItems = -1   // Max is 25 local bottles. Increment when new one added

    @AppStorage("deviceUserInfoFailed") var deviceUserInfoFailed = false

    // Used to reset to today view
    @AppStorage("isOnBoardingComplete") var isOnboardingComplete = false

    @AppStorage("savedOnboardingStep") var onboardingStep = 1     // Used for Initial Setup view (5 Steps)

    @AppStorage("pairCHDeviceSN") var pairCHDeviceSN = ""
    @AppStorage("enterpriseSiteCode") var enterpriseSiteCode = ""
    @AppStorage("CH_UserID") var CH_UserID = ""
    @AppStorage("CH_UserRole") var CH_UserRole = ""
    @AppStorage("CH_EnterpriseName") var CH_EnterpriseName = ""
    @AppStorage("CH_SiteName") var CH_SiteName = ""
    @AppStorage("userEmailAddress") var userEmailAddress = ""
    @AppStorage("jwtEnterpriseID") var jwtEnterpriseID = ""
    @AppStorage("jwtSiteID") var jwtSiteID = ""

    @AppStorage("UserSubjectID") var UserSubjectID = ""

    @Published var unitsChanged = "1"   // moving publish to UserPrefsData is to slow
                                        // 0 is metric, 1 = imperial
    var userPrefsData = UserPrefsData()

    @AppStorage("CH_FluidBottleSizeInMl") var CH_FluidBottleSizeInMl = 500.0
    @AppStorage("CH_SodiumPackSizeInMg") var CH_SodiumPackSizeInMg = 220

    @AppStorage("capSodiumValue") var capSodiumValue = 0

    var onboardingEnterpriseSiteCode = ""
    var onboardingEnterpriseName = ""

    // Last synch time for connectivity view
    var syncDate: Date? = nil
    var updateDate :Date? = nil

    var sensorNavigation = false

    // Used for retries if network API fails to update user data
    var userUpdateAPIFailure = false

    var sweatDataLogStartEpochTimeString: String?

    var userStatusString  = "unknown"

    init() {
        print("ModelData Created")
        monitor.pathUpdateHandler =  { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
        userPrefsData.setUserUnits()
    }

    func searchFirstBottleDataBarCodes(barcode: String) -> Int? {
        return bottles.firstIndex { $0.barcode == barcode }
    }

    func searchSecondBottleDataBarCodes(barcode: String) -> Int? {
        return bottle_list.firstIndex { $0.barcode == barcode }
    }

    func searchBottleDataNames(name: String) -> Int? {
        return bottles.firstIndex { $0.name == name }
    }

    func getTotalBottles() -> [BottleData] {
        let totalBottles = bottles// + currentBottleMenuItems
        return totalBottles
    }

    func bottleInMenu(barcode: String) -> Bool {
        return (currentBottleMenuItems.firstIndex { $0.barcode == barcode } != nil)
    }

    func getTotalPresetBottles() -> [BottleData] {
        let totalPresetBottles = bottle_list
        return totalPresetBottles
    }

    func addIntakeBottle(bottle: BottleData) {
        // Only add if unique bottle id
        var appendBottle = true
        for i in 0..<currentUserIntakeItems.count {
            if bottle.id == currentUserIntakeItems[i].id {
                appendBottle = false
                let keyExists = currentBottleCounts[currentUserIntakeItems[i].id] != nil
                if keyExists {
                    var val = Int(currentBottleCounts[currentUserIntakeItems[i].id]!)!
                    val += 1
                    currentBottleCounts[currentUserIntakeItems[i].id] = String(val)
                }
                else {
                    currentBottleCounts[currentUserIntakeItems[i].id] = "2"
                }
            }
        }
        if appendBottle {
            logger.info("addIntakeBottle", attributes: ["bottleName" : bottle.name, "waterAmount" : bottle.waterAmount, "sodiumAmount" : bottle.sodiumAmount])
            currentUserIntakeItems.append(bottle)
            currentBottleCounts[bottle.id] = "1"
        }
        // Handle the intake icon state
        if currentUserIntakeItems.count == 0 {
            intakeTabGlobalState = .intakeClose
        }
        else {
            intakeTabGlobalState = .intakeSave
            tabBarView?.setNeedsLayout()
        }
        updateIntakeTabState()
    }

    func removeIntakeBottle(bottle: BottleData) {
        for i in 0..<currentUserIntakeItems.count {
            if bottle.id == currentUserIntakeItems[i].id {
                if currentBottleCounts.isEmpty == false {
                    let keyExists = currentBottleCounts[bottle.id] != nil
                    if keyExists {
                        var val = Int(currentBottleCounts[bottle.id]!)!
                        val -= 1
                        if val == 0 {
                            currentBottleCounts.removeValue(forKey: bottle.id)
                            currentUserIntakeItems.remove(at: i)
                            logger.info("removeIntakeBottle", attributes: ["bottleName" : bottle.name, "waterAmount" : bottle.waterAmount, "sodiumAmount" : bottle.sodiumAmount])
                        }
                        else {
                            currentBottleCounts[bottle.id] = String(val)
                        }
                    }
                }
                break
            }
        }
    }

    func tabSelectionChanged(item: Tab) {
        if item == .intake {
            switch intakeTabGlobalState {
            case .intakeNormal:
                loadUserBottleMenuItems()
                intakeTabGlobalState = .intakeClose
                updateIntakeTabState()
                break
                
            case .intakeCancel:
                cancelFromIntakeSubView = true
                rootViewId = UUID()
                intakeTabGlobalState = .intakeClose
                updateIntakeTabState()
                break
            case .intakeAdd:
                if currentBottleListSelections.count >= 1 {
                    addSelectedBottlesMenuItem()
                }
                else {
                    addNewUserBottleMenuItem()
                }
                currentBottleListSelections.removeAll()
                cancelFromIntakeSubView = true
                rootViewId = UUID()
                intakeTabGlobalState = .intakeNormal
                updateIntakeTabState()
                break
            case .intakeClose:
                // open today view
                currentUserIntakeItems.removeAll()
                currentBottleCounts.removeAll()
                currentBottleListSelections.removeAll()
                newBottlesAdded.removeAll()
                totalWaterAmount = 0
                totalSodiumAmount = 0
                intakeTabGlobalState = .intakeNormal
                updateIntakeTabState()
                break
            case .intakeSave:
                logger.info("intakeSaved", attributes: ["totalWaterAmount" : totalWaterAmount, "totalSodiumAmount" : totalSodiumAmount])
                ebsMonitor.saveFuildIntakeToDevice()
                currentUserIntakeItems.removeAll()
                currentBottleCounts.removeAll()
                currentBottleListSelections.removeAll()
                newBottlesAdded.removeAll()
                totalWaterAmount = 0
                totalSodiumAmount = 0
                intakeTabGlobalState = .intakeNormal
                updateIntakeTabState()
                break
            case .intakeUpdate:
                break
            }
        }
    }

    func bottleAlreadyExistInList(id: Int) -> Bool {
        for bottle in currentBottleMenuItems {
            if bottle.id == id {
                return true
            }
        }
        return false
    }

    func addSelectedBottlesMenuItem() {
        do {
            for bottleId in currentBottleListSelections.keys {
                // Get bottle from bottles
                if let index = (bottle_list.firstIndex { $0.id == bottleId }) {
                    newUserBottle = bottle_list[index]
                    print(userBottleMenuItems)
                    // Don't append if already in list
                    if bottleAlreadyExistInList(id: newUserBottle.id) == false {
                        currentBottleMenuItems.append(newUserBottle)
                        userTotalBottleMenuItems += 1

                        // Used for new bottle intake border so users know new item
                        newBottlesAdded.append(newUserBottle.id)
                    }
                    else {
                        print("Bottle already exists")
                    }
                } else {
                    print("Bottle not found")
                }
            }
            // Write out new user bottles
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(currentBottleMenuItems)
            userBottleMenuItems = String(data: jsonData, encoding: String.Encoding.utf8)!
            // Reinitialize newUserBottle
            newUserBottle = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: "", sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")
        } catch {
            print(error.localizedDescription)
            logger.error("JSONEncoder", attributes: ["currentBottleMenuItems": error.localizedDescription])
        }
    }

    func addNewUserBottleMenuItem() {
        do {
            if waterAmountEnterManual != "0" {
                newUserBottle.waterAmount = userPrefsData.useUnits == "1" ? (round((Float(waterAmountEnterManual) ?? 0.0) * 29.574)): (Float(waterAmountEnterManual) ?? 0.0)
                newUserBottle.name = manualUserBottle.name
                newUserBottle.sodiumAmount = 0
                newUserBottle.sodiumSize = "mg"
                newUserBottle.waterSize = "ml"
                newUserBottle.barcode = ""
                newUserBottle.imageName = manualUserBottle.imageName
                waterAmountEnterManual = ""
            }
            if sodiumAmountEnterManual != "0" {
                newUserBottle.sodiumAmount = Float(sodiumAmountEnterManual) ?? 0
                newUserBottle.name = manualUserBottle.name
                newUserBottle.imageName = manualUserBottle.imageName
                sodiumAmountEnterManual = ""
            }

            logger.info("newUserBottle", attributes: ["name": manualUserBottle.name, "waterAmount" : newUserBottle.waterAmount,
                                                      "sodiumAmount" : newUserBottle.sodiumAmount, "waterSize" : newUserBottle.waterSize,
                                                      "sodiumSize" : newUserBottle.sodiumSize])

            manualUserBottle.name = ""
            
            // Add the new bottle the user created
            print(userBottleMenuItems)
            if newUserBottle.sodiumAmount == 0  {
                newUserBottle.sodiumAmount = 0
            }
            if newUserBottle.waterAmount == 0  {
                newUserBottle.waterAmount = 0
            }
            
            // Only add new item when either water or sodium amount is not 0
            if(newUserBottle.waterAmount != 0 || newUserBottle.sodiumAmount != 0) {

                // Use a bigger number to differentiate the IDs of user created and scanned drinks from preset list.
                newUserBottle.id = 100000 + userTotalBottleMenuItems

                // Used for new bottle intake border so users know new item
                newBottlesAdded.append(newUserBottle.id)

                currentBottleMenuItems.append(newUserBottle)
                userTotalBottleMenuItems += 1

                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(currentBottleMenuItems)
                userBottleMenuItems = String(data: jsonData, encoding: String.Encoding.utf8)!
                // Reinitialize newUserBottle
                newUserBottle = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: newUserBottle.barcode, sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")
            }
            
        } catch {
            print(error.localizedDescription)
            logger.error("JSONEncoder", attributes: ["userBottleMenuItems": error.localizedDescription])
        }
    }

    func deleteUserBottleMenuItem(id: Int) {
        do {
            for (index, bottle) in currentBottleMenuItems.enumerated() {
                if bottle.id == id {
                    currentBottleMenuItems.remove(at: index)
                }
            }

            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(currentBottleMenuItems)
            userBottleMenuItems = String(data: jsonData, encoding: String.Encoding.utf8)!

        } catch {
            print(error.localizedDescription)
            logger.error("JSONEncoder", attributes: ["deleteUserBottleMenuItem": error.localizedDescription])
        }
    }

    func loadUserBottleMenuItems() {
        do {
            let jsonDecoder = JSONDecoder()
            let jsonEncoder = JSONEncoder()
            //print("userTotalBottleMenuItems == \(userTotalBottleMenuItems)")
            if userTotalBottleMenuItems < 0 {
                // Initialize users menu items array
                let jsonData = try jsonEncoder.encode(currentBottleMenuItems)
                userBottleMenuItems = String(data: jsonData, encoding: String.Encoding.utf8)!
                userTotalBottleMenuItems += 1
                return
            }
            let jsonData = Data(userBottleMenuItems.utf8)
            currentBottleMenuItems = try jsonDecoder.decode([BottleData].self, from: jsonData)
            // Reinitialize newUserBottle
            newUserBottle = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: "", sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")
        } catch {
            print(error.localizedDescription)
            logger.error("JSONEncoder", attributes: ["loadUserBottleMenuItems": error.localizedDescription])
        }
    }

    func getSweatSodiumString() -> String {
        var sweatString: String = ""

        // choride
        // low - x<=15mM
        // medium -  15mM < x <40mM
        // high - 40mM<=x
        let sodiumConcentration = userAvgSweatSodiumConcentration?.data.sodiumConcentrationMm ?? 0
        if sodiumConcentration <= 15.0000 {
            sweatString = String(localized: "low") + String(localized: " sodium concentration")
        }
        else  if sodiumConcentration <= 40.0000 {
            sweatString = String(localized: "moderate") + String(localized: " sodium concentration")
        }
        else {
            sweatString = String(localized: "high") + String(localized: " sodium concentration")
        }

        sweatString += String(localized: " and ")

        let sweatConcentration = userAvgSweatSodiumConcentration?.data.sweatVolumeMl ?? 0
        // sweat
        // low - x<=21oz
        // Moderate - 21oz < x <48oz
        // Heavy - 48oz<=x
        let mlConversionToOz =  sweatConcentration / 29.574
        if mlConversionToOz <= 21.0 {
            sweatString += String(localized: "low") + String(localized: " volume of loss") + "."
        }
        else if mlConversionToOz <= 48.0 {
            sweatString += String(localized: "moderate") + String(localized: " volume of loss") + "."
        }
        else {
            sweatString += String(localized: "high") + String(localized: " volume of loss") + "."
        }

        return sweatString
    }
    
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
