//
//  CreateAccountFlowViews.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/25.
//

import SwiftUI
import KeychainAccess

struct CreateAccountGetStartedView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var isTermsChecked = false
    @State var isTermsPresent = false
    @State var isPrivacyPresent = false

    var body: some View {
        VStack {

            Rectangle()
                .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
                .frame(height: 1.0)
                .edgesIgnoringSafeArea(.horizontal)

            Text("Welcome to Connected Hydration")
                .font(.custom("Roboto-Bold", size: 18))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .foregroundColor(Color.white)

            Text("To get started, gather the Connected Hydration materials that you received.")
                .font(.custom("Oswald-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .foregroundColor(Color.white)

            Text("You’ll also need:")
                .font(.custom("Oswald-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 30)
                .foregroundColor(Color.white)

            HStack(spacing: 5){
                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_phoneicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text("SMART\nPHONE")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                }

                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_internet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text("INTERNET\nCONNECTION")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                }

                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_enterprise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text("ENTERPRISE /\nSITE ID")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                }
            }
            .padding(40)
            
            Spacer()

            HStack(alignment: .top, spacing: -10) {
                Button(action: {
                    self.isTermsChecked.toggle()
                }) {
                    if self.isTermsChecked == true {
                        Image("GetStarted - Checked")
                            .frame(width: 60, height: 60)
                    }
                    else {
                        Image("GetStarted - UnChecked")
                            .frame(width: 60, height: 60)
                    }
                }
                .accessibility(identifier: "checkbox_agree_to_terms")
                .padding(.leading, 20)

                VStack {
                    HStack(spacing: 0) {
                        Text("I agree to Epicore Biosystems’ ")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)
                        
                        Button(action: {
                            self.isTermsPresent = true
                            logger.info("onBoarding", attributes: ["main": "Terms & Conditions - button pressed"])
                        }) {
                            Text("Terms & Conditions")
                                .underline()
                                .font(.custom("Roboto-Regular", size: 12))
                                .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        }
                        .accessibility(identifier: "button_terms_and_conditions")

                    }
                    .padding(.top, 20)
                    .padding(.trailing, 30)
                    .uiKitFullPresent(isPresented: $isTermsPresent, content: { closeHandler in
                        EpicoreRequiredView(epicodeLegalView: .terms)
                    })
                    
                    HStack(spacing: 0) {
                        Text(" and acknowledge that the ")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)

                        Button(action: {
                            self.isPrivacyPresent = true
                            logger.info("onBoarding", attributes: ["main": "Privacy Policy - button pressed"])
                        }) {
                            Text("Privacy Policy")
                                .underline()
                                .font(.custom("Roboto-Regular", size: 12))
                                .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        }
                        .accessibility(identifier: "button_privacy_policy")
                        .uiKitFullPresent(isPresented: $isPrivacyPresent, content: { closeHandler in
                            EpicoreRequiredView(epicodeLegalView: .privacy)
                        })

                        Text(" applies.")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)
                    }
                    .padding(.trailing, 30)
                }
                .frame(maxWidth: .infinity, alignment: .center)
           }

            Button(action: {
                if self.isTermsChecked {
                    navigate(.push(.initialSetupOnboarding))
                    logger.info("onBoarding", attributes: ["main": "GET STARTED - button pressed"])
                }
            }) {
                Text("GET STARTED")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(self.isTermsChecked ? Color(hex: chHydrationColors.waterFull) : Color.gray)
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            }
            .accessibility(identifier: "button_get_started")
            .disabled(self.isTermsChecked ? false : true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            
        }
        .trackRUMView(name: "CreateAccountGetStartedView")
        .onAppear() {
            self.isTermsPresent = false
            self.isPrivacyPresent = false
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct CreateAccountMainView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate
    
    @State private var scanErrorString = ""
    @State var showNetworkProgressView = false
    @State var qrScanCode = ""
    @State private var enterpriseId = ""
    @State private var handlingNetworkAPI = false
    @State private var isCodeScannerPresented = false
    @State private var isKeyboardVisible = false
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        
        ZStack {
            VStack {
                CreateAccountMainTitleView()

                Image("PairModule - Dots 1")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    .accessibility(identifier: "progress_dots_1")
                    .id(200)

                Text("Find your Enterprise / Site ID on the printed Onboarding Instructions sheet.")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)

                Image("GetStarted_enterprise")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 100, maxHeight: 200, alignment: .center)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                
                Button(action: {
                    self.isCodeScannerPresented = true
                }) {
                    if (languageCode == "ja") {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 350, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                    else {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 200, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    }
                }
                .trackRUMTapAction(name: "SCAN QR CODE")
                .accessibility(identifier: "scan_qr_code")
                .id(201)
                .uiKitFullPresent(isPresented: $isCodeScannerPresented, content: { closeHandler in
                    QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: true)
                        .environmentObject(modelData)
                })
                                    
                Text("or enter code manually:")
                    .id(202)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, -15)
                    .padding(.top, 10)

                TextField("", text: $enterpriseId)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.custom("Roboto-Bold", size: 24))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(width: 200, height: 60, alignment: .center)
                    .keyboardType(.alphabet)
                    .autocapitalization(.allCharacters)
                    .autocorrectionDisabled(true)
                    .submitLabel(.done)
                    .accessibility(identifier: "enterprise_id_textfield")
                    .id(203)

                if scanErrorString.isEmpty == false {
                    Text(scanErrorString)
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.red)
                        .padding(.top, 5)
                        .padding(.leading, 45)
                        .accessibility(identifier: "error_scan_enterprise_id")
                        .id(204)
                }
                
                if self.modelData.networkAPIError == true {
                    if let serverError = modelData.networkManager.enterpriseNameErr {
                        Text(serverError.message ?? "Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .onAppear() {
                                print("onAppear - self.modelData.networkAPIError")
                                showNetworkProgressView = false
                                handlingNetworkAPI = false
                            }
                            .onDisappear() {
                                print("onAppear - self.modelData.networkAPIError")
                            }
                            .accessibility(identifier: "error_server_api_enterprise_id")
                            .id(205)
                    }
                    else {
                        Text("Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .onAppear() {
                                showNetworkProgressView = false
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "unknown_error_string")
                            .id(206)
                    }
                }
                
                Spacer()

                Button(action: {
                    if isValidEnterpriseCode(enterpriseId) {
                        logger.info("EnterpriseId", attributes: ["valid" : "true", "enterpriseId" : enterpriseId])
                        modelData.networkManager.enterpriseNameErr = nil
                        modelData.onboardingEnterpriseSiteCode = enterpriseId
                        modelData.CH_EnterpriseName = ""
                        modelData.CH_SiteName = ""
                        showNetworkProgressView = true
                        handlingNetworkAPI = false
                        modelData.networkAPIError = false
                        modelData.networkManager.modelData = modelData
                        modelData.networkManager.getEnterpriseName(enterpriseId: enterpriseId)
                    }
                    else {
                        logger.info("EnterpriseId", attributes: ["valid" : "false", "enterpriseId" : enterpriseId])
                        var sendCodeServerError = ServerError()
                        sendCodeServerError.error = ""
                        sendCodeServerError.errorDescription = "Enterpise ID is wrong format."
                        modelData.networkManager.serverError = sendCodeServerError

                        modelData.networkAPIError = true
                        showNetworkProgressView = false
                        handlingNetworkAPI = true
                    }
                }) {
                    Text("SUBMIT")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(enterpriseId.isEmpty ? Color.gray : Color(hex: generalCHAppColors.onboardingVeryDarkBackground))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .trackRUMTapAction(name: "SUBMIT-enterpriseId")
                .accessibility(identifier: "submit_enterprise_id_button")
                .id(207)
                .disabled(enterpriseId.isEmpty ? true : false)
                .padding(.bottom, 40)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                modelData.networkAPIError = false
                modelData.networkManager.enterpriseNameErr = nil
                if qrScanCode.isEmpty == false {
                    logger.info("EnterpriseId", attributes: ["qrscanned" : qrScanCode])
                    print("Enterprise QR Code = " + qrScanCode)
                    enterpriseId = qrScanCode
                }
            }
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))
            
            if showNetworkProgressView == true {
                NetworkProgressView()
            }
        }
        .onAppear() {
            self.modelData.enterpriseNameAvailable = 0
            self.modelData.enterpriseSiteCodeUpdated = false
        }
        .onReceive(self.modelData.$enterpriseNameAvailable) { state in
            if state == 1 && modelData.networkManager.enterpriseNameErr == nil {
                self.showNetworkProgressView = false
                self.modelData.enterpriseNameAvailable = 0
                
                if self.modelData.enterpriseSiteCodeUpdated {
                    self.modelData.enterpriseSiteCodeUpdated = false
                }
                
                else {
                    navigate(.push(.createAccountConfirmEnterprise))
                }
            }
            else {
                self.showNetworkProgressView = false
            }
        }
//        .onTapGesture {
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        }
    }
    
    func isValidEnterpriseCode(_ code: String) -> Bool {
        let codeRegEx = "[a-zA-Z0-9]{3,4}-[a-zA-Z0-9]{3,4}"
        let codePred = NSPredicate(format:"SELF MATCHES %@", codeRegEx)
        return codePred.evaluate(with: code)
    }
}

struct CreateAccountMainTitleView: View {
    var body: some View {
        Text("ACCOUNT SETUP")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
        
        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct CreateAccountConfirmEnterprise: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var isEnterpriseEditPresent = false

    var body: some View {
        ZStack {
            VStack {
                CreateAccountMainTitleView()

                Image("PairModule - Dots 2")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    .accessibility(identifier: "progress_dot_2")
                    .id(208)

                Text("Please confirm that this is the job site at which you are based:")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)

                Spacer()

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))

                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "enterprise_name")
                    .id(209)

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.onboardingEnterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "site_name_empty")
                        .id(210)
                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "site_name_found")
                        .id(211)
                }

                Spacer()
                
                Button(action: {
                    navigate(.push(.createAccountEnterEmailAddress))
                }) {
                    Text("CONFIRM")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 200, height: 50)
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .trackRUMTapAction(name: "CONFIRM-enterpriseId")
                .accessibility(identifier: "comfirm_enterprise_id")
                .id(212)
                .padding(.bottom, 10)

                Button(action: {
                    self.isEnterpriseEditPresent.toggle()
                }) {
                    Text("Enterprise and/or Site is incorrect")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .accessibility(identifier: "button_change_enterprise_site")
                .id(213)
                .uiKitFullPresent(isPresented: $isEnterpriseEditPresent, content: { closeHandler in
                    EditEnterpriseSiteIdView(isEnterpriseEditPresent: $isEnterpriseEditPresent)
                        .environmentObject(modelData)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)

            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))
        }
        //.onTapGesture {
        //    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //}
    }
}

struct CreateAccountEnterEmailAddress: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var emailAddress = ""
    @State private var isValidEmail = true
    @State private var handlingNetworkAPI = false
    @State private var showNetworkProgressView = false

    private let signInEmailPlaceholder = "example@mycompany.com"

    var body: some View {
        ZStack {
            VStack {
                CreateAccountMainTitleView()
                
                Image("PairModule - Dots 3")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    .accessibility(identifier: "progress_dots_3")
                    .id(214)

                Text("Enterprise code confirmed.")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .padding(.top, 10)

                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "enterprise_name")
                    .id(215)

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.onboardingEnterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "onboarding_site_code")
                        .id(216)
                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "site_name")
                        .id(217)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Next, enter your email address:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Oswald-Regular", size: 16))
                        .foregroundColor(Color.white)
                    
                    TextField(signInEmailPlaceholder, text: $emailAddress)
                        .accessibility(identifier: "sign_in_email")
                        .id(218)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 50, alignment: .center)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .accessibility(identifier: "textfield_email_address")
                        .onTapGesture {
                            if emailAddress == signInEmailPlaceholder {
                                emailAddress = ""
                            }
                            isValidEmail = true
                        }
                        .submitLabel(.done)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                .padding(.trailing, 40)
                .padding(.top, 20)
                
                if isValidEmail == false && emailAddress.isEmpty == false {
                    Text("Invalid email address, please re-enter.")
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.red)
                        .padding(.top, 5)
                        .accessibility(identifier: "invalid_email_address")
                        .id(219)
                }
                
                if self.modelData.networkAPIError {
                    if let serverError = modelData.networkManager.serverError {
                        Text(serverError.error ?? "Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .onAppear() {
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "email_api_error")
                            .id(220)
                    }
                    else {
                        Text("Unknown server API issue")
                            .accessibility(identifier: "unknow_error_api")
                            .id(221)
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .onAppear() {
                                handlingNetworkAPI = false
                            }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Need to do loginContext to see if user_exists
                    if isValidEmail(emailAddress) {
                        
                        let keychain = Keychain(service: keychainAppBundleId)
                        let email = keychain["email_address"]
                        let accessToken = keychain["access_token"]
                        let refreshToken = keychain["refresh_token"]
                        let enterpriseCode = keychain["enterpriseId_siteCode"]
                        let enterpriseName = keychain["enterprise_name"]
                        let jwtEnterpriseID = keychain["jwt_enterprise_id"]
                        let jwtSiteID = keychain["jwt_site_id"]
                        let apiServer = keychain["currentApiServer"]
                        
                        let userID = keychain["user_id"]
                        let userRole = keychain["user_role"]
                        
                        modelData.networkManager.modelData = modelData
                        
                        let isTokenValid = modelData.networkManager.isTokenValid()
                        
                        if apiServer == modelData.epicoreHost && email != nil && accessToken != nil && refreshToken != nil && enterpriseCode != nil && enterpriseName != nil && jwtEnterpriseID != nil && jwtSiteID != nil && emailAddress == email && userID != nil && userRole != nil && isTokenValid
                        {
                            isValidEmail = true
                            
                            modelData.userEmailAddress = emailAddress
                            modelData.CH_EnterpriseName = enterpriseName!
                            modelData.jwtEnterpriseID = jwtEnterpriseID!
                            modelData.jwtSiteID = jwtSiteID!
                            modelData.enterpriseSiteCode = enterpriseCode!
                            
                            modelData.CH_UserID = userID!
                            modelData.CH_UserRole = userRole!
                            
                            self.modelData.networkAPIError = false
                            
                            modelData.networkManager.getNewRefreshToken()
                            
                            // Show user there account info and enterprise/site
                            navigate(.push(.createAccountUserExistsView))
                        }
                        else {
                            // Remove old keychain values
                            do {
                                try keychain.remove("access_token")
                                try keychain.remove("refresh_token")
                                try keychain.remove("email_address")
                                try keychain.remove("enterpriseId_siteCode")
                                try keychain.remove("enterprise_name")
                                try keychain.remove("jwt_enterprise_id")
                                try keychain.remove("jwt_site_id")
                                try keychain.remove("currentApiServer")
                                try keychain.remove("user_id")
                                try keychain.remove("user_role")
                            } catch let error {
                                print("keychain removal error: \(error)")
                            }
                            
                            isValidEmail = true
                            modelData.userEmailAddress = emailAddress
                            
                            modelData.networkManager.getUserLoginContext(email: emailAddress)
                            
                            self.modelData.networkAPIError = false
                            handlingNetworkAPI = true
                            showNetworkProgressView = true
                        }
                    }
                }) {
                    Text("CONTINUE")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                }
                .trackRUMTapAction(name: "CONTINUE-create-acct")
                .accessibility(identifier: "continue_create_account")
                .id(222)
                .padding(.bottom, 40)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))

            if showNetworkProgressView == true {
                NetworkProgressView()
            }
        }
        .onAppear() {
            self.modelData.networkAPIError = false
            self.modelData.userExists = 0
            self.modelData.sendCodeSuccess = 0
        }
        .onReceive(self.modelData.$userExists) { state in
            if state == 1 {
                self.modelData.userExists = 0
                modelData.networkManager.modelData = modelData
                modelData.enterpriseSiteCode = modelData.onboardingEnterpriseSiteCode
                modelData.networkManager.sendCode(email: modelData.userEmailAddress, enterpriseCode: modelData.onboardingEnterpriseSiteCode)
            }
        }
        .onReceive(self.modelData.$sendCodeSuccess) { state in
            if state == 1 {
                self.showNetworkProgressView = false
                navigate(.push(.createAccountCheckEmailView))
                handlingNetworkAPI = false
                self.modelData.networkAPIError = false
                self.modelData.sendCodeSuccess = 0
            }
        }
        //.onTapGesture {
        //    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //}
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailPred.evaluate(with: email) == false {
            isValidEmail = false
        }
        return emailPred.evaluate(with: email)
    }

}

struct CreateAccountCheckEmailView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Text("ACCOUNT SETUP")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)

                Text("Check your email inbox")
                    .font(.custom("Roboto-Medium", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                
                Text("To complete your login, we’ve sent an email containing a one-time passcode to:")
                    .font(.custom("Oswald-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                Text(modelData.userEmailAddress)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .accessibility(identifier: "users_email_address")
                    .id(223)

                Button(action: {
                    navigate(.push(.logInNavToEmailView))
                    logger.info("onBoarding", attributes: ["Login": "How do I navigate to my email?"])
                }) {
                    Text("How do I navigate to my email?")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
                .accessibility(identifier: "button_navigate_email")
                .id(224)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)

                Button(action: {
                    navigate(.push(.createAccountEnterCodeView))
                    logger.info("onBoarding", attributes: ["Login": "Enter verification code manually"])
                }) {
                    Text("Enter verification code manually")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
                .accessibility(identifier: "button_enter_verification_code")
                .id(225)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
        }
        .trackRUMView(name: "CreateAccountCheckEmailView")
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            let code = handleIncomingURL(incomingURL)
            if code.isEmpty == false {
                modelData.deepLinkCode = code
                navigate(.push(.createAccountEnterCodeView))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
    
    private func handleIncomingURL(_ url: URL) -> String {
        guard url.scheme == "rehydrate" || url.scheme == "https" else {
            return ""
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return ""
        }

        guard let action = components.host, action == "code" || action == "epicore.dev" || action == "ch.epicorebiosystems.com" else {
            print("Unknown URL, we can't handle this one!")
            return ""
        }

        var code = components.path

        if code.isEmpty {
            return ""
        }

        if code.hasPrefix("/code/") {
            code = code.replacingOccurrences(of: "/code/", with: "/")
        }
        else {
            code = components.path
        }

        if code.isEmpty {
            return ""
        }

        return String(code.dropFirst())
    }
    
}

struct CreateAccountEnterCodeView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var verificationCode = ""
    @State private var showNetworkProgressView = false
    @State private var handlingNetworkAPI = false

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        ZStack {
            VStack {
                Text("ACCOUNT SETUP")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)

                Text("Enter verification code received by email:")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                
                TextField("", text: $verificationCode)
                    .onReceive(verificationCode.publisher.collect()) {
                        self.verificationCode = String($0.prefix(8))
                    }
                    .accessibility(identifier: "textfield_verification_code")
                    .id(226)
                    .font(Font.largeTitle.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .frame(width: 200, height: 120)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)

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
                .accessibility(identifier: "button_submit")
                .id(227)
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
                    Text(languageCode == "ja" ? "" : "Call for support")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
                .accessibility(identifier: "epicore_phone")
                .id(228)
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
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))

            if showNetworkProgressView == true {
                NetworkProgressView()
            }
        }
        .trackRUMView(name: "CreateAccountEnterCodeView")
        .onAppear() {
            modelData.networkAPIError = false
            self.modelData.userAuthenticated = 0
            self.verificationCode = ""
        }
        .onReceive(self.modelData.$networkAPIError) { state in
            if state == true {
                self.handlingNetworkAPI = false
                navigate(.push(.logInVerificationFailedView))
                self.modelData.networkAPIError = false
            }
        }
        .onReceive(self.modelData.$userAuthenticated) { state in
            if state == 1 {
                self.showNetworkProgressView = false
                self.handlingNetworkAPI = false
                self.modelData.userAuthenticated = 0
                modelData.onboardingStep = 2
                navigate(.unwind(.initialSetupOnboarding))
            }
        }
        //.onTapGesture {
        //    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //}

    }
    
}

struct CreateAccountUserExistsView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var onboardingEnterpriseSelected = true
    @State private var showNetworkProgressView = false
    @State private var handlingNetworkAPI = false
    @State private var showSuccessAfterSelection = false
    @State private var showedEnterpriseSelection = false
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        if ((modelData.onboardingEnterpriseSiteCode != modelData.enterpriseSiteCode) && showSuccessAfterSelection == false) {
            VStack {
                CreateShowAccountText(showSuccessText: false)
                
                Text("Has your enterprise ID changed? Confirm where you’ll be based: ")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color("Onboarding Email Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text(modelData.onboardingEnterpriseName)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = true
                            }
                            .accessibility(identifier: "enterpise_name")
                            .id(229)

                        Text(modelData.onboardingEnterpriseSiteCode)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = true
                            }
                            .accessibility(identifier: "enterpise_onboarind_site_code")
                            .id(230)

                        Button(action: {
                            onboardingEnterpriseSelected = true
                        }) {
                            if onboardingEnterpriseSelected == true {
                                Image("GetStarted - Checked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                            }
                            else {
                                Image("GetStarted - UnChecked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                            }
                        }
                        .accessibility(identifier: "checkbox_onboarding")
                        .id(231)

                    }
                    
                    VStack(alignment: .center, spacing: 10) {
                        Text(modelData.CH_EnterpriseName)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = false
                            }
                            .accessibility(identifier: "enterpise_name")
                            .id(232)

                        Text(modelData.enterpriseSiteCode)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = false
                            }
                            .accessibility(identifier: "site_code")
                            .id(233)

                        Button(action: {
                            onboardingEnterpriseSelected = false
                        }) {
                            if onboardingEnterpriseSelected == true {
                                Image("GetStarted - UnChecked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                            }
                            else {
                                Image("GetStarted - Checked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                            }
                        }
                        .accessibility(identifier: "checkbox_onboarding")
                        .id(234)
                    }
                }
                
                Spacer()
                
                if modelData.networkAPIError {
                    if let serverError = modelData.networkManager.serverError {
                        Text(serverError.error ?? "Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.bottom, 10)
                            .onAppear() {
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "server_api_error")
                            .id(235)
                    }
                    else {
                        Text("Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.bottom, 10)
                            .onAppear() {
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "unknown_error")
                            .id(236)
                    }
                }
                
                Button(action: {
                    showedEnterpriseSelection = true
                    if onboardingEnterpriseSelected {
                        // Set to use onboarding enterprise over old values and update server
                        modelData.enterpriseSiteCode = modelData.onboardingEnterpriseSiteCode
                        modelData.CH_EnterpriseName = modelData.onboardingEnterpriseName
                        
                        let codeId = modelData.enterpriseSiteCode
                        let splitCode = codeId.split(separator: "-")
                        if splitCode.count <= 0 {
                            return
                        }
                        let enterpriseCode = String(splitCode[0])
                        let siteId = String(splitCode[1])
                        
                        let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                        modelData.networkManager.updateUser(enterpriseId: enterpriseCode, siteId: siteId, userInfo: userInfo)
                        
                        handlingNetworkAPI = true
                        showNetworkProgressView = true
                    }
                    else {
                        showSuccessAfterSelection = true
                        //navigate(.unwind(.initialSetupOnboarding))
                        //modelData.onboardingStep = 2
                    }
                }) {
                    Text("OK")
                        .font(.custom("Oswald-Regular", size: 18))
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                }
                .accessibility(identifier: "confirm_information")
                .id(237)
                .frame(width: 280, height: 50)
                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                .padding(.bottom, 40)

                if showNetworkProgressView == true {
                    NetworkUpdateUserInfoProgressView()
                }
            }
            .onAppear() {
                modelData.networkAPIError = false
                self.modelData.updatedUserSuccess = 0
            }
            .onReceive(self.modelData.$updatedUserSuccess) { state in
                if state == 1 {
                    self.showNetworkProgressView = false
                    handlingNetworkAPI = false
                    self.modelData.updatedUserSuccess = 0

                    if showedEnterpriseSelection {
                        showSuccessAfterSelection = true
                    }
                    else {
                        navigate(.unwind(.initialSetupOnboarding))
                        modelData.onboardingStep = 2
                    }
                }
                else {
                    self.showNetworkProgressView = false
                    handlingNetworkAPI = true
                }
            }
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))

        }
        else {
            VStack {
                CreateShowAccountText(showSuccessText: true)
                
                Text(modelData.userEmailAddress)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(Color("Onboarding Email Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .accessibility(identifier: "user_email_address")
                    .id(238)

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .padding(.top, 10)
                
                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "enterprise_name")
                    .id(239)

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.enterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "user_site_name")
                        .id(240)
                }
                
                Text("You can choose to skip onboarding, but we’ll still need to confirm some key information and pair your module to your phone.")
                    .font(.custom("Oswald-Regular", size: languageCode == "ja" ? 14 : 18))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                Spacer()
                
                Button(action: {
                    // Start Pair Module step 3
                    navigate(.push(.initialSetupOnboarding))
                    modelData.onboardingStep = 2
                }) {
                    Text("CONTINUE WITH ONBOARDING")
                        .font(.custom("Oswald-Regular", size: 18))
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                }
                .accessibility(identifier: "continue_onboarding")
                .id(241)
                .frame(width: 220, height: 50)
                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                Text("I’ll skip Onboarding")
                    .accessibility(identifier: "button_login")
                    .id(242)
                    .font(.custom("Roboto-Regular", size: 14))
                    .underline()
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .onTapGesture {
                        navigate(.push(.step3PairModuleMainView))
                        modelData.onboardingStep = 6
                    }
                    .padding(.bottom, 20)
            }
            .onAppear() {
                modelData.networkManager.modelData = modelData
                modelData.networkManager.GetUserInfo()
            }
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))

        }

    }
}

struct NetworkUpdateUserInfoProgressView: View {

    @State private var isRotating = 0.0

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("Progress Spinner")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .rotationEffect(.degrees(isRotating))
                    .onAppear {
                        withAnimation(.linear(duration: 1)
                            .speed(0.1).repeatForever(autoreverses: false)) {
                                isRotating = 360.0
                            }
                    }
                
                Text("Updating user data...")
                    .font(.custom("Oswald-Regular", size: 24))
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.white))
                
                Spacer()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all))
    }
}

struct CreateShowAccountText: View {
    
    @State var showSuccessText: Bool

    var body: some View {
        Text("ACCOUNT SETUP")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .padding(.top, 20)
        
        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        if showSuccessText {
            Text("You’ve successfully logged in as:")
                .font(.custom("Roboto-Bold", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 40)
                .padding(.bottom, 20)
                .padding(.leading, 20)
        }
    }
}
