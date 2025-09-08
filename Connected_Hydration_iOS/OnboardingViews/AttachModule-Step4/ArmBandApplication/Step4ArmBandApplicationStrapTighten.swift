//
//  Step4ArmBandApplicationStrapTighten.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/7/25.
//

import SwiftUI

struct Step4ArmBandApplicationStrapTighten: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            Text("MODULE ATTACHMENT: ARMBAND")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)

            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)

            Image("Personalize - Dots 2")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

            ArmBandApplicationStrapSubView()
            
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
            }
            .padding(.bottom, 40)
        }
        .trackRUMView(name: "Step4ArmBandApplicationStrapTighten")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct ArmBandApplicationStrapSubView: View {
    var body: some View {
        Text("Slide strap around your bicep, pull strap to tighten, then secure it in place using the hook and loop.")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .fixedSize(horizontal: false, vertical: true)

        Image("ArmBand Application - 2")
            .resizable()
            .scaledToFit()
            .padding(.top, 10)
    }
}
