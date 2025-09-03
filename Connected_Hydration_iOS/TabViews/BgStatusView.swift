//
//  BgStatusView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/9/23.
//

import SwiftUI

struct BgStatusView<Content>: View where Content: View {

    @EnvironmentObject var modelData: ModelData

    private let bgImage = Image.init(systemName: "m.circle.fill")
    private let content: Content

    // make these enums - global (already are)
    // ok = 0
    // At Risk = 1
    // Dehydrated = 2

    // Need a global state variable to monitor for here from BLEManager
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body : some View {
        ZStack {
            VStack {
                if modelData.sweatDashboardViewStatus == 0 {
                    Rectangle()
                        .fill(Color(hex: "#11314c"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.horizontal)
                        .clipped()
                }
                else if modelData.sweatDashboardViewStatus == 1 {
                    Rectangle()
                        .fill(Color(hex: "#d7b20c"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.horizontal)
                        .clipped()
                }
                else {
                    Rectangle()
                        .fill(Color(hex: "#b02023"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.horizontal)
                        .clipped()
                }
            }
            VStack {
                HStack {
                    Text("STATUS:")
                        .font(.custom("Oswald-Regular", size: 20))
                        .foregroundColor(.white)
                        .padding(.leading, 40)
                    if modelData.sweatDashboardViewStatus == 0 {
                        Text("OK")
                            .font(.custom("Oswald-Bold", size: 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    else if modelData.sweatDashboardViewStatus == 1 {
                        Text("AT RISK")
                            .font(.custom("Oswald-Bold", size: languageCode == "ja" ? 16 : 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    else {
                        Text("DEHYDRATED")
                            .font(.custom("Oswald-Bold", size: 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    Spacer()
                    if modelData.sweatDashboardViewStatus == 0 {
                        Image("status ok")
                            .padding(.trailing, 40)
                    }
                    else if modelData.sweatDashboardViewStatus == 1 {
                        Image("status AtRisk")
                            .padding(.trailing, 40)
                    }
                    else {
                        Image("status dehydrated")
                            .padding(.trailing, 40)
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
    }
}
