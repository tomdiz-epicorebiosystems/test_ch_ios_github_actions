//
//  CheckAppUpdateAvail.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/14/24.
//

import Foundation
import UIKit

// MARK: - Enum Errors
enum VersionError: Error {
    case invalidBundleInfo, invalidResponse, dataError
}

// MARK: - Models
struct LookupResult: Decodable {
    let data: [TestFlightInfo]?
    let results: [AppInfo]?
}

struct TestFlightInfo: Decodable {
    let type: String
    let attributes: Attributes
}

struct Attributes: Decodable {
    let version: String
    let expired: String
}

struct AppInfo: Decodable {
    let version: String
    let trackViewUrl: String
}

let lastAppUpdateNotificationDateKey = "lastAppUpdateNotifyDate"

class CheckAppUpdateAvail: NSObject {

    public var modelData: ModelData?

    // MARK: - Singleton
    static let shared = CheckAppUpdateAvail()

    // MARK: - TestFlight variable
    var isTestFlight: Bool = false

    static let appStoreId = "1621442254" // Epicore CH appstore Id
    
    func checkForAppUpdate(showLink: Bool, isTestFlight: Bool = false) {
        self.isTestFlight = isTestFlight
        DispatchQueue.global().async {
            self.checkVersion(force : false, showLink: showLink)
        }
    }

    // MARK: - Function to check version
    private  func checkVersion(force: Bool = false, showLink: Bool = false) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (data, info, error) in
                
                let store = self.isTestFlight ? "TestFlight" : "AppStore"
                
                if let error = error {
                    print("error getting app \(store) version: ", error)
                }
                
                if let appStoreAppVersion = info?.version { // Check app on AppStore
                    // Check if the installed app is the same that is on AppStore, if it is, print on console, but if it isn't it shows an alert.
                    if appStoreAppVersion <= currentVersion {
                        print("Already on the last app version: ", currentVersion)
                    } else {
                        print("Needs update: \(store) Version: \(appStoreAppVersion) > Current version: ", currentVersion)
                        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
                        UserDefaults.standard.set(Date(), forKey: lastAppUpdateNotificationDateKey)
                        if self.modelData!.showNotification == false {
                            self.modelData!.notificationData = NotificationModifier.NotificationData(id: appUpdateAvailNotification, title: String(format: "New %@ Application", appName), detail: String(format: "Version %@ is now available.", appStoreAppVersion), type: .Info, notificationLocation: .Top, showOnce: false, showSeconds: ShowOptions.showClose, appURL: (info?.trackViewUrl)!)
                            DispatchQueue.main.async {
                                self.modelData!.showNotification = true
                            }
                        }
                    }
                } else if let testFlightAppVersion = data?.attributes.version { // Check app on TestFlight
                    // Check if the installed app is the same that is on TestFlight, if it is, print on console, but if it isn't it shows an alert.
                    if testFlightAppVersion <= currentVersion {
                        print("Already on the last app version: ",currentVersion)
                    } else {
                        print("Needs update: \(store) Version: \(testFlightAppVersion) > Current version: ", currentVersion)
                        if self.modelData!.showNotification == false {
                            self.modelData!.notificationData = NotificationModifier.NotificationData(id: appUpdateAvailNotification, title: "New Version", detail: String(format: "There is a new EpicoreCH TestFlight Application available version %@", testFlightAppVersion), type: .Info, notificationLocation: .Middle, showOnce: false, showSeconds: -1)
                            DispatchQueue.main.async {
                                self.modelData!.showNotification = true
                            }
                        }
                    }
                }  else { // App doesn't exist on store
                    print("App does not exist on \(store)")
                }
            }
        } else {
            print("Error to decode app current version")
        }
    }

    // https://itunes.apple.com/us/lookup?bundleId=com.epicorebiosystems.rehydrate
    private func getUrl(from identifier: String) -> String {
        // You should pay attention on the country that your app is located
        let testflightURL = "https://api.appstoreconnect.apple.com/v1/apps/\(CheckAppUpdateAvail.appStoreId)/builds"
        let appStoreURL = "http://itunes.apple.com/us/lookup?bundleId=\(identifier)"

        return isTestFlight ? testflightURL : appStoreURL
    }

    private func getAppInfo(completion: @escaping (TestFlightInfo?, AppInfo?, Error?) -> Void) -> URLSessionDataTask? {

        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: getUrl(from: identifier)) else {
                DispatchQueue.main.async {
                    completion(nil, nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        
        // You need to generate an authorization token to access the TestFlight versions and then you replace the ```***``` with the JWT token.
        // https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
        
        let authorization = "Bearer ***"
        
        var request = URLRequest(url: url)
        
        // You just need to add an authorization header if you are checking TestFlight version
        if self.isTestFlight {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        // Make request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                do {
                    if let error = error {
                        print(error)
                        throw error
                    }
                    guard let data = data else { throw VersionError.invalidResponse }
                    
                    let result = try JSONDecoder().decode(LookupResult.self, from: data)
                    print(result)
                    
                    if self.isTestFlight {
                        let info = result.data?.first
                        completion(info, nil, nil)
                    } else {
                        let info = result.results?.first
                        completion(nil, info, nil)
                    }

                } catch {
                    completion(nil, nil, error)
                }
            }
        
        task.resume()
        return task

    }

    func getBundle(key: String) -> String? {

        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
          fatalError("Couldn't find file 'Info.plist'.")
        }
        // Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
          fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}
