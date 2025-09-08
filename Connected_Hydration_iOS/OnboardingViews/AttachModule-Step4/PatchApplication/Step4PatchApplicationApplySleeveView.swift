//
//  Step4PatchApplicationApplySleaveView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step4PatchApplicationApplySleeveView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            PatchApplicationTopView(progressDots: "4")

            Spacer()
            
            PatchApplicationShareInfo4View()

            Spacer()
            
            Button(action: {
                modelData.onboardingStep = 5
                navigate(.unwind(.initialSetupOnboarding))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step4patchapplicationapplysleeveview_continue")

            }
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step4patchapplicationapplysleeveview_ontinue")

        }
        .trackRUMView(name: "Step4PatchApplicationApplySleaveView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct PatchApplicationShareInfo4View: View {
    var body: some View {

        Text("(Optional)")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .accessibility(identifier: "text_patchapplicationshareinfo4view_optional")

        Text("If your module comes with a cover, wrap it around your arm over the patch.")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .accessibility(identifier: "text_patchapplicationshareinfo4view_module")

        Image("PatchApplication - Sleave")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
            .accessibility(identifier: "image_patchapplicationshareinfo4view_sleave")

    }
}
