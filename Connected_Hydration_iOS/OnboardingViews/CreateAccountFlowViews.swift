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
                .accessibility(identifier: "text_createaccountgetstartedview_welcome")

            Text("To get started, gather the Connected Hydration materials that you received.")
                .font(.custom("Oswald-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_createaccountgetstartedview_started")

            Text("You’ll also need:")
                .font(.custom("Oswald-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 30)
                .foregroundColor(Color.white)
                .accessibility(identifier: "text_createaccountgetstartedview_need")

            HStack(spacing: 5){
                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_phoneicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .accessibility(identifier: "image_createaccountgetstartedview_phone")

                    Text("SMART\nPHONE")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                        .accessibility(identifier: "text_createaccountgetstartedview_smart")

                }

                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_internet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .accessibility(identifier: "image_createaccountgetstartedview_internet")

                    Text("INTERNET\nCONNECTION")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                        .accessibility(identifier: "text_createaccountgetstartedview_internet")

                }

                VStack(alignment: .center, spacing: 10) {
                    Image("GetStarted_enterprise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .accessibility(identifier: "image_createaccountgetstartedview_enterprise")

                    Text("ENTERPRISE /\nSITE ID")
                        .font(.custom("Roboto-Regular", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: generalCHAppColors.regularGrayStandardBackground))
                        .accessibility(identifier: "text_createaccountgetstartedview_enterprise")

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
                            .accessibility(identifier: "image_createaccountgetstartedview_checked")

                    }
                    else {
                        Image("GetStarted - UnChecked")
                            .frame(width: 60, height: 60)
                            .accessibility(identifier: "image_createaccountgetstartedview_uncheck")

                    }
                }
                .padding(.leading, 20)

                VStack {
                    HStack(spacing: 0) {
                        Text("I agree to Epicore Biosystems’ ")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)
                            .accessibility(identifier: "text_createaccountgetstartedview_agree")

                        Button(action: {
                            self.isTermsPresent = true
                            logger.info("onBoarding", attributes: ["main": "Terms & Conditions - button pressed"])
                        }) {
                            Text("Terms & Conditions")
                                .underline()
                                .font(.custom("Roboto-Regular", size: 12))
                                .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                                .accessibility(identifier: "text_createaccountgetstartedview_terms")

                        }

                    }
                    .padding(.top, 20)
                    .padding(.trailing, 30)
                    .uiKitFullPresent(isPresented: $isTermsPresent, content: { closeHandler in
                        EpicoreRequiredView(epicodeLegalView: .terms)
                    })
                    .accessibility(identifier: "button_createaccountgetstartedview_terms")

                    HStack(spacing: 0) {
                        Text(" and acknowledge that the ")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)
                            .accessibility(identifier: "text_createaccountgetstartedview_ack")

                        Button(action: {
                            self.isPrivacyPresent = true
                            logger.info("onBoarding", attributes: ["main": "Privacy Policy - button pressed"])
                        }) {
                            Text("Privacy Policy")
                                .underline()
                                .font(.custom("Roboto-Regular", size: 12))
                                .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                                .accessibility(identifier: "text_createaccountgetstartedview_privacy")

                        }
                        .uiKitFullPresent(isPresented: $isPrivacyPresent, content: { closeHandler in
                            EpicoreRequiredView(epicodeLegalView: .privacy)
                        })
                        .accessibility(identifier: "button_createaccountgetstartedview_privacy")

                        Text(" applies.")
                            .font(.custom("Roboto-Regular", size: 12))
                            .foregroundColor(Color.white)
                            .accessibility(identifier: "text_createaccountgetstartedview_applies")

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
                    .accessibility(identifier: "text_createaccountgetstartedview_started")

            }
            .disabled(self.isTermsChecked ? false : true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
            .accessibility(identifier: "button_createaccountgetstartedview_started")

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
                    .accessibility(identifier: "image_createaccountmainview_progress_1")

                Text("Find your Enterprise / Site ID on the printed Onboarding Instructions sheet.")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_createaccountmainview_find")

                Image("GetStarted_enterprise")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 100, maxHeight: 200, alignment: .center)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .accessibility(identifier: "image_createaccountmainview_getstarted")

                Button(action: {
                    self.isCodeScannerPresented = true
                }) {
                    if (languageCode == "ja") {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 350, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "text_createaccountmainview_qrcode_ja")

                    }
                    else {
                        Text("SCAN QR CODE \(Image(systemName: "qrcode.viewfinder"))")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 200, height: 40)
                            .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                            .accessibility(identifier: "text_createaccountmainview_qrcode")

                    }
                }
                .trackRUMTapAction(name: "SCAN QR CODE")
                .uiKitFullPresent(isPresented: $isCodeScannerPresented, content: { closeHandler in
                    QRCodeScannerView(isCodeScannerPresented: $isCodeScannerPresented, qrScanCode: $qrScanCode, scanErrorString: $scanErrorString, isEnterpriseIdScan: true)
                        .environmentObject(modelData)
                })
                .accessibility(identifier: "button_createaccountmainview_qrcode")

                Text("or enter code manually:")
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, -15)
                    .padding(.top, 10)
                    .accessibility(identifier: "text_createaccountmainview_enter_manually")

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
                    .accessibility(identifier: "textfield_createaccountmainview_enterprise")

                if scanErrorString.isEmpty == false {
                    Text(scanErrorString)
                        .font(.custom("Roboto-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.red)
                        .padding(.top, 5)
                        .padding(.leading, 45)
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
                            .accessibility(identifier: "text_createaccountmainview_servererror")

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
                            .accessibility(identifier: "text_createaccountmainview_unknown")

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
                        .accessibility(identifier: "text_createaccountmainview_submit")

                }
                .trackRUMTapAction(name: "SUBMIT-enterpriseId")
                .disabled(enterpriseId.isEmpty ? true : false)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_createaccountmainview_submit")

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
            .accessibility(identifier: "text_createaccountmaintitleview_accountsetup")

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
                    .accessibility(identifier: "image_createaccountconfirmenterprise_progress_2")

                Text("Please confirm that this is the job site at which you are based:")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_createaccountconfirmenterprise_confirm")

                Spacer()

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .accessibility(identifier: "image_createaccountconfirmenterprise_mappin")

                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_createaccountconfirmenterprise_enterprisename")

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.onboardingEnterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountconfirmenterprise_enterprisesite")

                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountconfirmenterprise_sitename")

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
                        .accessibility(identifier: "text_createaccountconfirmenterprise_confirm")
                }
                .trackRUMTapAction(name: "CONFIRM-enterpriseId")
                .padding(.bottom, 10)
                .accessibility(identifier: "button_createaccountconfirmenterprise_confirm")

                Button(action: {
                    self.isEnterpriseEditPresent.toggle()
                }) {
                    Text("Enterprise and/or Site is incorrect")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 14))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountconfirmenterprise_incorrect")

                }
                .uiKitFullPresent(isPresented: $isEnterpriseEditPresent, content: { closeHandler in
                    EditEnterpriseSiteIdView(isEnterpriseEditPresent: $isEnterpriseEditPresent)
                        .environmentObject(modelData)
                })
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_createaccountconfirmenterprise_incorrect")

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
                    .accessibility(identifier: "image_createaccountenteremailaddress_progress_3")

                Text("Enterprise code confirmed.")
                    .font(.custom("Oswald-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .accessibility(identifier: "text_createaccountenteremailaddress_confirm")

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .padding(.top, 10)
                    .accessibility(identifier: "image_createaccountenteremailaddress_mappin")

                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_createaccountenteremailaddress_enterprisename")

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.onboardingEnterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountenteremailaddress_sitecode")

                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountenteremailaddress_sitename")

                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Next, enter your email address:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Oswald-Regular", size: 16))
                        .foregroundColor(Color.white)
                        .accessibility(identifier: "text_createaccountenteremailaddress_enter")

                    TextField(signInEmailPlaceholder, text: $emailAddress)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 50, alignment: .center)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .onTapGesture {
                            if emailAddress == signInEmailPlaceholder {
                                emailAddress = ""
                            }
                            isValidEmail = true
                        }
                        .submitLabel(.done)
                        .accessibility(identifier: "textfield_createaccountenteremailaddress_emailaddress")

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
                            .accessibility(identifier: "text_createaccountenteremailaddress_servererror")

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
                            .accessibility(identifier: "text_createaccountenteremailaddress_unknown")

                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Need to do loginContext to see if user_exists
                    if isValidEmail(emailAddress) {
#if targetEnvironment(simulator) && QA_TESTING
                    if emailAddress == "qa_user@qatest.com" {
                        navigate(.push(.createAccountCheckEmailView))
                        return
                    }
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
                        .accessibility(identifier: "text_createaccountenteremailaddress_continue")

                }
                .trackRUMTapAction(name: "CONTINUE-create-acct")
                .padding(.bottom, 40)
                .accessibility(identifier: "button_createaccountenteremailaddress_continue")

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
                    .accessibility(identifier: "text_createaccountcheckemailview_accountsetup")

                Text("Check your email inbox")
                    .font(.custom("Roboto-Medium", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_createaccountcheckemailview_inbox")

                Text("To complete your login, we’ve sent an email containing a one-time passcode to:")
                    .font(.custom("Oswald-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_createaccountcheckemailview_complete")

                Text(modelData.userEmailAddress)
                    .font(.custom("Roboto-Regular", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_createaccountcheckemailview_emailaddress")

                Button(action: {
                    navigate(.push(.logInNavToEmailView))
                    logger.info("onBoarding", attributes: ["Login": "How do I navigate to my email?"])
                }) {
                    Text("How do I navigate to my email?")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .accessibility(identifier: "text_createaccountcheckemailview_navigate")

                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .accessibility(identifier: "button_createaccountcheckemailview_navigate")

                Button(action: {
                    navigate(.push(.createAccountEnterCodeView))
                    logger.info("onBoarding", attributes: ["Login": "Enter verification code manually"])
                }) {
                    Text("Enter verification code manually")
                        .underline()
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                        .accessibility(identifier: "text_createaccountcheckemailview_entercode")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "button_createaccountcheckemailview_entercode")

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
                    .accessibility(identifier: "text_createaccountentercodeview_accountsetup")

                Text("Enter verification code received by email:")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                    .accessibility(identifier: "text_createaccountentercodeview_verification")

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
                    .accessibility(identifier: "textfield_createaccountentercodeview_code")

                Button(action: {
#if targetEnvironment(simulator) && QA_TESTING
                    if verificationCode == "1234" {
                        modelData.networkManager.modelData = modelData
                        modelData.onboardingStep = 2
                        navigate(.unwind(.initialSetupOnboarding))
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
                        .accessibility(identifier: "text_createaccountentercodeview_submit")

                }
                .padding(.bottom, 20)
                .accessibility(identifier: "button_createaccountentercodeview_submit")

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
                        .accessibility(identifier: "text_createaccountentercodeview_call")

                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
                .accessibility(identifier: "button_createaccountentercodeview_call")

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
                    .accessibility(identifier: "text_createaccountuserexistsview_exists")

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
                            .accessibility(identifier: "text_createaccountuserexistsview_enterprisename_1")

                        Text(modelData.onboardingEnterpriseSiteCode)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = true
                            }
                            .accessibility(identifier: "text_createaccountuserexistsview_sitecode_1")

                        Button(action: {
                            onboardingEnterpriseSelected = true
                        }) {
                            if onboardingEnterpriseSelected == true {
                                Image("GetStarted - Checked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                                    .accessibility(identifier: "image_createaccountuserexistsview_checked_1")

                            }
                            else {
                                Image("GetStarted - UnChecked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                                    .accessibility(identifier: "image_createaccountuserexistsview_unchecked_1")

                            }
                        }
                        
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
                            .accessibility(identifier: "text_createaccountuserexistsview_enterprisename_2")

                        Text(modelData.enterpriseSiteCode)
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(hex: chHydrationColors.waterFull))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                            .onTapGesture {
                                onboardingEnterpriseSelected = false
                            }
                            .accessibility(identifier: "text_createaccountuserexistsview_sitecode_2")

                        Button(action: {
                            onboardingEnterpriseSelected = false
                        }) {
                            if onboardingEnterpriseSelected == true {
                                Image("GetStarted - UnChecked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                                    .accessibility(identifier: "text_createaccountuserexistsview_unchecked_2")
                            }
                            else {
                                Image("GetStarted - Checked")
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.12)
                                    .accessibility(identifier: "text_createaccountuserexistsview_checked_2")
                            }
                        }

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
                            .accessibility(identifier: "text_createaccountuserexistsview_servererror")

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
                            .accessibility(identifier: "text_createaccountuserexistsview_unknown")

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
                        .accessibility(identifier: "text_createaccountuserexistsview_ok")

                }
                .frame(width: 280, height: 50)
                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                .padding(.bottom, 40)
                .accessibility(identifier: "button_createaccountuserexistsview_ok")

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
                    .accessibility(identifier: "text_createaccountuserexistsview_emailaddress")

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .padding(.top, 10)
                    .accessibility(identifier: "image_createaccountuserexistsview_mappin")

                Text(modelData.CH_EnterpriseName)
                    .font(.custom("Oswald-Regular", size: 32))
                    .foregroundColor(Color(hex: chHydrationColors.waterFull))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(identifier: "text_createaccountuserexistsview_enterprisename")

                if modelData.CH_SiteName.isEmpty {
                    Text(modelData.enterpriseSiteCode)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountuserexistsview_sitecode")

                }
                else {
                    Text(modelData.CH_SiteName)
                        .font(.custom("Oswald-Regular", size: 28))
                        .foregroundColor(Color(hex: chHydrationColors.waterFull))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(identifier: "text_createaccountuserexistsview_sitename")

                }
                
                Text("You can choose to skip onboarding, but we’ll still need to confirm some key information and pair your module to your phone.")
                    .font(.custom("Oswald-Regular", size: languageCode == "ja" ? 14 : 18))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_createaccountuserexistsview_choose")

                Spacer()
                
                Button(action: {
                    // Start Pair Module step 3
                    navigate(.push(.initialSetupOnboarding))
                    modelData.onboardingStep = 2
                }) {
                    Text("CONTINUE WITH ONBOARDING")
                        .font(.custom("Oswald-Regular", size: 18))
                        .foregroundColor(Color(hex: generalCHAppColors.onboardingLtBlueColor))
                        .accessibility(identifier: "text_createaccountuserexistsview_continue")

                }
                .frame(width: 220, height: 50)
                .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
                .padding(.top, 10)
                .padding(.bottom, 20)
                .accessibility(identifier: "button_createaccountuserexistsview_continue")

                Text("I’ll skip Onboarding")
                    .font(.custom("Roboto-Regular", size: 14))
                    .underline()
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                    .onTapGesture {
                        navigate(.push(.step3PairModuleMainView))
                        modelData.onboardingStep = 6
                    }
                    .padding(.bottom, 20)
                    .accessibility(identifier: "text_createaccountuserexistsview_skip")

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
                    .accessibility(identifier: "image_networkupdateUserinfoprogressView_spinner")

                Text("Updating user data...")
                    .font(.custom("Oswald-Regular", size: 24))
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.white))
                    .accessibility(identifier: "text_networkupdateUserinfoprogressView_updating")

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
            .accessibility(identifier: "text_createshowaccounttext_accountsetup")

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
                .accessibility(identifier: "text_createshowaccounttext_success")
        }
    }
}
