//
//  Step4PatchApplicationApplyView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/30/23.
//

import SwiftUI

struct Step4PatchApplicationApplyView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {

                PatchApplicationTopView(progressDots: "3")
                
                Spacer(minLength: 10)

                PatchApplicationShareInfo3View()
                
                Spacer(minLength: 10)
                
                Button(action: {
                    navigate(.push(.step4PatchApplicationApplySleeveView))
                }) {
                    Text("CONTINUE")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .padding(.bottom, 20)
            }
        }
        .trackRUMView(name: "Step4PatchApplicationApplyView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))}
}

struct PatchApplicationShareInfo3View: View {
    var body: some View {
        
        HStack {
            Image("PatchApplication - Apply 1")
            
            Text("Press module firmly onto flat part of the upper arm (about 2 finger width from elbow).")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        
        HStack {
            Text("Smooth outside “skirt” material firmly onto skin.")
                .font(.custom("Roboto-Regular", size: 18))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.white)
            
            Image("PatchApplication - careful")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        
        Text("Be sure to create a secure seal between the patch and your skin.")
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(Color.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 10)
            .padding(.bottom, 10)
    }
}
