//
//  ConnectivityModifier.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/13/23.
//

import SwiftUI
import BLEManager

public class ConnectivityData {
    public enum ConnectivityType {
        case warning, error, success

        var backgroundColor: Color {
            return .white
        }
    }

    var type: ConnectivityType = .success

    public init(type: ConnectivityType) {
        self.type = type
    }
}

public struct ConnectivityModifier: ViewModifier {

    @EnvironmentObject var modelData: ModelData
    @Binding var model: ConnectivityData?
    @State var isExpanded = false
    @State var isLargeToubleshoot = false
    @State var subviewHeight : CGFloat = 0
    @State var isModuleView = true

    @State var isAppOverviewPresented = false
    @State var isPatchApplicationPresented = false
    @State var isModulePairingPresented = false
    @State var isUrineColorChartPresented = false
    @State var isHydrationGuidesPresented = false
    @State var isSodiumEqPresented = false
    @State var isSupportPresented = false

    let formatter = DateFormatter() // iOS 13 support
    
    let ontSizeToubleshootText = 14.0

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    public init(model: Binding<ConnectivityData?>) {
        _model = model
        // iOS 13 support
        formatter.dateFormat = "HH:mm Z"
    }

    public func body(content: Content) -> some View {
        content.overlay(
            VStack {
                if model != nil {
                    GeometryReader { geometry in
                        ZStack {
                            // a transparent rectangle under everything. Used to close view
                            Rectangle()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .opacity(0.001)
                                .layoutPriority(-1)
                                .onTapGesture {
                                    model = nil
                                }

                            VStack {
                                Triangle()
                                    .foregroundColor(Color.white)
                                    .frame(width: 25, height: 25)
                                    .padding(.bottom, -10)
                                    .offset(x: 120)

                                VStack {
                                    HStack(alignment: .center, spacing: (languageCode == "ja" ? -2 : 8)) {
                                        getCurrentDeviceNetworkImage(data: modelData)
                                        VStack {
                                            Image("Connex - divider ok")
                                                .padding(.top, 20)
                                            HStack (spacing: 5){
                                                Text("Synced:")
                                                if modelData.syncDate == nil {
                                                    Text("--:--")
                                                }
                                                else {
                                                    Text(modelData.syncDate!, style: .time)
                                                }
                                            }
                                            .fixedSize()
                                            .font(.custom("Roboto-Regular", size: 12))
                                        }
                                        Image("Connex - phone icon")
                                        VStack {
                                            Image("Connex - divider ok")
                                                .padding(.top, 20)
                                            HStack (spacing: 5){
                                                Text("Updated:")
                                                if modelData.updateDate == nil {
                                                    Text("--:--")
                                                }
                                                else {
                                                    Text(modelData.updateDate!, style: .time)
                                                }
                                            }
                                            .fixedSize()
                                            .font(.custom("Roboto-Regular", size: 12))
                                        }
                                        if modelData.isNetworkConnected == true {
                                            Image("Connex - cloud connect")
                                        }
                                        else {
                                            Image("Connex - cloud disconnect")
                                        }
                                    }
                                    HStack() {
                                        getCHDeviceBatteryLevel()
                                        Text(String(modelData.chDeviceBatteryLvl) + String(localized:" days"))
                                            .font(.custom("Roboto-Regular", size: 15))
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .padding(.leading, 40)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack {
                                        // if last sync > 15 hours ago this:
                                        //Text("Sync within the next hour to avoid data loss.")
                                        //    .foregroundColor(Color.red)
                                        //    .font(.system(size: 10, weight: Font.Weight.bold))
                                        if modelData.chDeviceBatteryLvl <= 5 {
                                            Text("Replace module battery soon.")
                                                .fixedSize(horizontal: false, vertical: true)
                                               .foregroundColor(Color.red)
                                                .font(.custom("Roboto-Regular", size: 12))
                                            Spacer()
                                        }
                                        Button(action: {
                                            isExpanded.toggle()
                                        }) {
                                            HStack {
                                                Text("TROUBLESHOOT")
                                                    .font(.custom("Oswald-Regular", size: 20))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))

                                                if isExpanded {
                                                    Image("Connex - down arrow")
                                                }
                                                else {
                                                    Image("Connex - up arrow")
                                                }
                                            }
                                        }
                                        .trackRUMTapAction(name: "conn-troubleshoot")
                                    }

                                    if isExpanded {
                                        
                                        VStack {

                                            Rectangle()
                                                .fill(Color(UIColor.lightGray))
                                                .frame(height: 2.0)
                                                .edgesIgnoringSafeArea(.horizontal)

                                            HStack() {
                                                Button(action: {
                                                    self.isModuleView = true
                                                }) {
                                                    VStack {
                                                        /*
                                                        if isModuleView {
                                                            Rectangle()
                                                                .fill(Color(hex: generalCHAppColors.connexSelectionColor))
                                                                .frame(height: 3.0)
                                                                .frame(width: 100)
                                                        }
                                                         */
                                                        
                                                        Text("Module Sync")
                                                            .font(.custom("JostRoman-Medium", size: languageCode == "ja" ? 17 : 18))
                                                            .foregroundColor(Color(hex: isModuleView ? generalCHAppColors.connexSelectionColor : generalCHAppColors.grayStandardText))
                                                    }
                                                }
                                                .trackRUMTapAction(name: "conn-modulesync")
                                                .padding(languageCode == "ja" ? 0 : 20)
                                                
                                                Divider()
                                                    .frame(width: 1)
                                                    .overlay(Color(UIColor.lightGray))
                                                
                                                Button(action: {
                                                    self.isModuleView = false
                                                }) {
                                                    VStack {
                                                        /*
                                                        if isModuleView == false {
                                                            Rectangle()
                                                                .fill(Color(hex: generalCHAppColors.connexSelectionColor))
                                                                .frame(height: 3.0)
                                                                .frame(width: 100)
                                                        }
                                                        */
                                                        Text("Cloud Update")
                                                            .font(.custom("JostRoman-Medium", size: languageCode == "ja" ? 17 : 18))
                                                            .foregroundColor(Color(hex: isModuleView == false ? generalCHAppColors.connexSelectionColor : generalCHAppColors.grayStandardText))
                                                    }
                                                }
                                                .trackRUMTapAction(name: "conn-cloudupdate")
                                                .padding(languageCode == "ja" ? 0 : 20)
                                            }
                                            .frame(height: 40)
                                            .frame(maxWidth: .infinity, alignment: .center)

                                            if self.isModuleView {
                                                if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == true {
                                                    Text("Your module is successfully communicating with your phone.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == false {
                                                    Text("Your module can hold 16 hours of your latest data. Try to connect your module to your phone via bluetooth to unload the data to your phone, prevent data loss, and see current recommendations.\n\n**You can check the following:**\n\u{2022} Turn on your phone’s bluetooth if it is turned off\n\u{2022} Check that your phone’s bluetooth is paired to your module\n\u{2022} Check that the module and phone are within 6 feet\n\u{2022} Confirm that your module is turned on\n\u{2022} Replace the battery if its power level is low\n\u{2022} If problem persists, the module might be malfunctioning.\nPlease report the error so that we can diagnose and fix it.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else if modelData.isNetworkConnected == false && modelData.isCHDeviceConnected == true {
                                                    Text("Your module is successfully communicating with your phone.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else {
                                                    Text("Your module can hold 16 hours of your latest data. Try to connect your module to your phone via bluetooth to unload the data to your phone, prevent data loss, and see current recommendations.\n\n**You can check the following:**\n\u{2022} Turn on your phone’s bluetooth if it is turned off\n\u{2022} Check that your phone’s bluetooth is paired to your module\n\u{2022} Check that the module and phone are within 6 feet\n\u{2022} Confirm that your module is turned on\n\u{2022} Replace the battery if its power level is low\n\u{2022} If problem persists, the module might be malfunctioning. Please report the error so that we can diagnose and fix it.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                            }
                                            else {
                                                if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == true {
                                                    Text("Your phone is connected to the internet.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == false {
                                                    Text("Your phone is connected to the internet. You can still use your app to manage settings or view personal hydration insights based on previously synced and updated data.")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else if modelData.isNetworkConnected == false && modelData.isCHDeviceConnected == true {
                                                    Text("Your latest data is being stored on your  phone. Once it connects to the internet, your data will update to the cloud and the latest analysis and projections will be available.\n\n**In the meantime, you can try the following:**\n\u{2022} Disable airplane mode, if enabled\n\u{2022} Enable wifi and / or mobile data, if disabled\n\u{2022} Wait until you are in wifi or mobile data range\n\u{2022} Server may be temporarily down, check again in a few hours")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                                else {
                                                    Text("Once your phone connects to the internet, any data synced to your phone will update to the cloud.\n\n**In the meantime, you can try the following:**\n\u{2022} Disable airplane mode, if enabled\n\u{2022} Enable wifi and / or mobile data, if disabled\n\u{2022} Wait until you are in wifi or mobile data range\n\u{2022} Server may be temporarily down, check again in a few hours")
                                                        .font(.custom("Roboto-Regular", size: ontSizeToubleshootText))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .onAppear() {
                                                            getExpandedToubleshoot()
                                                        }
                                                }
                                            }

                                            Button(action: {
                                                self.isSupportPresented = true
                                            }) {
                                                Text("GET HELP >")
                                                    .font(.custom("Oswald-Regular", size: 20))
                                                    .foregroundColor(Color(hex: generalCHAppColors.connexSelectionColor))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                                    .onAppear() {
                                                        getExpandedToubleshoot()
                                                    }
                                            }
                                            .trackRUMTapAction(name: "conn-gethelp")
                                            .padding(.top, -15)
                                            .uiKitFullPresent(isPresented: $isSupportPresented, content: { closeHandler in
                                                InformationViews(currInfoScreen: .support, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                                    .environmentObject(modelData)
                                           })
                                        }
// Need to get light gray background working.
//                                        .background(Color(hex: generalCHAppColors.connexLightGrayBackground))
                                    }   // if isExpanded
                                }
                                .frame(height: isExpanded ? (languageCode == "ja" ? 550 : 500) : 120)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color(.white))
                                .cornerRadius(10)
                                .shadow(radius: 10, y: 15)
                            }
                            .padding()
                            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 2.0)) {
                                    isExpanded.toggle()
                                }
                            }
                        }
                    }
                    .trackRUMView(name: "ConnectivityModifier")
                }
            }
            .padding(.top, 15)
            .animation(.spring(), value: 1.0)
        )
    }

    func getCHDeviceBatteryLevel() -> Image {
        // 30 days total battery life or is there a better way
        let days = modelData.chDeviceBatteryLvl
        if days <= 5 {
            return Image("Connex - battery level 0")
        }
        else if days <= 30 {
            return Image("Connex - battery level 1")
        }
        else if days <= 40 {
            return Image("Connex - battery level 2")
        }
        else if days <= 50 {
            return Image("Connex - battery level 3")
        }

        return Image("Connex - battery level 4")
    }

    func getExpandedToubleshoot() {
        if self.isModuleView {
            modelData.isCHDeviceConnected = BLEManager.bleSingleton.sensorConnected
            if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == true {
                isLargeToubleshoot = false
            }
            else if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == false {
                isLargeToubleshoot = true
            }
            else if modelData.isNetworkConnected == false && modelData.isCHDeviceConnected == true {
                isLargeToubleshoot = false
            }
            else {
                isLargeToubleshoot = true
            }
        }
        else {
            if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == true {
                isLargeToubleshoot = false
            }
            else if modelData.isNetworkConnected == true && modelData.isCHDeviceConnected == false {
                isLargeToubleshoot = false
            }
            else if modelData.isNetworkConnected == false && modelData.isCHDeviceConnected == true {
                isLargeToubleshoot = true
            }
            else {
                isLargeToubleshoot = true
            }
        }
    }

}
