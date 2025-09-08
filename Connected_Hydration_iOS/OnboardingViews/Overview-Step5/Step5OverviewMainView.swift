//
//  Step5OverviewMain.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step5OverviewMainView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            OverviewTopView(progressDots: "1")
            
            OverviewShareInfo1View()
            
            HStack(spacing: 5) {
                Image("Nav Info Button")
                    .padding(.leading, 20)

                Text("Instructions will always be available later from the Info Menu of this app.")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            Spacer()
            
            Button(action: {
                navigate(.push(.step5OverviewNotificationsView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .padding(.bottom, 20)

            Button(action: {
                modelData.isOnboardingComplete = true
            }) {
                Text("Skip Overview")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .accessibility(identifier: "button_change_enterprise_site")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)

        }
        .trackRUMView(name: "Step5OverviewMain")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct OverviewTopView: View {

    @EnvironmentObject var modelData: ModelData

    var progressDots: String

    var body: some View {
        Text("OVERVIEW")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        Image("SignUpMain - Dots \(progressDots)")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
    }
}

struct OverviewShareInfo1View: View {

    @EnvironmentObject var modelData: ModelData

    var body: some View {
        Text("Powering On")
            .font(.custom("Roboto-Regular", size: 24))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 5)
        
        Text("To turn the module on, press the power button. A green light will flash every 10 sec. Device will pair automatically with your phone and start measuring.")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        if (modelData.isCHArmBandConnected) {
            Image("Overview - CH - Top Button")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        else {
            Image("Overview - Top Button")
                .frame(maxWidth: .infinity, alignment: .center)
        }

    }
}
