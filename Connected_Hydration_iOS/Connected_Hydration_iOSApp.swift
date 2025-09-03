//
//  Connected_Hydration_iOSApp.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//
import UIKit
import SwiftUI
import DatadogCore
import DatadogLogs
import DatadogTrace
import DatadogRUM
import DatadogCrashReporting
import KeychainAccess

var logger: LoggerProtocol!
//var tracer: OTTracer { Tracer.shared() }
//var rumMonitor: RUMMonitorProtocol { RUMMonitor.shared() }

@main
struct Connected_Hydration_iOSAppWrapper {

    static func main() {
/*
        // Fonts not loading? Use this to verify font name and that loading correctly. - debugging
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
*/
/*
        // Use this to clear UserDefaults and/or Keychain when application starts - debugging
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)

            let keychain = Keychain(service: keychainAppBundleId)

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
                logger.info("keychain removal error: \(error)")
            }
        }
*/
        let appID = "fe6831d1-7232-411c-ae24-59a42f4f16e2"
        let clientToken = "pubf0aa7c4c005b9d3ca67eaeb03e2ae649"
        let environment = "prod"

        // Initialize Datadog SDK
        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: clientToken,
                env: environment,
                //batchSize: .small,
                //uploadFrequency: .frequent,
                site: .us5
            ),
            trackingConsent: .granted
        )

        
        // Enable Logs
        Logs.enable()

        // Enable Crash Reporting
        CrashReporting.enable()

        // Set highest verbosity level to see debugging logs from the SDK
        Datadog.verbosityLevel = .debug

        // Enable Trace
        Trace.enable(
            with:Trace.Configuration(
                urlSessionTracking: .init(
                    firstPartyHostsTracing: .traceWithHeaders(
                        hostsWithHeaders: [
                            "ch.epicorebiosystems.com": [.tracecontext]
                        ],
                        sampleRate: 100
                    )
                ),
                networkInfoEnabled: true
            )
        )
  
        RUM.enable(
            with: RUM.Configuration(
                applicationID: appID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                urlSessionTracking: RUM.Configuration.URLSessionTracking(),
                trackBackgroundEvents: true
            )
        )

        RUMMonitor.shared().debug = false

        URLSessionInstrumentation.enable(
            with: .init(
                delegateClass: NetworkManager.self
            )
        )

        // Create Logger
        logger = Logger.create(
            with: Logger.Configuration(
                service: "epicore-ch-ios-app",
                name: "epicore_ch_logger",
                networkInfoEnabled: true,
                remoteSampleRate: 100,
                remoteLogThreshold: .info,
                consoleLogFormat: .shortWith(prefix: "[EpicoreCH_iOS] ")
            )
        )

        logger.addAttribute(forKey: "device-model", value: UIDevice.current.model)

        Connected_Hydration_iOSApp.main()
    }
}

struct Connected_Hydration_iOSApp: App {

    @StateObject private var modelData = ModelData()

    var body: some Scene {

        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                //.environment(\.locale, Locale.init(identifier: "ja"))   // spanish "es" - japanese "ja"
        }
    }
}
