//
//  Step4PatchApplicationMainView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step4PatchApplicationMainView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        VStack {
            PatchApplicationTopView(progressDots: "1")
            
            Text("Careful patch application is necessary for dependable results.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 20)

            Image("PatchApplication - careful")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
            
            HStack {
                Image("PatchApplication - Info")
                
                Text("Instructions will always be available later from the Info Menu of this app.")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Spacer()
            
            Button(action: {
                navigate(.push(.step4PatchApplicationCleanSkinView))
            }) {
                Text("CONTINUE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .padding(.bottom, 20)
            
        }
        .trackRUMView(name: "Step4PatchApplicationMain")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct PatchApplicationTopView: View {
    
    var progressDots: String

    var body: some View {
        Text("MODULE ATTACHMENT: PATCH")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
        
        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        Image("PairModule - Dots \(progressDots)")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
    }
}
