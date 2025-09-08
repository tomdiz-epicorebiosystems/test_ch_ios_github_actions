//
//  Step5OverviewSetupComplete.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/28/25.
//

import SwiftUI

struct Step5OverviewSetupComplete: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            Text("Setup Completed")
                .font(.custom("Oswald-Regular", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 0)
                .accessibility(identifier: "text_step5overviewsetupcomplete_setupcompleted")

            Image("Onbarding - Way to go")
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "image_step5overviewsetupcomplete_go")

            Text("You’re good to go!")
                .font(.custom("Roboto-Medium", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibility(identifier: "text_step5overviewsetupcomplete_good")

            Text("You can revisit instructions any time for app pairing, patch application & overview.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
                .accessibility(identifier: "text_step5overviewsetupcomplete_revisit")

            Image("Congradulations View")
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "image_step5overviewsetupcomplete_congrates")

            Spacer()
            
            Button(action: {
                modelData.isOnboardingComplete = true
                navigate(.unwind(.clearNavPath))
            }) {
                Text("ENTER THE APP")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_step5overviewsetupcomplete_enterapp")

            }
            .padding(.bottom, 20)
            .accessibility(identifier: "button_step5overviewsetupcomplete_enterapp")

        }
        .trackRUMView(name: "Step5OverviewEndOfShiftView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    Step5OverviewSetupComplete()
}
