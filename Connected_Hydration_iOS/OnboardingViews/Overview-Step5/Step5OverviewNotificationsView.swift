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
                    .accessibility(identifier: "text_step5overviewnotificationsview_continue")
                
            }
            .padding(.bottom, 10)
            .accessibility(identifier: "button_step5overviewnotificationsview_continue")

            Button(action: {
                modelData.isOnboardingComplete = true
            }) {
                Text("Skip Overview")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_step5overviewnotificationsview_skip")

            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step5overviewnotificationsview_skip")

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
            .accessibility(identifier: "text_overviewshareinfo2view_types")

        HStack {
            Image("Overview - Short Vibration")
                .accessibility(identifier: "image_overviewshareinfo2view_short")

            Text("Short vibration alerts  you to drink a bottle of water.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .accessibility(identifier: "text_overviewshareinfo2view_short")

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 10)
        .padding(.trailing, 10)

        HStack {
            Text("Continuous vibration alarm means you are dehydrated.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .accessibility(identifier: "text_overviewshareinfo2view_alarm")

            Image("Overview - Alarm")
                .accessibility(identifier: "image_overviewshareinfo2view_alarm")

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
                    .accessibility(identifier: "image_overviewshareinfo2view_armband")

            }
            else {
                Image("Overview - Bottom Button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .accessibility(identifier: "image_overviewshareinfo2view_patch")

            }

            Text("To stop the continuous vibration alarm for dehydration, press the large button on the module.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .accessibility(identifier: "text_overviewshareinfo2view_continuous")

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.top, -10)
    }
}
