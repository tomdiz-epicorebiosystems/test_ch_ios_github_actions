//
//  Step5OverviewEndOfShiftView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step5OverviewEndOfShiftView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                OverviewTopView(progressDots: "5")
                
                OverviewShareInfo4View()
                
                Spacer(minLength: 10)
                
                Button(action: {
                    navigate(.push(.step5OverviewSetupComplete))
                }) {
                    Text("DONE")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        .accessibility(identifier: "text_step5overviewendOfshiftview_done")

                }
                .padding(.bottom, 10)
                .accessibility(identifier: "button_step5overviewendOfshiftview_done")

            }
        }
        .trackRUMView(name: "Step5OverviewEndOfShiftView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct OverviewShareInfo4View: View {

    @EnvironmentObject var modelData: ModelData

    var body: some View {
        Text("At the End your Shift...")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 5)
            .accessibility(identifier: "text_overviewshareinfo4view_eos")

        Text("Enter any unlogged intake for your shift.")
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .accessibility(identifier: "text_overviewshareinfo4view_unlogged")

        HStack {
            Text("In the app, check that all data has synced.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
                .accessibility(identifier: "text_overviewshareinfo4view_synced")

            Image("Overview - Sync")
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "image_overviewshareinfo4view_synced")

        }
        .padding(.trailing, 20)
        .padding(.leading, 20)

        HStack {
            if (modelData.isCHArmBandConnected) {
                Image("Overview - CH - Top Button")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_overviewshareinfo4view_armband")

            }
            else {
                Image("Overview - Top Button")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_overviewshareinfo4view_patch")

            }

            Text("Long-press power button. Module will flash orange and turn off.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 20)
                .accessibility(identifier: "text_overviewshareinfo4view_long")

        }
        .padding(.trailing, 20)
        .padding(.leading, 20)

        if (modelData.isCHArmBandConnected) {
            HStack {
                Text("If washing the Armband, be sure to detach module first and set aside for next use.")
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_overviewshareinfo4view_detach")

                Image("Overview - CH - Peel")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_overviewshareinfo4view_armband_remove")

            }
            .padding(.trailing, 20)
            .padding(.leading, 20)
        }
        else {
            HStack {
                Text("Grab adhesive patch from top and peel. Disconnect module and discard patch.")
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_overviewshareinfo4view_peel")

                Image("Overview - Peel")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "image_overviewshareinfo4view_patch_peel")

            }
            .padding(.trailing, 20)
            .padding(.leading, 20)
        }

    }
}
