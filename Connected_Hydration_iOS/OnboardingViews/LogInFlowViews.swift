//
//  LogInFlowViews.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/25.
//

import SwiftUI
import KeychainAccess
import BLEManager

struct LogInEnterEmailAddressView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var showNetworkProgressView = false
    @State private var emailAddress = ""
    @State private var isValidEmail = true
    @State private var handlingNetworkAPI = false

    let signInEmailPlaceholder = "example@mycompany.com"

    var body: some View {
        ZStack {
            GeometryReader { geo in
                VStack {
                    
                    Text("ACCOUNT LOGIN")
                        .font(.custom("Oswald-Regular", size: 20))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.white)
                        .accessibility(identifier: "text_loginenteremailaddressview_account_login")

                    Image("SignIn-Hard Hat")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                        .accessibility(identifier: "image_loginenteremailaddressview_hard_hat")

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Welcome Back!")
                            .font(.custom("Oswald-Regular", size: 20))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                            .accessibility(identifier: "text_loginenteremailaddressview_welcome")

                        Text("Enter your email address:")
                            .font(.custom("Roboto-Medium", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.white)
                            .accessibility(identifier: "text_loginenteremailaddressview_enter_email")
                        
                        TextField(signInEmailPlaceholder, text: $emailAddress)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 50, alignment: .center)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .accessibility(identifier: "textfield_loginenteremailaddressview_email")
                            .onTapGesture {
                                if emailAddress == signInEmailPlaceholder {
                                    emailAddress = ""
                                }
                            }
                            .submitLabel(.done)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, 20)

                    if self.modelData.showNoAccountFound == true {
                        Text("Email address not recognized")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .onAppear() {
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "text_loginenteremailaddressview_not_recognized")
                    }

                    if isValidEmail == false && emailAddress.isEmpty == false {
                        Text("Invalid email address, please re-enter.")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .accessibility(identifier: "text_loginenteremailaddressview_email_invalid")
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
                                .accessibility(identifier: "text_loginenteremailaddressview_unknown_1")
                        }
                        else {
                            Text("Unknown server API issue")
                                .font(.custom("Roboto-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.red)
                                .padding(.top, 5)
                                .onAppear() {
                                    handlingNetworkAPI = false
                                }
                                .accessibility(identifier: "text_loginenteremailaddressview_unknown_2")
                        }
                    }
                    
                    Spacer()

                    Button(action: {
                        if isValidEmail(emailAddress) {
#if targetEnvironment(simulator) && QA_TESTING
                            if emailAddress == "qa_user@qatest.com" {
                                navigate(.push(.logInMainView))
                                return
                            }
                            test
#endif
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
                                navigate(.push(.logInUserExistsView))
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

                                self.modelData.networkAPIError = false

                                modelData.networkManager.getUserLoginContext(email: emailAddress)
                                
                                handlingNetworkAPI = true
                                showNetworkProgressView = true
                            }
                        }
                    }) {
                        if self.modelData.showNoAccountFound == true {
                            Text("TRY AGAIN")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 180, height: 50)
                                .foregroundColor(emailAddress.isEmpty ? Color.gray : Color(hex: generalCHAppColors.onboardingVeryDarkBackground))
                                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                                .accessibility(identifier: "text_loginenteremailaddressview_button_tryagain")
                        }
                        else {
                            Text("CONTINUE")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 180, height: 50)
                                .foregroundColor(emailAddress.isEmpty ? Color.gray : Color(hex: chHydrationColors.waterFull))
                                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                                .accessibility(identifier: "text_loginenteremailaddressview_button_continue")
                        }
                    }
                    .trackRUMTapAction(name: "continue_email_address")
                    .disabled(emailAddress.isEmpty ? true : false)
                    .padding(.bottom, 40)
                    .accessibility(identifier: "button_loginenteremailaddressview_continue")

                    if self.modelData.showNoAccountFound == true {
                        VStack {
                            Text("Create a New Account")
                                .accessibility(identifier: "button_login")
                                .font(.custom("Roboto-Regular", size: 14))
                                .foregroundColor(.white)
                                .underline()
                                .onTapGesture {
                                    modelData.onboardingStep = 1
                                    self.modelData.showNoAccountFound = false
                                    navigate(.unwind(.clearNavPath))
                                }
                                .accessibility(identifier: "text_loginenteremailaddressview_create")

                            Text("(Requires Onboarding)")
                                .accessibility(identifier: "button_login")
                                .font(.custom("Roboto-Regular", size: 14))
                                .foregroundColor(.white)
                                .onTapGesture {
                                    modelData.onboardingStep = 1
                                    self.modelData.showNoAccountFound = false
                                    navigate(.unwind(.clearNavPath))
                                }
                                .accessibility(identifier: "button_loginenteremailaddressview_requires")
                        }
                    }
                    
                }
                .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                    .edgesIgnoringSafeArea(.all))
            }

            if showNetworkProgressView == true {
                NetworkProgressView()
            }
        }
        .onAppear() {
            self.modelData.userExists = 0
        }
        .trackRUMView(name: "LogInEnterEmailAddressView")
        .onReceive(self.modelData.$userExists) { state in
            if state == 1 && modelData.userStatusString == "exists" {
                self.showNetworkProgressView = false
                navigate(.push(.logInMainView))
                handlingNetworkAPI = false
                self.modelData.userExists = 0
            }
            else {
                self.showNetworkProgressView = false
                handlingNetworkAPI = false
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

struct LogInCheckEmailView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    var body: some View {
        GeometryReader { geo in
            VStack {
                
                Text("ACCOUNT LOGIN")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .accessibility(identifier: "text_logincheckemailview_account_login")

                if modelData.userExists == 1 {
                    Text("You already have an account.")
                        .font(.custom("Roboto-Medium", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        .accessibility(identifier: "text_logincheckemailview_account_already")
                }
                else{
                    Text("Check your email inbox")
                        .font(.custom("Roboto-Medium", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        .accessibility(identifier: "text_logincheckemailview_account_check_inbox")
                }
                
                Text("To complete your login, we’ve sent an email containing a one-time passcode to:")
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_logincheckemailview_complete_login")

                Text(modelData.userEmailAddress)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_logincheckemailview_user_email")

                Button(action: {
                    navigate(.push(.logInNavToEmailView))
                    logger.info("onBoarding", attributes: ["Login": "How do I navigate to my email?"])
                }) {
                    Text("How do I navigate to my email?")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .accessibility(identifier: "text_logincheckemailview_how_navigate")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibility(identifier: "button_logincheckemailview_how_navigate")

                Button(action: {
                    navigate(.push(.logInEnterCodeView))
                    logger.info("onBoarding", attributes: ["Login": "Enter verification code manually"])
                }) {
                    Text("Enter verification code manually")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .accessibility(identifier: "text_logincheckemailview_enter_code")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_logincheckemailview_enter_code")

                Spacer()
            }
        }
        .trackRUMView(name: "LogInCheckEmailView")
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            let code = handleIncomingURL(incomingURL)
            if code.isEmpty == false {
                modelData.deepLinkCode = code
                navigate(.push(.logInEnterCodeView))
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

struct LogInEnterCodeView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var verificationCode = ""

    @State private var showNetworkProgressView = false
    @State private var handlingNetworkAPI = false

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        ZStack {
            VStack {
                Text("ACCOUNT LOGIN")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .accessibility(identifier: "text_loginentercodeview_account_login")

                Text("Enter verification code received by email:")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_loginentercodeview_enter_code")

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
                    .submitLabel(.done)
                    .accessibility(identifier: "textfield_loginentercodeview_code")

                Button(action: {
#if targetEnvironment(simulator) && QA_TESTING
                    if verificationCode == "1234" {
                        modelData.networkManager.modelData = modelData
                        navigate(.push(.logInAccountCreatedView))
                    }
#else
                    modelData.networkManager.modelData = modelData
                    modelData.networkManager.AuthenticateWithCode(email: modelData.userEmailAddress, verificationCode: verificationCode)
                    
                    handlingNetworkAPI = true
                    showNetworkProgressView = true
#endif
                }) {
                    Text("SUBMIT")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        .accessibility(identifier: "text_loginentercodeview_button_submit")
                }
                .padding(.bottom, 20)
                .accessibility(identifier: "button_loginentercodeview_button_submit")

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
                        .accessibility(identifier: "text_loginentercodeview_button_call")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_loginentercodeview_call")

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
        .trackRUMView(name: "LogInEnterCodeView")
        .onAppear() {
            self.modelData.networkSendCodeAPIError = 0
            self.modelData.userAuthenticated = 0
            modelData.networkAPIError = false
            self.verificationCode = ""
        }
        .onReceive(self.modelData.$networkSendCodeAPIError) { state in
            if state == 1 {
                self.handlingNetworkAPI = false
                self.modelData.networkSendCodeAPIError = 0
                navigate(.push(.logInVerificationFailedView))
            }
        }
        .onReceive(self.modelData.$userAuthenticated) { state in
            if state == 1 {
                self.showNetworkProgressView = false
                self.handlingNetworkAPI = false
                self.modelData.userAuthenticated = 0
                navigate(.push(.logInAccountCreatedView))
            }
        }
        //.onTapGesture {
        //    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //}

    }
    
}

struct LogInNavToEmailView: View {

    @EnvironmentObject var modelData: ModelData
    
    @State private var isTroubleshootingPresent = false

    var body: some View {
        VStack {
            Text("ACCOUNT LOGIN")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_loginnavtoemailview_account_login")

            Text("If you use the **iPhone Mail App** on this phone, you can tap the button below:")
                .font(.custom("Roboto-Regular", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginnavtoemailview_mail_info")

            Button(action: {
                let mailURL = URL(string: "message://")!
                if UIApplication.shared.canOpenURL(mailURL) {
                    UIApplication.shared.open(mailURL)
                }
            }) {
                HStack {
                    Image("SignUp - Mail Icon")
                        .accessibility(identifier: "image_loginnavtoemailview_icon")
                    Text("Take me to iPhone’s Mail App")
                        .font(.custom("Oswald-Regular", size: 18))
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .accessibility(identifier: "text_loginnavtoemailview_takeme")
                }
            }
            .frame(width: 280, height: 50)
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .accessibility(identifier: "button_loginnavtoemailview_mail_signup")

            LogInNavToEmailInstructionsView()

            Spacer()
            
            Button(action: {
                self.isTroubleshootingPresent = true
            }) {
                Text("More Troubleshooting Steps")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .accessibility(identifier: "text_loginnavtoemailview_trouble")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            .accessibility(identifier: "button_loginnavtoemailview_trouble")

        }
        .trackRUMView(name: "LogInNavToEmailView")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
             isPresented: $isTroubleshootingPresent) {
                 LogInTroubleshootingEmailView().navigationBarBackButtonHidden(true)
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct LogInNavToEmailInstructionsView: View {
    var body: some View {
        Text("If you check your email another way:")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginnavtoemailinstructionsview_check_email")

        Text("1. Switch to the app you use to check email")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginnavtoemailinstructionsview_step_1")

        Text("2. Look for an email from Epicore Biosystems")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginnavtoemailinstructionsview_step_2")

        Text("3. Follow instructions in the email")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginnavtoemailinstructionsview_step_3")
    }
}

struct LogInVerificationFailedView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            LogInTopVerificationFailedAccount()
            
            Text("Carefully check the verification code from the email you received and try again:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .padding(.top, 20)
                .accessibility(identifier: "text_loginverificationfailedview_check")

            Button(action: {
                self.modelData.networkSendCodeAPIError = 0
                navigate(.unwind(.logInEnterCodeView))
            }) {
                Text("ENTER CODE MANUALLY")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .accessibility(identifier: "text_loginverificationfailedview_enter_code")
            }
            .frame(width: 280, height: 50)
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.bottom, 40)
            .accessibility(identifier: "button_loginverificationfailedview_enter_code")

            Text("Request a new email, containing a new verification link / code:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibility(identifier: "text_loginverificationfailedview_request")

            Button(action: {
                self.modelData.networkSendCodeAPIError = 0
                modelData.networkManager.modelData = modelData
                modelData.networkManager.sendCode(email: modelData.userEmailAddress, enterpriseCode: modelData.enterpriseSiteCode)
            }) {
                Text("RESEND EMAIL")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .accessibility(identifier: "text_loginverificationfailedview_resend")
            }
            .frame(width: 280, height: 50)
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.bottom, 20)
            .accessibility(identifier: "button_loginverificationfailedview_resend")

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
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_loginverificationfailedview_call")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            .accessibility(identifier: "button_loginverificationfailedview_call")

        }
        .trackRUMView(name: "LogInNavToEmailInstructionsView")
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct LogInTopVerificationFailedAccount: View {
    var body: some View {
        Text("ACCOUNT LOGIN")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .accessibility(identifier: "text_loginTopverificationfailedaccount_account_login")

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        Text("Verification did not succeed.")
            .font(.custom("Roboto-Bold", size: 20))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 40)
            .padding(.bottom, 20)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginTopverificationfailedaccount_failed")

    }
}

struct LogInAccountCreatedView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var isEnterpriseEditPresent = false

    var body: some View {
        VStack {

            LogInCreateAccountText()

            Text(modelData.userEmailAddress)
                .font(.custom("Roboto-Regular", size: 20))
                .foregroundColor(Color("Onboarding Email Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginaccountcreatedview_emailaddress")

            Text("Next, we’ll confirm key information and have you pair your module to your phone.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginaccountcreatedview_next")

            Text("Please confirm that your site information is still current:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginaccountcreatedview_please")

            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: chHydrationColors.waterFull))
                .padding(.top, 10)
                .accessibility(identifier: "image_loginaccountcreatedview_mappin")

            Text(modelData.CH_EnterpriseName)
                .font(.custom("Oswald-Regular", size: 32))
                .foregroundColor(Color(hex: chHydrationColors.waterFull))
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "text_loginaccountcreatedview_enterprise_name")

            if modelData.CH_SiteName.isEmpty {
                Text(modelData.enterpriseSiteCode)
                    .font(.custom("Oswald-Regular", size: 28))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_loginaccountcreatedview_site_name_empty")
            }
            else {
                Text(modelData.CH_SiteName)
                    .font(.custom("Oswald-Regular", size: 28))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_loginaccountcreatedview_site_name")
            }

            Spacer()

            Button(action: {
                navigate(.push(.logInPhysioloyInfoView))
            }) {
                Text("THIS IS CORRECT")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .accessibility(identifier: "text_loginaccountcreatedview_correct")
            }
            .frame(width: 280, height: 50)
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.bottom, 20)
            .accessibility(identifier: "button_loginaccountcreatedview_correct")

            Button(action: {
                self.isEnterpriseEditPresent.toggle()
            }) {
                Text("Change my Enterprise / Site")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_loginaccountcreatedview_change")
            }
            .uiKitFullPresent(isPresented: $isEnterpriseEditPresent, content: { closeHandler in
                EditEnterpriseSiteIdView(isEnterpriseEditPresent: $isEnterpriseEditPresent)
                    .environmentObject(modelData)
            })
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 60)
            .accessibility(identifier: "button_loginaccountcreatedview_change")

            Spacer()
            
        }
        .trackRUMView(name: "LogInAccountCreatedView")
        .onAppear() {
            if self.modelData.downloadUserPhysiology {
                modelData.networkManager.GetUserInfo()
            }
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct LogInCreateAccountText: View {
    var body: some View {
        Text("ACCOUNT LOGIN")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .padding(.bottom, 40)
            .accessibility(identifier: "text_logincreateaccounttext_accountlogin")

        Text("You’ve successfully logged in as:")
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logincreateaccounttext_success")

    }
}

struct LogInTroubleshootingEmailView: View {

    @EnvironmentObject var modelData: ModelData
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            Text("TROUBLESHOOTING STEPS")
                .font(.custom("Oswald-Regular", size: 20))
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_logintroubleshootingemailview_troubleshooting")

            LogInTroubleshootingInstructionsView()

            Spacer()

            Button(action: {
                modelData.networkManager.modelData = modelData
                modelData.networkManager.sendCode(email: modelData.userEmailAddress, enterpriseCode: modelData.enterpriseSiteCode)
            }) {
                Text("RESEND EMAIL")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 180, height: 50)
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                    .accessibility(identifier: "text_logintroubleshootingemailview_resend")
            }
            .padding(.bottom, 20)
            .accessibility(identifier: "button_logintroubleshootingemailview_resend")

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
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .accessibility(identifier: "text_logintroubleshootingemailview_call")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            .accessibility(identifier: "button_logintroubleshootingemailview_call")

        }
        .trackRUMView(name: "LogInTroubleshootingEmailView")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct LogInTroubleshootingInstructionsView: View {

    @EnvironmentObject var modelData: ModelData

    var body: some View {
        Text("Email Not Received:")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_not_received")

        Text("• It may take 5 minutes for email to arrive")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_1")

        Text("• Check Spam or Junk folders")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_2")

        Text("• Ensure you’re checking inbox for ")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_3")

        Text(modelData.userEmailAddress)
            .font(.custom("Roboto-Bold", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 30)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_emailaddress")

        Text("• Check network connection")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_4")

        Text("• Request a new email (below)")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_5")

        Text("Link / Verification Code Not Working:")
            .font(.custom("Roboto-Regular", size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_link")

        Text("• Link / verification code may have expired. Request a new email (below)")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_link_1")

        Text("• If manually entered: double-check verification code for typos")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .accessibility(identifier: "text_logintroubleshootinginstructionsView_link_2")

    }
}

struct LogInPhysioloyInfoView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State var isPhysiologyPresent = true
    @State var showNetworkProgressView = false
    @State var currentWeightValue = ""
    
    @State private var showPhysiologyConfirmAlert = false

    @State private var oldUserHeightFeet = ""
    @State private var oldUserHeightInch = ""
    @State private var oldUserHeightCm = ""
    @State private var oldUserWeight = ""
    @State private var oldUserGender = ""

    var body: some View {
        ZStack {
            VStack {
                Text("ACCOUNT LOGIN")
                    .font(.custom("Oswald-Regular", size: 20))
                    .foregroundColor(Color.white)
                    .padding(.top, 20)
                    .accessibility(identifier: "text_loginphysioloyinfoview_account_login")

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
                    .accessibility(identifier: "text_loginphysioloyinfoview_shared")

                Text("Please comfirm that the information is correct:")
                    .font(.custom("Roboto-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .accessibility(identifier: "text_loginphysioloyinfoview_correct")

                if self.modelData.networkSendCodeAPIError == 1 {
                    Text("Unable to update user data on server.")
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.red)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .onAppear() {
                            self.modelData.networkSendCodeAPIError = 0
                            showNetworkProgressView = false
                        }
                        .accessibility(identifier: "text_loginphysioloyinfoview_server")

                }
                else {
                    Text("")
                        .onAppear() {
                            showNetworkProgressView = false

                            oldUserHeightFeet = modelData.userPrefsData.getUserHeightInFt()
                            oldUserHeightInch = modelData.userPrefsData.getUserHeightIn()
                            oldUserHeightCm = modelData.userPrefsData.getUserHeightCm()
                            oldUserWeight = modelData.userPrefsData.getUserWeight()
                            //print("oldUserWeight = \(oldUserWeight)")
                            oldUserGender = modelData.userPrefsData.getUserGender()
                        }
                }
                
                PhysiologyInformationView(showHeader: false, isEditing: true, showOKCancelOption: false, isPhysiologyShowing: $isPhysiologyPresent, currentWeightValue: $currentWeightValue)
                    .environmentObject(modelData)
                
                Spacer()
                
                Button(action: {
                    if oldUserHeightFeet != modelData.userPrefsData.getUserHeightInFt() || oldUserHeightInch != modelData.userPrefsData.getUserHeightIn() ||  oldUserWeight != currentWeightValue || oldUserGender != modelData.userPrefsData.getUserGender() || oldUserHeightCm != modelData.userPrefsData.getUserHeightCm() {
                        modelData.userPrefsData.setUserWeight(weight: currentWeightValue)
                        showPhysiologyConfirmAlert = true
                    }
                    else {
                        if (modelData.onboardingStep == 8) {
                            modelData.isOnboardingComplete = true
                            navigate(.unwind(.clearNavPath))
                        }
                        else {
                            navigate(.push(.step3PairModuleMainView))
                            modelData.onboardingStep = 7
                            modelData.sensorNavigation = true
                            guard BLEManager.bleSingleton.peripheralToConnect != nil else {
                                return
                            }

                            // Force disconnect from sensor to re-pair. Reset the pairCHDeviceSN to empty to prevent the automatic connection after disconnection.
                            self.modelData.pairCHDeviceSN = ""
                            self.modelData.ebsMonitor.forceDisconnectFromPeripheral()
                        }
                    }

                }) {
                    Text("CONTINUE")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        .accessibility(identifier: "text_loginphysioloyinfoview_continue")
                }
                .padding(.bottom, 40)
                .alert(isPresented: $showPhysiologyConfirmAlert) {
                    Alert(
                        title: Text("Confirm"),
                        message: Text("Are you sure you want to update your physiology information?"),
                        primaryButton: .destructive(Text("Cancel"), action: {
                            modelData.userPrefsData.setUserHeightFeet(feet: oldUserHeightFeet)
                            modelData.userPrefsData.setUserHeightInch(inches: oldUserHeightInch)
                            modelData.userPrefsData.setUserHeightCm(cm: UInt8(oldUserHeightCm) ?? 125)
                            modelData.userPrefsData.setUserWeight(weight: oldUserWeight)
                            modelData.userPrefsData.setUserGender(gender: oldUserGender)

                            if modelData.onboardingStep == 8 {
                                modelData.isOnboardingComplete = true
                                navigate(.unwind(.clearNavPath))
                            }
                            else {
                                navigate(.push(.step3PairModuleMainView))
                                modelData.onboardingStep = 7
                                modelData.sensorNavigation = true
                            }
                        }),
                        secondaryButton: .default(Text("OK"), action: {
                            updateDevice()

                            let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                            modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                            if modelData.onboardingStep == 8 {
                                modelData.isOnboardingComplete = true
                                navigate(.unwind(.clearNavPath))
                            }
                            else {
                                navigate(.push(.step3PairModuleMainView))
                                modelData.onboardingStep = 7
                                modelData.sensorNavigation = true
                            }
                        })
                    )
                }
                .accessibility(identifier: "button_loginphysioloyinfoview_continue")

                if showNetworkProgressView == true {
                    NetworkGetUserInfoProgressView()
                }
                
            }   // VStack
        }   // ZStack
        .trackRUMView(name: "LogInPhysioloyInfoView")
        .onAppear() {
            self.modelData.networkSendCodeAPIError = 0
            showNetworkProgressView = true
            modelData.networkManager.GetUserInfo()
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
    
    func updateDevice() {
        // Check sensor connected
        guard BLEManager.bleSingleton.sensorConnected == true else { return }
        guard BLEManager.bleSingleton.peripheralToConnect != nil else { return }

        if modelData.unitsChanged == "0" {
            modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
        }
        
        else {
            modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
        }
    }
    
}

struct LogInUserExistsView: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var isEnterpriseEditPresent = false
    @State private var onboardingEnterpriseSelected = false
    @State private var serverEnterpriseSelected = false

    var body: some View {
        VStack {

            LogInShowAccountText()
            
            Text(modelData.userEmailAddress)
                .font(.custom("Roboto-Regular", size: 20))
                .foregroundColor(Color("Onboarding Email Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginuserexistsview_emailaddress")

            Text("Next, we’ll confirm key information and have you pair your module to your phone.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginuserexistsview_pair")

            Text("Please confirm that your site information is still current:")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.leading, 20)
                .accessibility(identifier: "text_loginuserexistsview_confirm")

            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: chHydrationColors.waterFull))
                .padding(.top, 10)
                .accessibility(identifier: "image_loginuserexistsview_mappin")

            Text(modelData.CH_EnterpriseName)
                .font(.custom("Oswald-Regular", size: 32))
                .foregroundColor(Color(hex: chHydrationColors.waterFull))
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "text_loginuserexistsview_enterprisename")

            if modelData.CH_SiteName.isEmpty {
                Text(modelData.jwtEnterpriseID + "-" + modelData.jwtSiteID)
                    .font(.custom("Oswald-Regular", size: 28))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_loginuserexistsview_jwt_info")
            }
            else {
                Text(modelData.CH_SiteName)
                    .font(.custom("Oswald-Regular", size: 28))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_loginuserexistsview_sitename")
            }

            Button(action: {
                self.isEnterpriseEditPresent.toggle()
            }) {
                Text("Change")
                    .underline()
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_loginuserexistsview_change")
            }
            .uiKitFullPresent(isPresented: $isEnterpriseEditPresent, content: { closeHandler in
                EditEnterpriseSiteIdView(isEnterpriseEditPresent: $isEnterpriseEditPresent)
                    .environmentObject(modelData)
            })
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            .accessibility(identifier: "button_loginuserexistsview_change")

            Spacer()
            
            Button(action: {
                navigate(.push(.step3PairModuleMainView))
                modelData.onboardingStep = 8
            }) {
                Text("THIS IS CORRECT")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                    .accessibility(identifier: "text_loginuserexistsview_correct")
            }
            .frame(width: 280, height: 50)
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.bottom, 60)
            .accessibility(identifier: "button_loginuserexistsview_correct")

        }
        .onAppear() {
            modelData.networkManager.GetUserInfo()
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))
    }
}

struct LogInShowAccountText: View {
    var body: some View {
        Text("ACCOUNT LOGIN")
            .font(.custom("Oswald-Regular", size: 20))
            .foregroundColor(Color.white)
            .padding(.top, 20)
            .accessibility(identifier: "text_loginshowaccounttext_account_login")

        Rectangle()
            .fill(Color(hex: generalCHAppColors.onboardingLtGrayColor))
            .frame(height: 1.0)
            .edgesIgnoringSafeArea(.horizontal)

        Text("You’ve successfully logged in as:")
            .font(.custom("Roboto-Bold", size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 40)
            .padding(.bottom, 20)
            .padding(.leading, 20)
            .accessibility(identifier: "text_loginshowaccounttext_success")

    }
}

struct LogInMainView: View {
    
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

                Text("Find your Enterprise / Site ID on the printed Onboarding Instructions sheet.")
                    .multilineTextAlignment(.center)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .accessibility(identifier: "text_loginmainview_find")

                Image("GetStarted_enterprise")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 100, maxHeight: 200, alignment: .center)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .accessibility(identifier: "image_loginmainview_started")

                Button(action: {
                    self.isCodeScannerPresented = true
                }) {
                    if (languageCode == "ja") {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 350, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "text_loginmainview_qrcode_ja")

                    }
                    else {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 200, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "text_loginmainview_qrcode")

                    }
                }
                .trackRUMTapAction(name: "SCAN QR CODE")
                .accessibility(identifier: "button_loginmainview_qrcode")
                .uiKitFullPresent(isPresented: $isCodeScannerPresented, content: { closeHandler in
                    QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: true)
                        .environmentObject(modelData)
                })
                                    
                Text("or enter code manually:")
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, -15)
                    .padding(.top, 10)
                    .accessibility(identifier: "text_loginmainview_enter_manually")

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
                    .accessibility(identifier: "textfield_loginmainview_enterprise")

                if scanErrorString.isEmpty == false {
                    Text(scanErrorString)
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.red)
                        .padding(.top, 5)
                        .padding(.leading, 45)
                }
                
                if self.modelData.networkAPIError == true {
                    if let serverError = modelData.networkManager.serverError {
                        Text(serverError.errorDescription ?? "Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .padding(.leading, 45)
                            .onAppear() {
                                print("onAppear - self.modelData.networkAPIError")
                                showNetworkProgressView = false
                                handlingNetworkAPI = false
                            }
                            .onDisappear() {
                                print("onAppear - self.modelData.networkAPIError")
                            }
                            .accessibility(identifier: "text_loginmainview_error")

                    }
                    else {
                        Text("Unknown server API issue")
                            .font(.custom("Roboto-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.red)
                            .padding(.top, 5)
                            .padding(.leading, 45)
                            .onAppear() {
                                showNetworkProgressView = false
                                handlingNetworkAPI = false
                            }
                            .accessibility(identifier: "text_loginmainview_unknown")

                    }
                }
                
                Spacer()
                
                Button(action: {
                    if isValidEnterpriseCode(enterpriseId) {
#if targetEnvironment(simulator) && QA_TESTING
                        modelData.networkManager.modelData = modelData
                        navigate(.push(.logInCheckEmailView))
                        return
#else
                        logger.info("EnterpriseId", attributes: ["valid" : "true", "enterpriseId" : enterpriseId])
                        self.showNetworkProgressView = true
                        modelData.enterpriseSiteCode = enterpriseId
                        modelData.networkManager.modelData = modelData
                        modelData.networkManager.sendCode(email: modelData.userEmailAddress, enterpriseCode: modelData.enterpriseSiteCode)
                        self.modelData.userExists = 0
#endif
                    }
                    else {
                        logger.info("EnterpriseId", attributes: ["valid" : "false", "enterpriseId" : enterpriseId])
                        var sendCodeServerError = ServerError()
                        sendCodeServerError.error = ""
                        sendCodeServerError.errorDescription = "Enterpise ID is wrong format."
                        self.modelData.networkManager.serverError = sendCodeServerError

                        self.modelData.networkAPIError = true
                        showNetworkProgressView = false
                        handlingNetworkAPI = true
                    }
                }) {
                    Text("SUBMIT")
                        .font(.custom("Oswald-Regular", size: 18))
                        .frame(width: 180, height: 50)
                        .foregroundColor(enterpriseId.isEmpty ? Color.gray : Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                        .accessibility(identifier: "text_loginmainview_submit")

                }
                .trackRUMTapAction(name: "SUBMIT-enterpriseId")
                .disabled(enterpriseId.isEmpty ? true : false)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_loginmainview_submit")

            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
                .edgesIgnoringSafeArea(.all))
            .onAppear() {
                if qrScanCode.isEmpty == false {
                    logger.info("EnterpriseId", attributes: ["qrscanned" : qrScanCode])
                    print("Enterprise QR Code = " + qrScanCode)
                    enterpriseId = qrScanCode
                }
            }

            if showNetworkProgressView == true {
                NetworkProgressView()
            }
        }
        .onAppear() {
            self.modelData.sendCodeSuccess = 0
        }
        .onReceive(self.modelData.$sendCodeSuccess) { state in
            if state == 1 {
                self.showNetworkProgressView = false
                navigate(.push(.logInCheckEmailView))
                handlingNetworkAPI = false
                self.modelData.sendCodeSuccess = 0
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
