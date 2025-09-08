//
//  Step5OverviewNotificationsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step5OverviewNotificationsView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {

        VStack {
            OverviewTopView(progressDots: "2")
            
            OverviewShareInfo2View()

            Spacer()
            
            Button(action: {
                navigate(.push(.step5OverviewTrackIntakeView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .padding(.bottom, 10)
            
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
        .trackRUMView(name: "Step5OverviewNotificationsView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct OverviewShareInfo2View: View {

    @EnvironmentObject var modelData: ModelData

    var body: some View {
        Text("Module Notification Types")
            .font(.custom("Roboto-Regular", size: 24))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 5)

        HStack {
            Image("Overview - Short Vibration")

            Text("Short vibration alerts  you to drink a bottle of water.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 10)
        .padding(.trailing, 10)

        HStack {
            Text("Continuous vibration alarm means you are dehydrated.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Image("Overview - Alarm")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 10)
        .padding(.trailing, 10)

        HStack {
            if (modelData.isCHArmBandConnected) {
                Image("Overview - SV - armband")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            else {
                Image("Overview - Bottom Button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }

            Text("To stop the continuous vibration alarm for dehydration, press the large button on the module.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.top, -10)
    }
}
