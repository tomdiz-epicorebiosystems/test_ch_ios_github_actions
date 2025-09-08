//
//  SignInViews.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/17/23.
//

import SwiftUI

struct StartOnboardingView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        GeometryReader { geoMain in
            VStack {
                                     
                ZStack(alignment: .bottom) {
                    Image("SignIn - background")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geoMain.size.width)
                        .accessibility(identifier: "image_startonboardingview_background")
                        .overlay(
                            VStack {
                                Image("SignIn - Epicore Logo")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.75)
                                    .accessibility(identifier: "image_startonboardingview_logo")

                                Image("SignIn - Worker")
                                    .resizable()
                                    .scaledToFit()
                                    .accessibility(identifier: "image_startonboardingview_worker")
                            },
                            alignment: .bottom
                        )
                }
                
                Spacer()

                Button(action: {
                    modelData.onboardingStep = 1
                    navigate(.push(.getStartedOnboarding))
                    logger.info("onBoarding", attributes: ["main": "create_account_button_pressed"])
                }) {
                    Text("CREATE A NEW ACCOUNT")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 200, height: 50)
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_startonboardingview_create_new_account")
                }
                .trackRUMTapAction(name: "create_new_account")
                .accessibility(identifier: "button_startonboardingview_create_new_account")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

                HStack(spacing: 5){
                    Text("Already have an account?")
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(.white)
                        .accessibility(identifier: "text_startonboardingview_already")

                    Text("LOG IN")
                        .accessibility(identifier: "button_startonboardingview_login")
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(.white)
                        .underline()
                        .bold()
                        .onTapGesture {
                            modelData.onboardingStep = 1
                            self.modelData.showNoAccountFound = false
                            navigate(.push(.logInEmailOnboarding))
                            logger.info("onBoarding", attributes: ["main": "log_in_button_pressed"])
                        }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)

                HStack(spacing: 5.0) {
                    Text("\u{00A9}2025 Epicore Biosystems Inc.")
                        .font(.custom("Oswald-Bold", size: 12))
                        .foregroundColor(Color.gray)
                        .accessibility(identifier: "text_startonboardingview_copyright")

                    Text("Version " + Bundle.main.releaseVersionNumber! + " Build " + Bundle.main.buildVersionNumber!)
                        .font(.custom("Oswald-Regular", size: 12))
                        .foregroundColor(Color.gray)
                        .accessibility(identifier: "text_startonboardingview_version")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, 20)
        }
        .trackRUMView(name: "StartOnboardingView")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}
