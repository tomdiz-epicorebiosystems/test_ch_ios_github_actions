//
//  Step4PatchApplicationCleanSkinView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step4PatchApplicationCleanSkinView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            
            Spacer(minLength: 10)
            
            PatchApplicationTopView(progressDots: "2")

            PatchApplicationShareInfo2View()
            
            Spacer(minLength: 10)

            Button(action: {
                navigate(.push(.step4PatchApplicationApplyView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step4patchapplicationcleanskinview_continue")
            }
            .accessibility(identifier: "button_step4patchapplicationcleanskinview_continue")

            Spacer(minLength: 20)
            
        }
        .trackRUMView(name: "Step4PatchApplicationCleanSkinView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct PatchApplicationShareInfo2View: View {
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        Text("Clean skin with alcohol wipe on flat part of  upper arm (about 2 finger width from elbow). Wait at least 30 seconds until completely dry.")
            .font(.custom("Roboto-Regular", size: languageCode == "ja" ? 16 : 18))
            .foregroundColor(Color.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .accessibility(identifier: "text_patchapplicationshareinfo2view_clean")

        Image("PatchApplication - Clean 1")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "image_patchapplicationshareinfo2view_clean_1")

        HStack {
            Text("Remove both top and bottom liners from device.")
                .font(.custom("Roboto-Regular", size: languageCode == "ja" ? 16 : 18))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.white)
                .padding(.leading, 20)
                .accessibility(identifier: "text_patchapplicationshareinfo2view_remove")

            Image("PatchApplication - Clean 2")
                .padding(.trailing, 20)
                .accessibility(identifier: "image_patchapplicationshareinfo2view_clean_2")

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, -10)
    }
}
