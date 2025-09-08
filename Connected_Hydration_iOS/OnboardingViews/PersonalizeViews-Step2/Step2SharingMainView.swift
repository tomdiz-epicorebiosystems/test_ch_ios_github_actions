//
//  Step2SharingMainView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/24/23.
//

import SwiftUI

struct Step2SharingMainView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            Text("PERSONALIZE")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_step2sharingmainview_personalize")

            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            Image("Personalize - Dots 2")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .accessibility(identifier: "image_step2sharingmainview_progress_2")

            Text("Choose whether to share safety statistics. Your data is never connected to your identity.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .accessibility(identifier: "text_step2sharingmainview_choose")

            DataSharingSettingsView(showHeading: false)
                .environmentObject(modelData)

            Spacer()
            
            Text("You can change your preferences at any time within the \"SETTINGS\" tab of the app.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(20)
                .accessibility(identifier: "text_step2sharingmainview_references")

            Button(action: {
                modelData.onboardingStep = 3
                navigate(.unwind(.initialSetupOnboarding))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step2sharingmainview_continue")

            }
            .padding(.bottom, 40)
            .accessibility(identifier: "button_step2sharingmainview_continue")

        }
        .trackRUMView(name: "Step2SharingMainView")
        .onDisappear() {
            modelData.networkManager.modelData = modelData
            modelData.networkManager.SetUserInfo(epicore: modelData.shareAnonymousDataEpicore, site: modelData.shareAnonymousDataEnterprise)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))

    }
}
