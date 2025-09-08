//
//  Step5ModuleButtonTrackIntakeView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/7/25.
//

import SwiftUI

struct Step5ModuleButtonTrackIntakeView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            OverviewTopView(progressDots: "4")

            ModuleIntakeShareInfoView()

            Spacer()

            if (modelData.isCHArmBandConnected) {
                Image("Overview - CA - Module Intake")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_step5modulebuttontrackintakeview_armband")

            }
            else {
                Image("Overview - Module Intake")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_step5modulebuttontrackintakeview_patch")

            }

            Spacer()

            Button(action: {
                navigate(.push(.step5OverviewEndOfShiftView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step5modulebuttontrackintakeview_continue")

            }
            .padding(.bottom, 10)
            .accessibility(identifier: "button_step5modulebuttontrackintakeview_continue")

            Button(action: {
                modelData.isOnboardingComplete = true
                navigate(.unwind(.clearNavPath))
            }) {
                Text("Skip Overview")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_step5modulebuttontrackintakeview_skip")

            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step5modulebuttontrackintakeview_skip")

        }
        .trackRUMView(name: "Step5ModuleButtonTrackIntakeView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct ModuleIntakeShareInfoView: View {
    var body: some View {
        Text("Tracking Intake")
            .font(.custom("Roboto-Regular", size: 24))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_moduleintakeshareinfoview_intake")

        Text("For **quick** tracking: push button on module to add one bottle when you drink.")
            .font(.custom("Oswald-Regular", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_moduleintakeshareinfoview_tracking")

        Text("One bottle equals 500ml by default. Change this at any time in the Settings tab.")
            .font(.custom("Roboto-Regular", size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 30)
            .padding(.trailing, 30)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_moduleintakeshareinfoview_bottle")

    }
}
