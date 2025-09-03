//
//  InfoPopoverModifier.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/1/23.
//

import SwiftUI

public class InfoPopoverData {
    public enum InfoPopoverType {
        case basic

        var backgroundColor: Color {
            return .white
        }
    }

    var type: InfoPopoverType = .basic

    public init(type: InfoPopoverType) {
        self.type = type
    }
}

public struct InfoPopoverModifier: ViewModifier {

    @EnvironmentObject var modelData: ModelData
    @Binding var infoData: InfoPopoverData?
    @State private var isAppOverviewPresented = false
    @State private var isPatchApplicationPresented = false
    @State private var isModulePairingPresented = false
    @State private var isUrineColorChartPresented = false
    @State private var isHydrationGuidesPresented = false
    @State private var isSodiumEqPresented = false
    @State private var isSupportPresented = false

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    public init(model: Binding<InfoPopoverData?>) {
        _infoData = model
    }

    public func body(content: Content) -> some View {
        content.overlay(
            VStack {
                if infoData != nil {
                    GeometryReader { geometry in
                        ZStack {
                            // a transparent rectangle under everything. Used to close view
                            Rectangle()
                                .frame(width: geometry.size.width, height: geometry.size.height + 600)
                                .opacity(0.001)
                                .layoutPriority(-1)
                                .onTapGesture {
                                    infoData = nil
                                }

                            VStack {
                                Triangle()
                                    .foregroundColor(Color.white)
                                    .frame(width: 30, height: 25)
                                    .padding(.bottom, -10)
                                    .offset(x: languageCode == "ja" ? 125 : 75)
                                
                                VStack {
                                    Text("INSTRUCTIONS")
                                        .font(.custom("Oswald-Regular", size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(Color(hex: "#009EDF"))
                                        .padding(.bottom, 5)

                                    Button(action: {
                                        self.isAppOverviewPresented = true
                                    }) {
                                        Text("APP OVERVIEW")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .trackRUMTapAction(name: "info-appoverview")
                                    .uiKitFullPresent(isPresented: $isAppOverviewPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .appOverview, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                    })
                                    .buttonStyle(InfoButtonStyle())
                                    .padding(.bottom, 5)

                                    Button(action: {
                                        self.isPatchApplicationPresented = true
                                    }) {
                                        if (modelData.isCHArmBandConnected) {
                                            Text("MODULE ATTACHMENT")
                                                .font(.custom("Oswald-Regular", size: 18))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                        }
                                        else {
                                            Text("PATCH APPLICATION")
                                                .font(.custom("Oswald-Regular", size: 18))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                        }
                                    }
                                    .trackRUMTapAction(name: "info-patchapp")
                                    .uiKitFullPresent(isPresented: $isPatchApplicationPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .patchApp, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                   })
                                    .buttonStyle(InfoButtonStyle())
                                    .padding(.bottom, 5)

                                    Button(action: {
                                        self.isModulePairingPresented = true
                                    }) {
                                        Text("MODULE PAIRING")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .trackRUMTapAction(name: "info-modulepair")
                                    .uiKitFullPresent(isPresented: $isModulePairingPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .modulePairing, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                    })
                                    .buttonStyle(InfoButtonStyle())
                                    .padding(.bottom, 5)

                                    Text("REFERENCE")
                                        .font(.custom("Oswald-Regular", size: 18))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(Color(hex: "#009EDF"))
                                        .padding(.bottom, 5)

                                    Button(action: {
                                        self.isSodiumEqPresented = true
                                    }) {
                                        Text("SODIUM EQUIVALENTS")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .trackRUMTapAction(name: "info-sodiumequiv")
                                    .uiKitFullPresent(isPresented: $isSodiumEqPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .sodiumEq, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                    })
                                    .padding(.bottom, 5)
                                    .buttonStyle(InfoButtonStyle())

                                    Button(action: {
                                        self.isUrineColorChartPresented = true
                                    }) {
                                        Text("URINE COLOR CHART")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .uiKitFullPresent(isPresented: $isUrineColorChartPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .urineColorChart, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                    })
                                    .padding(.bottom, 5)
                                    .buttonStyle(InfoButtonStyle())

/*
                                    Button(action: {
                                        self.isHydrationGuidesPresented = true
                                    }) {
                                        Text("HYDRATION GUIDE")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .uiKitFullPresent(isPresented: $isHydrationGuidesPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .hydrationGuides, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                    })
                                    .padding(.bottom, 5)
                                    .buttonStyle(InfoButtonStyle())
*/

                                    Button(action: {
                                        self.isSupportPresented = true
                                    }) {
                                        Text("SUPPORT")
                                            .font(.custom("Oswald-Regular", size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            .foregroundColor(Color(hex: generalCHAppColors.grayStandardText))
                                    }
                                    .trackRUMTapAction(name: "info-support")
                                    .uiKitFullPresent(isPresented: $isSupportPresented, content: { closeHandler in
                                        InformationViews(currInfoScreen: .support, isAppOverviewPresented: $isAppOverviewPresented, isPatchApplicationPresented: $isPatchApplicationPresented, isModulePairingPresented: $isModulePairingPresented, isUrineColorChartPresented: $isUrineColorChartPresented, isHydrationGuidesPresented: $isHydrationGuidesPresented, isSodiumEqPresented: $isSodiumEqPresented, isSupportPresented: $isSupportPresented)
                                            .environmentObject(modelData)
                                    })
                                    .padding(.bottom, 5)
                                    .buttonStyle(InfoButtonStyle())

                                    Spacer()
                                }
                                //.frame(width: 180, height: 360, alignment: .trailing)
                                .frame(width: (languageCode == "ja" ? 290: 235), height: 300, alignment: .trailing)
                                .padding()
                                .background(infoData?.type.backgroundColor ?? .clear)
                                .cornerRadius(10)
                                .shadow(radius: 10, y: 15)
                                .foregroundColor(Color(UIColor.lightGray))
                            }
                            .offset(x: geometry.size.width - (languageCode == "ja" ? 330.0 : 250.0))    // use geometry for length of view and subtract window width to get placement
                                                                        // Make window width statics
                        }
                        .padding()
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    }
                    .trackRUMView(name: "InfoPopoverModifier")
                }
            }
            .padding(.top, 15)
            .animation(.spring(), value: 1.0)
        )
    }

}

struct InfoButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .background(configuration.isPressed ? Color(hex:"#BFECF9") : Color(.white))
  }

}
