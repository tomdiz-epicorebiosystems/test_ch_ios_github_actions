//
//  Step5OverviewTrackIntakeView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step5OverviewTrackIntakeView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            OverviewTopView(progressDots: "3")

            OverviewShareInfo3View()

            Spacer()

            Image("Overview - Intake")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibility(identifier: "image_step5overviewtrackintakeview_intake")

            Spacer()

            Button(action: {
                navigate(.push(.step5ModuleButtonTrackIntakeView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step5overviewtrackintakeview_continue")

            }
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step5overviewtrackintakeview_continue")

            Button(action: {
                modelData.isOnboardingComplete = true
                navigate(.unwind(.clearNavPath))
            }) {
                Text("Skip Overview")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_step5overviewtrackintakeview_skip")

            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step5overviewtrackintakeview_skip")

        }
        .trackRUMView(name: "Step5OverviewTrackIntakeView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct OverviewShareInfo3View: View {
    var body: some View {
        Text("Tracking Intake")
            .font(.custom("Roboto-Regular", size: 24))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_overviewshareinfo3view_track")

        Text("After you finish a drink, open the app and tap “Track Intake”. Select items from menu and save. This tracks the items’ sodium and water content.")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_overviewshareinfo3view_finish")

    }
}
