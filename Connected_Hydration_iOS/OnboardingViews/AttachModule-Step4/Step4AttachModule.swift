//
//  Step4AttachModule.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/7/25.
//

import SwiftUI
import BLEManager

struct Step4AttachModule: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        VStack {
            Text("MODULE ATTACHMENT")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_step4attachmodule_attachment")

            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.bottom, 5)

            ModuleApplicationShareInfoView()

            Spacer()

            HStack(spacing: 5) {
                Image("Nav Info Button")
                    .padding(.leading, 20)
                    .accessibility(identifier: "image_step4attachmodule_info")

                Text("Instructions will always be available later from the Info Menu of this app.")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 20)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibility(identifier: "text_step4attachmodule_instructions")

            }
            .padding(.bottom, 10)

            Button(action: {
                modelData.isCHArmBandConnected = isCHArmBand(modelData.firmwareRevText)
                if modelData.isCHArmBandConnected {
                    navigate(.push(.step4ArmBandApplicationStrapTighten))
                }
                else {
                    navigate(.push(.step4PatchApplicationMainView))
                }
            }) {
                Text("I’VE ATTACHED THE MODULE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: languageCode == "ja" ? 230 : 210, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step4attachmodule_attached")

            }
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step4attachmodule_attached")

        }
        .trackRUMView(name: "Step4AttachModule")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }

}

struct ModuleApplicationShareInfoView: View {
    var body: some View {
        Text("With the module turned on, snap the module into the clip of your Patch or your Armband (you will have received one of these):")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .fixedSize(horizontal: false, vertical: true)
            .accessibility(identifier: "text_moduleapplicationshareinfoview_turnedon")

        Text("Accessory: Patch")
            .font(.custom("Oswald-Regular", size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .accessibility(identifier: "text_moduleapplicationshareinfoview_patch")

        Image("ArmBand Step 1-1")
            .resizable()
            .scaledToFit()
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .accessibility(identifier: "image_moduleapplicationshareinfoview_armband_1")

        Spacer()

        Text("Accessory: Armband")
            .font(.custom("Oswald-Regular", size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .accessibility(identifier: "text_moduleapplicationshareinfoview_armband")

        Image("ArmBand Step 1-2")
            .resizable()
            .scaledToFit()
            .padding(.leading, 70)
            .padding(.trailing, 70)
            .accessibility(identifier: "image_moduleapplicationshareinfoview_armband_2")

    }
}
