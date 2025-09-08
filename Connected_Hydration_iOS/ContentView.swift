//
//  ContentView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//

import SwiftUI
import Combine
import BLEManager

enum Tab {
    case today
    case history
    case intake
    case insights
    case settings
}

struct ContentView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var selection: Tab = .today
    
    @State private var navigationPath: [MainOnboardingRoute] = []

    //@State var isConnectivityPresented = false
    //@State var isInfoPopoverPresented = false

    @ObservedObject var tb = ToolBarManager.toolBar

    @State private var showBluetoothNotAuthorized = false
    @State private var showBluetoothPoweredOff = false

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    init() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "Oswald-Medium", size: 12)! ], for: .normal)
        UITextField.appearance().tintColor = .black
    }
    
    var body: some View {
        if modelData.isOnboardingComplete == false {
            MainOnboardingView()
                .environmentObject(modelData)
                .onAppear() {
                    modelData.ebsMonitor.modelData = modelData
                    modelData.ebsMonitor.start()
                    modelData.unitsChanged = modelData.userPrefsData.useUnits
                }
        }
        else {
            VStack {
                TabView(selection: $selection.onUpdate {
                    let oldIntakeState = intakeTabGlobalState
                    if selection == .intake {
                    }
                    else {
                        modelData.currentUserIntakeItems.removeAll()
                        modelData.currentBottleCounts.removeAll()
                        modelData.currentBottleListSelections.removeAll()
                        modelData.totalWaterAmount = 0
                        modelData.totalSodiumAmount = 0
                        intakeTabGlobalState = .intakeNormal
                        updateIntakeTabState()
                    }
                    modelData.tabSelectionChanged(item: selection)
                    
                    if selection == .intake {
                        
                        if oldIntakeState == .intakeClose{
                            modelData.rootViewId = UUID()
                            selection = .today
                        }
                        
                        if oldIntakeState == .intakeSave {
                            modelData.rootViewId = UUID()
                            selection = .today
                        }
                    }
                    
                })
                {
                    TodayView(tabNothing: $selection, showBluetoothNotAuthorized: $showBluetoothNotAuthorized, showBluetoothPoweredOff: $showBluetoothPoweredOff)
                        .tabItem {
                            selection == .today ? Label("TODAY", image: "Today Tab On") : Label("TODAY", image: "Today Tab Off")
                        }
                        .tag(Tab.today)
                        .accessibility(identifier: "tabview_today")

                    HistoryView(tabNothing: $selection)
                        .tabItem {
                            selection == .history ? Label("HISTORY", image: "History Tab On") : Label("HISTORY", image: "History Tab Off")
                        }
                        .tag(Tab.history)
                        .accessibility(identifier: "tabview_history")

                    IntakeTabView(tabSelection: $selection)
                        .tabItem {
                            Image("Intake Tab Normal")
                        }
                        .tag(Tab.intake)
                        .accessibility(identifier: "tabview_intake")

                    InsightsView(tabNothing: $selection)
                        .tabItem {
                            selection == .insights ? Label("INSIGHTS", image: "Insights Tab On") : Label("INSIGHTS", image: "Insights Tab Off")
                        }
                        .tag(Tab.insights)
                        .accessibility(identifier: "tabview_insights")

                    SettingsView(tabNothing: $selection)
                        .environmentObject(modelData)
                        .tabItem {
                            selection == .settings ? Label("SETTINGS", image: "Settings Tab On") : Label("SETTINGS", image: "Settings Tab Off")
                        }
                        .tag(Tab.settings)
                        .accessibility(identifier: "tabview_settings")

                }   // TabView end
                .onAppear() {
                    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

                    ToolBarManager.toolBar.modelData = modelData

                    modelData.ebsMonitor.modelData = modelData
                    //modelData.newAppVersionAvail.modelData = modelData

                    modelData.unitsChanged = modelData.userPrefsData.useUnits
                    
                    modelData.buttonPressWaterIntakeVolumeInMl = modelData.userPrefsData.buttonPressWaterIntakeMl
                    
                    BLEManager.bleSingleton.setPassiveLossOption(isPassiveLossEnabled: modelData.passiveWaterLoss)
                    
                    if (languageCode == "ja") {
                        modelData.bottle_list = load("preset_bottle_list_jap.json")
                    }
                    else if modelData.userPrefsData.useUnits == "1" {
                        modelData.bottle_list = load("preset_bottle_list.json")
                    }
                    else {
                        modelData.bottle_list = load("preset_bottle_list_metric.json")
                    }

                    if modelData.isCHDeviceConnected {
                        return
                    }
                    
                    modelData.ebsMonitor.start()

                    // Try to update refresh token - called when app started and brought to foreground (below)
                    modelData.networkManager.modelData = modelData
                    modelData.networkManager.getNewRefreshToken()

                    // Try to sync with old paired device
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        // Need to locate old device and re-pair again
                        connectToCHDevice()
                    }
                }
                .onDisappear() {
                    // After logout, set the returning tab selection to Today
                    if modelData.isOnboardingComplete == false {
                        selection = .today
                    }
                }
                .onReceive(timer) { time in
                    //print("The time is now \(time)")
                    modelData.isCHDeviceConnected = BLEManager.bleSingleton.sensorConnected

                    // Try to reconnect every 10 seconds if the device is not connected yet
                    if(!modelData.isCHDeviceConnected) {
                        connectToCHDevice()
                    }

                    // Handle issue where user turns off bluetooth using device
                    if BLEManager.bleSingleton.centralManager.state == .poweredOff {
                        if modelData.isCHDeviceConnected {
                            modelData.isCHDeviceConnected = false
                        }
                    }

                    // Update connection icon in toolbar
                    ToolBarManager.toolBar.updateConnectivityIcon.toggle()
                }
                .onAppCameToForeground {
                    // Scan and re-pair
                    print("*** App came to foreground")
                    logger.info("Epicore CH brought to foreground")
                    
                    // Make sure bluetooth is authorized and powered on
                    if isBluetoothPermissionGranted == false {
                        logger.info("isBluetoothPermissionGranted (onAppCameToForeground) == false")
                        showBluetoothNotAuthorized = true
                    }
                    else if isBluetoothPoweredOn {
                        showBluetoothPoweredOff = true
                    }

                    if modelData.notificationData.id == bleSessionRunningNotification {
                        modelData.showNotification = false
                        modelData.isCurrentUserSession = true
                        modelData.isUserSessionToDisplay = false
                    }

                    // Check to see if the login/token is still valid and not expired after app comes to foreground
                    if modelData.networkManager.isTokenValid() {

                        // Try to update refresh token
                        modelData.networkManager.getNewRefreshToken()

                        // Sync data right after app comes back to foreground
                        if(BLEManager.bleSingleton.sensorConnected) {
                            if(modelData.sweatDataMultiDaySyncWithSensorCompleted && modelData.historicalSweatDataDownloadCompleted) {
                                modelData.networkUploadSuccess = false
                                modelData.ebsMonitor.scanDeviceCurrentDayData()
                            }
                        }
                        
                        else {
                            connectToCHDevice()
                        }
                        
                        // Reset the setting to show the warning notification again after app comes to foreground.
                        UserDefaults.standard.set(false, forKey: maxDeficitIntakeNotification)
                        
                    }
                     
                    // If the token is not valid, go back to re-login
                    else {
                        DispatchQueue.main.async {
                            modelData.isOnboardingComplete = false
                            modelData.onboardingStep = 1
                            
                            modelData.networkAPIError = false
                            modelData.networkManager.serverError = nil
                            
                            modelData.ebsMonitor.forceDisconnectFromPeripheral()
                        }
                    }
                        
                }
                .onAppWentToBackground {
                    print("*** App sent to background")
                    logger.info("Epicore CH App sent to background")
                }
                .notification(data: $modelData.notificationData, show: $modelData.showNotification)
                .modifier(ConnectivityModifier(model: $tb.showConnectivity))
                .modifier(InfoPopoverModifier(model: $tb.showInfoPopover))
            }
            .trackRUMView(name: "ContentView")
        }
    }

    func connectToCHDevice() {
        if modelData.pairCHDeviceSN.isEmpty == false {
            var deviceFound = false
            for device in modelData.CHDeviceArray {
                if device.name == modelData.pairCHDeviceSN {
                    modelData.pairedCHDevice = device
                    deviceFound = true
                }
            }
            if deviceFound == true {
                logger.info("Found Device: " + modelData.pairCHDeviceSN)
                logger.info("ContentView - Connecting to CH Device...")
                print("Found Device: " + modelData.pairCHDeviceSN)
                print("ContentView - Connecting to CH Device...")
                modelData.ebsMonitor.connectToPeripheral()
            }
        }
    }

}

// Define a singleton class for managing ToolBar
final class ToolBarManager: ObservableObject {

    static let toolBar = ToolBarManager()

    var modelData: ModelData?

    @Published var showConnectivity: ConnectivityData?
    @Published var showInfoPopover: InfoPopoverData?
    @Published var updateConnectivityIcon = false
}

extension View {

    // Add ToolBar support
    func addToolbar() -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                    } label: {
                        Image("Nav Epicore Logo")
                            .resizable()
                            .padding(.leading, (400 / 2.0) - 295/3) // 295 = image size
                    }
                    .disabled(true)
                    }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        ToolBarManager.toolBar.showInfoPopover = nil
                        
                        if ToolBarManager.toolBar.showConnectivity == nil {
                            ToolBarManager.toolBar.showConnectivity = ConnectivityData(type: .success)
                        }
                        else {
                            ToolBarManager.toolBar.showConnectivity = nil
                        }
                    } label: {
                        if ToolBarManager.toolBar.modelData != nil {
                            if ToolBarManager.toolBar.updateConnectivityIcon == true || ToolBarManager.toolBar.updateConnectivityIcon == false {
                                getCurrentDeviceNetworkImage(data: ToolBarManager.toolBar.modelData!)
                            }
                        }
                        else {
                            Image("Connex - device gray")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        ToolBarManager.toolBar.showConnectivity = nil
                        
                        if ToolBarManager.toolBar.showInfoPopover == nil {
                            ToolBarManager.toolBar.showInfoPopover = InfoPopoverData(type: .basic)
                        }
                        else {
                            ToolBarManager.toolBar.showInfoPopover = nil
                        }
                    } label: {
                        Image("Nav Info Button")
                            .padding(.top, 10)
                    }
                }
            }
    }
}
