//
//  ios14Step1SignUpEnterCodeView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/19/23.
//

import SwiftUI

struct ios14Step1SignUpEnterCodeView: View {
    @EnvironmentObject var modelData: ModelData

    @Binding var isStep1Presented: Bool
    @Binding var isCheckEmailPresented: Bool

    @State private var verificationCode = ""
    @State private var isAccountCreatedPresented = false
    @State private var showNetworkProgressView = false
    @State private var handlingNetworkAPI = false
    @State private var isEnterCodePresent = false

    init(isStep1Presented: Binding<Bool>, isCheckEmailPresented: Binding<Bool>) {
        _isStep1Presented = isStep1Presented
        _isCheckEmailPresented = isCheckEmailPresented
        //print("** Step1SignUpEnterCodeView init() called")
    }

    var body: some View {
        if self.modelData.userAuthenticated == true {
            VStack {}
            .onAppear() {
                self.isAccountCreatedPresented = true
                self.handlingNetworkAPI = false
                self.modelData.userAuthenticated = false
            }
        }
        else if showNetworkProgressView == true && self.handlingNetworkAPI == false {
            VStack {}
            .onAppear() {
                self.showNetworkProgressView = false
            }
        }
        else {
            ZStack {
                VStack {

                    NavigationLink(destination: ios14Step1SignUpAccountCreatedView(isStep1Presented: $isStep1Presented, isAccountCreatedPresented: $isAccountCreatedPresented, isCheckEmailPresented: $isCheckEmailPresented, isEnterCodePresent: $isEnterCodePresent).navigationBarBackButtonHidden(true), isActive: $isAccountCreatedPresented) { }

                    Text("SIGN UP")
                        .font(.custom("Oswald-Regular", size: 20))
                        .foregroundColor(Color.white)
                    
                    Rectangle()
                        .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                        .frame(height: 1.0)
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    Image("SignUpMain - Dots 3")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    
                    Text("Enter verification code received by email:")
                        .font(.custom("Roboto-Regular", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                    
                    TextField("", text: $verificationCode)
                        .onReceive(verificationCode.publisher.collect()) {
                            self.verificationCode = String($0.prefix(8))
                        }
                        .font(Font.largeTitle.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(5)
                        .background(Color.gray)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .frame(width: 200, height: 120)
                        .keyboardType(.numberPad)
                    
                    NavigationLink(destination: Step1SignUpVerificationFailedView(serverError: modelData.networkManager.serverError?.errorDescription ?? "Unknown server API issue", previousCode: verificationCode).navigationBarBackButtonHidden(true), isActive: $modelData.networkAPIError) { }

                    Button(action: {
                        modelData.networkManager.modelData = modelData
                        modelData.networkManager.AuthenticateWithCode(email: modelData.userEmailAddress, verificationCode: verificationCode)
                        
                        handlingNetworkAPI = true
                        showNetworkProgressView = true
                    }) {
                        Text("SUBMIT")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 180, height: 50)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()

                    Button(action: {
                        guard let number = URL(string: "tel://+1-617-397-3756") else { return }
                        if UIApplication.shared.canOpenURL(number) {
                            UIApplication.shared.open(number)
                        } else {
                            print("Can't open url on this device")
                        }
                    }) {
                        Text("Call for Support")
                            .underline()
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 40)

                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear() {
                    if modelData.deepLinkCode.isEmpty == false {
                        verificationCode = modelData.deepLinkCode
                        modelData.networkManager.modelData = modelData
                        modelData.networkManager.AuthenticateWithCode(email: modelData.userEmailAddress, verificationCode: modelData.deepLinkCode)
                        modelData.deepLinkCode = ""
                        handlingNetworkAPI = true
                        showNetworkProgressView = true
                    }
                    else {
                        handlingNetworkAPI = false
                        showNetworkProgressView = false
                    }
                }
                .navigationBarItems(leading: Button(action : {
                    self.isCheckEmailPresented = false
                }){
                    Text("< BACK")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white)
                })

                if showNetworkProgressView == true {
                    NetworkProgressView()
                }
            }
            .background(Color(hex: generalCHAppColors.onboardingDarkBackground)
                .edgesIgnoringSafeArea(.all))
            .onAppear() {
                modelData.networkAPIError = false
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
}
