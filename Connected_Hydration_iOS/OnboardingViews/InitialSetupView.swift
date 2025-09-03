//
//  InitialSetupView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/18/23.
//

import SwiftUI

struct InitialSetupView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var isCheckEmailPresented = false
    @State var isAccountCreatedPresented = false

    var body: some View {
        VStack {
            TopTitleInitialSetupView()

            StepsButtonView()
        }
        .padding(.bottom, 20)
        .trackRUMView(name: "InitialSetupView")
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct StepNumberView: View {
    
    @EnvironmentObject var modelData: ModelData

    var viewNumber: String

    var body: some View {
        let currStep = Int(viewNumber) ?? 0

        if currStep < modelData.onboardingStep {
            Image(systemName: "checkmark")
                .font(.custom("Orbitron-Regular", size: 36))
                .frame(width: 60, height: 60)
                .foregroundColor(Color.white)
                .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground))
                .clipShape(Circle())
        }
        else if currStep == modelData.onboardingStep {
            Text(viewNumber)
                .font(.custom("Roboto-Bold", size: 36))
                .frame(width: 60, height: 60)
                .foregroundColor(Color.white)
                .background(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                .clipShape(Circle())
        }
        else {
            Text(viewNumber)
                .font(.custom("Roboto-Bold", size: 36))
                .frame(width: 60, height: 60)
                .foregroundColor(Color.white)
                .background(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .clipShape(Circle())
        }
    }
}

struct TopTitleInitialSetupView: View {
    
    var body: some View {
        Text("INITIAL SET UP")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .padding(.top, 20)

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        StepMenuInitialSetupView()
    }
}

struct StepMenuInitialSetupView: View {

    let stepVerticalSpacing = 10.0

    @EnvironmentObject var modelData: ModelData

    var body: some View {
        // Step 1
        HStack {
            StepNumberView(viewNumber: "1")
            
            VStack(spacing: 2) {
                Text("ACCOUNT SETUP")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Text("Set up your secure login")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .padding(.top, 30)
        
        // Step 2
        HStack {
            StepNumberView(viewNumber: "2")
            
            VStack(spacing: 2) {
                Text("PERSONALIZE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Text("Tailor your hydration\nrecommendations")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .padding(.top, stepVerticalSpacing)
        
        // Step 3
        HStack {
            StepNumberView(viewNumber: "3")
            
            VStack(spacing: 2) {
                Text("PAIR MODULE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Text("Enable data transfer from\nmodule to phone")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .padding(.top, stepVerticalSpacing)
        
        // Step 4
        HStack {
            StepNumberView(viewNumber: "4")
            
            VStack(spacing: 2) {
                Text("ATTACH MODULE")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Text("Ensure proper attachment\nto an accessory")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .padding(.top, stepVerticalSpacing)
        
        // Step 5
        HStack {
            StepNumberView(viewNumber: "5")
            
            VStack(spacing: 2) {
                Text("OVERVIEW")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Text("A quick orientation of the basics")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .padding(.top, stepVerticalSpacing)

        Spacer()
    }
}

struct StepsButtonView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    private let buttonWidth: CGFloat = 200

    var body: some View {
        if modelData.onboardingStep == 1 {
            Button(action: {
                // save current step to user defaults and return here when app is restarted
                navigate(.push(.createAccountMainView))
                logger.info("onBoarding", attributes: ["InitialSetupView": "Step 1"])
            }) {
                Text("BEGIN: ACCOUNT SETUP")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: buttonWidth, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "Step1")
        }
        else if modelData.onboardingStep == 2 {
            Button(action: {
                // save current step to user defaults and return here when app is restarted
                navigate(.push(.step2PersonalizeMainView))
                logger.info("onBoarding", attributes: ["InitialSetupView": "Step 2"])
            }) {
                Text("NEXT: PERSONALIZE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: buttonWidth, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "Step2")
        }
        else if modelData.onboardingStep == 3 {
            Button(action: {
                // save current step to user defaults and return here when app is restarted
                navigate(.push(.step3PairModuleMainView))
                logger.info("onBoarding", attributes: ["InitialSetupView": "Step 3"])
            }) {
                Text("NEXT: PAIR MODULE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: buttonWidth, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "Step3")
        }
        else if modelData.onboardingStep == 4 {
            Button(action: {
                navigate(.push(.step4AttachModule))
                logger.info("onBoarding", attributes: ["InitialSetupView": "Step 4"])
            }) {
                Text("NEXT: ATTACH MODULE")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: buttonWidth, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "Step4")
        }
        else if modelData.onboardingStep == 5 {
            Button(action: {
                // save current step to user defaults and return here when app is restarted
                navigate(.push(.step5OverviewMainView))
                logger.info("onBoarding", attributes: ["InitialSetupView": "Step 5"])
            }) {
                Text("NEXT: OVERVIEW")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: buttonWidth, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .trackRUMTapAction(name: "Step5")
        }
    }
}
