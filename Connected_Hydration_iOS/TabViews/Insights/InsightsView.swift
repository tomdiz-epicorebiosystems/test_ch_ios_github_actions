//
//  InsightsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//

import SwiftUI

struct InsightsView: View {

    @EnvironmentObject var modelData: ModelData
    @Binding var tabNothing: Tab

    @State private var isImperialOn = "true"
    @State private var backgroundStatusColor = "11314c"
    @State private var url : URL = URL(string: "https://ch.epicorebiosystems.com/mobile/insights?color=11314c&imperial=true")!
    @State private var prevUrl : URL = URL(string: "https://example.com")!
    @State private var isInsightsWebViewPresented : Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                BgStatusView() {}
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: true) {
                        
                        UserSweatProfileView()
                            .onAppear() {
                                if (modelData.suggestIntakeExpandedButtonPressed) {
                                    modelData.scrollToPassive += 1
                                }
                                /*                            if (modelData.suggestIntakeExpandedButtonPressed) {
                                 modelData.suggestIntakeExpandedButtonPressed = false
                                 DispatchQueue.main.async {
                                 reader.scrollTo(102, anchor: .center)
                                 }
                                 }*/
                            }
                        
                        if modelData.isNetworkConnected == true {
                            
                            InsightsWebView(url: $url, prevUrl: $prevUrl, isNetworkConnected: $modelData.isNetworkConnected, isInsightsWebViewPresented: $isInsightsWebViewPresented)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 1080)
                                .padding(.top, 20)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                .padding(.bottom, 40)
                                .id(102)
                                .onAppear() {
                                    if (modelData.suggestIntakeExpandedButtonPressed) {
                                        modelData.scrollToPassive += 1
                                    }
                                }
                                .onReceive(modelData.$scrollToPassive, perform: { _ in
                                    if (modelData.suggestIntakeExpandedButtonPressed) {
                                        DispatchQueue.main.async {
                                            reader.scrollTo(102, anchor: .top)
                                            modelData.suggestIntakeExpandedButtonPressed = false
                                        }
                                    }
                                })
                        }
                        else {
                            Text("More Insights will be availble once there is an Internet connection.")
                                .font(.custom("Roboto-Regular", size: 14))
                                .padding(.top, 30)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }   // ScrollView
                .clipped()
                
                BgTabIntakeExtensionView(tabSelection: $tabNothing)
                    .clipped()
            }
            .addToolbar()
        }
        .trackRUMView(name: "InsightsView")
        .onAppear() {
            modelData.rootViewId = UUID()

            modelData.networkManager.modelData = modelData
            modelData.networkManager.getAvgSweatVolumeSodiumConcentration()

            if modelData.unitsChanged == "0" {
                isImperialOn = "false"
            }
            else {
                isImperialOn = "true"
            }

            if modelData.sweatDashboardViewStatus == 0 {
                backgroundStatusColor = "11314c"
            }
            else if modelData.sweatDashboardViewStatus == 1 {
                backgroundStatusColor = "d7b20c"
            }
            else {
                backgroundStatusColor = "b02023"
            }
            
            isInsightsWebViewPresented = true
            
            url = URL(string: "https://\(modelData.epicoreHost)/mobile/insights?color=\(backgroundStatusColor)&imperial=\(isImperialOn)")!
            
        }
        .onDisappear() {
            isInsightsWebViewPresented = false
        }
    }
}
