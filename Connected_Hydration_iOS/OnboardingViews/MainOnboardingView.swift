//
//  MainOnboardingView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/18/23.
//

import SwiftUI

enum MainOnboardingRoute: Hashable {
    
    case clearNavPath           // goes back to first onboarding screen
    
    // Onboarding navigation
    case startOnboarding
    case getStartedOnboarding
    case initialSetupOnboarding
    
    case logInEmailOnboarding
    case logInCheckEmailView
    case logInEnterCodeView
    case logInNavToEmailView
    case logInVerificationFailedView
    case logInAccountCreatedView
    case logInPhysioloyInfoView
    case logInMainView
    case logInUserExistsView

    case createAccountConfirmEnterprise
    case createAccountEnterEmailAddress
    case createAccountCheckEmailView
    case createAccountEnterCodeView
    case createAccountMainView
    case createAccountUserExistsView

    case step2PersonalizeMainView
    case step2SharingMainView
    
    case step3PairModuleMainView
    case step3PairModuleScanView
    case step3PairModuleIdentifyView
    case step3PairModuleManuallyView
    case step3PairModuleUnresponsive

    case step4ArmBandApplicationStrapTighten
    case step4PatchApplicationMainView
    case step4PatchApplicationCleanSkinView
    case step4PatchApplicationApplyView
    case step4PatchApplicationApplySleeveView
    case step4AttachModule

    case step5OverviewNotificationsView
    case step5OverviewTrackIntakeView
    case step5OverviewEndOfShiftView
    case step5ModuleButtonTrackIntakeView
    case step5OverviewMainView
    case step5OverviewSetupComplete

    // Settings screen navigation
    case settingsSensor
    case settingsLegal
    case settingsTerms
    case settingsPrivacy

    // Intake navigation
    case intakeAddBottle
    case intakeEnterManually
    case intakeBottleList

    case verifyPhysioloyInfoView
}

enum NavigationType: Hashable {
    case push(MainOnboardingRoute)
    case unwind(MainOnboardingRoute)
}

struct NavigateEnvironmentKey: EnvironmentKey {
    static var defaultValue: NavigateAction = NavigateAction(action: { _ in })
}

extension EnvironmentValues {
    var navigate: (NavigateAction) {
        get { self[NavigateEnvironmentKey.self] }
        set { self[NavigateEnvironmentKey.self] = newValue }
    }
}

struct NavigateAction {
    typealias Action = (NavigationType) -> ()
    let action: Action
    func callAsFunction(_ navigationType: NavigationType) {
        action(navigationType)
    }
}

extension View {
    func onNavigate(_ action: @escaping NavigateAction.Action) -> some View {
        self.environment(\.navigate, NavigateAction(action: action))
    }
}

struct MainOnboardingView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var navigationPath: [MainOnboardingRoute] = []

    @State var emailAddress: String = ""
    @State var enterpriseCode: String = ""
    @State var verificationCode: String = ""
    @State var height: String = ""
    @State var weight: String = ""
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 40) {
                StartOnboardingView()
                    .environmentObject(modelData)
                    .navigationDestination(for: MainOnboardingRoute.self) { screen in
                        switch screen {
                        case .startOnboarding:
                            StartOnboardingView()
                                .environmentObject(modelData)

                        // Create Account onboarding flows
                        case .getStartedOnboarding:
                            CreateAccountGetStartedView()
                                .environmentObject(modelData)
                        case .initialSetupOnboarding:
                            InitialSetupView().navigationBarBackButtonHidden(true)
                                .environmentObject(modelData)
                        case .createAccountConfirmEnterprise:
                            CreateAccountConfirmEnterprise()
                                .environmentObject(modelData)
                        case .createAccountEnterEmailAddress:
                            CreateAccountEnterEmailAddress()
                                .environmentObject(modelData)
                        case .createAccountCheckEmailView:
                            CreateAccountCheckEmailView()
                                .environmentObject(modelData)
                        case .createAccountEnterCodeView:
                            CreateAccountEnterCodeView()
                                .environmentObject(modelData)
                        case .createAccountMainView:
                            CreateAccountMainView()
                                .environmentObject(modelData)
                        case .createAccountUserExistsView:
                            CreateAccountUserExistsView()
                                .environmentObject(modelData)

                            // Log In onboarding flows
                        case .logInEmailOnboarding:
                            LogInEnterEmailAddressView()
                                .environmentObject(modelData)
                        case .logInCheckEmailView:
                            LogInCheckEmailView()
                                .environmentObject(modelData)
                        case .logInEnterCodeView:
                            LogInEnterCodeView()
                                .environmentObject(modelData)
                        case .logInNavToEmailView:
                            LogInNavToEmailView()
                                .environmentObject(modelData)
                        case .logInVerificationFailedView:
                            LogInVerificationFailedView()
                                .environmentObject(modelData)
                        case .logInAccountCreatedView:
                            LogInAccountCreatedView()
                                .environmentObject(modelData)
                        case .logInPhysioloyInfoView:
                            LogInPhysioloyInfoView()
                                .environmentObject(modelData)
                        case .logInMainView:
                            LogInMainView()
                                .environmentObject(modelData)
                        case .logInUserExistsView:
                            LogInUserExistsView()
                                .environmentObject(modelData)

                        case .step2PersonalizeMainView:
                            Step2PersonalizeMainView().navigationBarBackButtonHidden(true)
                                .environmentObject(modelData)
                        case .step2SharingMainView:
                            Step2SharingMainView().navigationBarBackButtonHidden(true)
                                .environmentObject(modelData)

                            // Step 3 pair module
                        case .step3PairModuleMainView:
                            Step3PairModuleMainView().navigationBarBackButtonHidden(false)
                                .environmentObject(modelData)
                        case .step3PairModuleScanView:
                            Step3PairModuleScanView().navigationBarBackButtonHidden(false)
                                .environmentObject(modelData)
                        case .step3PairModuleIdentifyView:
                            Step3PairModuleIdentifyView().navigationBarBackButtonHidden(true)
                                .environmentObject(modelData)
                        case .step3PairModuleManuallyView:
                            Step3PairModuleManuallyView().navigationBarBackButtonHidden(false)
                                .environmentObject(modelData)
                        case .step3PairModuleUnresponsive:
                            Step3PairModuleUnresponsive().navigationBarBackButtonHidden(false)
                                .environmentObject(modelData)

                            // Step 4 attach module
                        case .step4ArmBandApplicationStrapTighten:
                            Step4ArmBandApplicationStrapTighten()
                                .environmentObject(modelData)
                        case .step4PatchApplicationMainView:
                            Step4PatchApplicationMainView()
                                .environmentObject(modelData)
                        case .step4PatchApplicationCleanSkinView:
                            Step4PatchApplicationCleanSkinView()
                                .environmentObject(modelData)
                        case .step4PatchApplicationApplyView:
                            Step4PatchApplicationApplyView()
                                .environmentObject(modelData)
                        case .step4PatchApplicationApplySleeveView:
                            Step4PatchApplicationApplySleeveView()
                                .environmentObject(modelData)
                        case .step4AttachModule:
                            Step4AttachModule()
                                .environmentObject(modelData)

                            // Step 5 overview
                        case .step5OverviewMainView:
                            Step5OverviewMainView()
                                .environmentObject(modelData)
                        case .step5OverviewNotificationsView:
                            Step5OverviewNotificationsView()
                                .environmentObject(modelData)
                        case .step5OverviewTrackIntakeView:
                            Step5OverviewTrackIntakeView()
                                .environmentObject(modelData)
                        case .step5OverviewEndOfShiftView:
                            Step5OverviewEndOfShiftView()
                                .environmentObject(modelData)
                        case .step5ModuleButtonTrackIntakeView:
                            Step5ModuleButtonTrackIntakeView()
                                .environmentObject(modelData)
                        case .step5OverviewSetupComplete:
                            Step5OverviewSetupComplete()
                                .environmentObject(modelData)

                        case .verifyPhysioloyInfoView:
                            VerifyPhysioloyInfoView().navigationBarBackButtonHidden(true)
                                .environmentObject(modelData)

                        default:
                            EmptyView()
                    }
                }
            }
        }
        .trackRUMView(name: "MainOnboardingView")
        .tint(.white)
        .onNavigate { navType in
            switch navType {
                case .push(let route):
                    navigationPath.append(route)
                case .unwind(let route):
                    // We now start push navs right from first screen now, don't need to clear for now - could do
                    // .clearOnboarding - to go to first create/login screen again
                    //if route == .initialSetupOnboarding {
                    if route == .clearNavPath {
                        navigationPath = []
                    } else {
                        guard let index = navigationPath.firstIndex(where: { $0 == route })  else { return }
                        navigationPath = Array(navigationPath.prefix(upTo: index + 1))
                    }
            }
        }
        .background(Color(hex: generalCHAppColors.onboardingVeryDarkBackground)
            .edgesIgnoringSafeArea(.all))

    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
