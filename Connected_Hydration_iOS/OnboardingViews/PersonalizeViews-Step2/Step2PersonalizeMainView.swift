//
//  Step2PersonalizeMainView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/24/23.
//

import SwiftUI

struct Step2PersonalizeMainView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var isPhysiologyPresent = false
    @State var currentWeightValue = ""

    var body: some View {
        VStack {
            Text("PERSONALIZE")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_step2personalizemainview_personalize")

            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
            
            Image("Personalize - Dots 1")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .accessibility(identifier: "image_step2personalizemainview_progress_1")

            Text("This information helps tailor a hydration recommendation specific to you. It is not shared.")
                .font(.custom("Roboto-Regular", size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .accessibility(identifier: "text_step2personalizemainview_information")

            if self.modelData.networkAPIError {
                Text("Unable to update user data on server.")
                    .font(.custom("Roboto-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.red)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .onAppear() {
                        self.modelData.networkAPIError = false
                    }
                    .accessibility(identifier: "text_step2personalizemainview_server")

            }

            PhysiologyInformationView(showHeader: false, isEditing: true, showOKCancelOption: false, isPhysiologyShowing: $isPhysiologyPresent, currentWeightValue: $currentWeightValue)
                .environmentObject(modelData)
            
            Spacer()
            
            Button(action: {
                navigate(.push(.step2SharingMainView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step2personalizemainview_continue")

            }
            .padding(.bottom, 40)
            .accessibility(identifier: "button_step2personalizemainview_continue")

        }
        .trackRUMView(name: "Step2PersonalizeMainView")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}
