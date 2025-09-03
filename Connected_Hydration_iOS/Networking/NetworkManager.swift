//
//  NetworkManager.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/19/23.
//

import Foundation
import SwiftUI
import CryptoKit
import KeychainAccess
import JWTDecode
import BLEManager

enum ErrorCodes: CustomStringConvertible {
    case authorizationError
    case internalError
    case entityNotFound
    case accessDenied
    case invalidClient
    case toManyRequests
    case invalidArgumentsException
    case unprocessableEntity
    case externalServiceError
    case temporaryUnavailable
    case localHTTPError
    
    var description : String {
      switch self {
      case .authorizationError: return "authorization_error"
      case .internalError: return "internal_error"
      case .entityNotFound: return "entity_not_found"
      case .accessDenied: return "access_denied"
      case .invalidClient: return "invalid_client"
      case .toManyRequests: return "toManyRequests"
      case .invalidArgumentsException: return "invalid_argument"
      case .unprocessableEntity: return "unprocessable_entity"
      case .externalServiceError: return "external_service_error"
      case .temporaryUnavailable: return "temporary_unavailable"
      case .localHTTPError: return "local_http_error"
      }
    }
}

enum ErrorStatuses: Int {
    case authorizationError = 401
    case permissionDenied = 403
    case entityNotFound = 404
    case invalidArgumentsException = 400
    case unprocessableEntity = 422
    case FailedDependency = 424
    case TooManyRequests = 429
    case internalServerError = 500
    case temporaryUnavailable = 503
}

//let header = ["alg": "HS256", "typ": "JWT"]
let keychainAppBundleId = "com.epicorebiosystems.Rehydrate"

//
// Decoded JSON returned from server side API
//

// API errors
struct ServerError: Codable {
    var error: String?
    var errorDescription: String?
}

// GET enterprise name error
struct EnterpriseNameError: Codable {
    var message: String?
    var status: String?
    var errorKey: String?
    var errorCode: Int?
}

struct UpdateUserServerError: Codable {
    var message: String?
    var status: String?
    var errorKey: String?
    var errorCode: Int?
}

//
// login-context
//
struct LoginContext: Codable {
    let userStatus: String
}

//
// authenticate-with-code
//
struct AuthenticatedUser: Codable {
    var token: String?
    var refreshToken: String?
}

//
// sites
//
struct EnterpriseInfo: Codable {
    let name: String
    let enterprise: EnterpriseName
}

struct EnterpriseName: Codable {
    let name: String
}

//
// user-info : Used for privacy settings
//
struct UserPrivacyInfo: Codable {
    let userInfo: UserInfo
    let agreements: Agreements
}

struct Agreements: Codable {
    let shareStatsWithEpicore: Bool?
    let shareStatsWithSite: [String:Bool?]?
}

struct UserInfo: Codable {
    let firstName: String?
    let lastName: String?
    let email: String
    let lastLoginAt: String
    let height: String?
    let weight: String?
    let gender: String?
}

//
// Auth0 Refresh Token
//
struct UpdateRefreshToken: Codable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let scope: String
    let expiresIn: Int
    let tokenType: String
}

//
// avg-sweat-volume-sodium-concentration
//
struct DataSweatVolumeSodiumConcentration: Codable {
    var sweatVolumeMl: Double
    var sodiumConcentrationMm: Double
}

struct AvgSweatVolumeSodiumConcentration: Codable {
    var status: String
    var data: DataSweatVolumeSodiumConcentration
}

//
// user-stats
//
struct UserHistoryStats: Codable {
    let status: String
    let data: [DayIntakeLossData]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}

struct DayIntakeLossData: Codable {
    let date: String
    let sodium_intake_ml: Double?
    let water_intake_ml: Double?
    let sodium_loss_ml: Double?
    let water_loss_ml: Double?
}

class NetworkManager: NSObject, ObservableObject {
    
    public var modelData: ModelData?
    var serverError: ServerError?
    var enterpriseNameErr: EnterpriseNameError?
    var sendCode: String?
    let scheme = "https"
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    func getUserLoginContext(email: String) {
        var loginContext: LoginContext?
        let queryParams: [String: String] = [
            "email": email
        ]
        var components = URLComponents()
        components.scheme = scheme
        components.host = modelData!.epicoreHost
        components.path = "/api/external/onboarding/login-context"
        components.setQueryItems(with: queryParams)
        let url = components.url
        print("url = " + url!.absoluteString)

        modelData?.userEmailAddress = email
        self.modelData?.showNoAccountFound = false

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("2", forHTTPHeaderField: "api-version")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(modelData!.ch_phone_api_key, forHTTPHeaderField: "ch-phone-api-key")
        if (languageCode == "ja") {
            request.addValue("language=\"ja\"", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let errorCheckString = String(decoding: data, as: UTF8.self)
                print("data = " + errorCheckString)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if errorCheckString.contains("error") {
                        let decodedResponse = try decoder.decode(ServerError.self, from: data)
                        logger.error("getUserLoginContext", attributes: ["error": decodedResponse.errorDescription])
                        self.modelData?.networkManager.serverError = decodedResponse
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                        }
                    }
                    else {
                        let decodedResponse = try decoder.decode(LoginContext.self, from: data)
                        loginContext = decodedResponse
                        print("userStatus: " + loginContext!.userStatus)
                        if (loginContext!.userStatus == "exists") {
                            self.modelData?.downloadUserPhysiology = true
                        }
                        let accountExists = loginContext!.userStatus == "exists"
                        self.modelData?.userStatusString = loginContext!.userStatus
                        DispatchQueue.main.async {
                            self.modelData?.userExists = 1
                            self.modelData?.showNoAccountFound = accountExists == false
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                var serverError = ServerError()
                serverError.error = error.localizedDescription
                serverError.errorDescription = error.localizedDescription
                logger.error("getUserLoginContext", attributes: ["HTTP request failed": error.localizedDescription])
                self.modelData?.networkManager.serverError = serverError
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                }
            }
            
        }.resume()
    }
    
    func sendCode(email: String, enterpriseCode: String) {
        do {
            // Header
            let header: [String: String] = ["alg": "HS256", "typ": "JWT"]
            let encodedHeader = Data(try JSONSerialization.data(withJSONObject: header, options: .prettyPrinted)).base64EncodedString()
            
            // Payload
            let payload: [String: String] = ["email": email, "enterpriseCode": enterpriseCode]
            let encodedPayload = Data(try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)).base64EncodedString()
            
            // Signature
            let signature = encodedHeader + "." + encodedPayload
            //let encryptedSignature = try! HMAC(key: secret.bytes, variant: .sha256).authenticate(signature.bytes).toBase64()
            let key = SymmetricKey(data: Data(modelData!.ch_phone_api_jwt_secret.utf8))
            let bytes = HMAC<SHA256>.authenticationCode(for: Data(signature.utf8), using: key)
            let data = Data(bytes)
            let encryptedSignature = data.base64EncodedString(options:   Data.Base64EncodingOptions(rawValue: 0))
            
            // Token
            let token = signature + "." + encryptedSignature
            
            // Request body
            let requestBody: [String: Any] = ["encodedData": token]
            let jsonData = try! JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)

            var components = URLComponents()
            components.scheme = scheme
            components.host = modelData!.epicoreHost
            components.path = "/api/external/onboarding/send-code"
            let url = components.url
            print("url = " + url!.absoluteString)

            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.setValue("2", forHTTPHeaderField: "api-version")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue(modelData!.ch_phone_api_key, forHTTPHeaderField: "ch-phone-api-key")
            if (languageCode == "ja") {
                request.addValue("language=\"ja\"", forHTTPHeaderField: "Cookie")
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let data = data {
                    let errorCheckString = String(decoding: data, as: UTF8.self)
                    //print("data = " + errorCheckString)
                    if errorCheckString.contains("error") {
                        logger.error("sendCode", attributes: ["error": errorCheckString])
                    }

                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        if errorCheckString.contains("error") {
                            let decodedResponse = try decoder.decode(ServerError.self, from: data)
                            self.serverError = decodedResponse
                            DispatchQueue.main.async {
                                self.modelData?.networkSendCodeAPIError = 1
                            }
                        }
                        else {
                            self.sendCode = errorCheckString
                            DispatchQueue.main.async {
                                self.modelData?.sendCodeSuccess = 1
                            }
                        }
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                    var sendCodeServerError = ServerError()
                    sendCodeServerError.error = "\(ErrorCodes.localHTTPError)"
                    sendCodeServerError.errorDescription = error.localizedDescription
                    self.serverError = sendCodeServerError
                    logger.error("getUserLoginContext", attributes: ["HTTP request failed": error.localizedDescription])
                    DispatchQueue.main.async {
                        self.modelData?.networkSendCodeAPIError = 1
                    }
                }
                
            }.resume()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func AuthenticateWithCode(email: String, verificationCode: String) {
        let keychain = Keychain(service: keychainAppBundleId)
        // Request body
        let requestBody: [String: Any] = ["email": email, "verificationCode": verificationCode]
        let jsonData = try! JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = modelData!.epicoreHost
        components.path = "/api/external/onboarding/authenticate-with-code"
        let url = components.url
        print("url = " + url!.absoluteString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("2", forHTTPHeaderField: "api-version")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(modelData!.ch_phone_api_key, forHTTPHeaderField: "ch-phone-api-key")
        if (languageCode == "ja") {
            request.addValue("language=\"ja\"", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if let data = data {
                let errorCheckString = String(decoding: data, as: UTF8.self)
                //print("data = " + errorCheckString)
                if errorCheckString.contains("error") {
                    logger.error("AuthenicateWithCode", attributes: ["error": errorCheckString])
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if errorCheckString.contains("error") {
                        let decodedResponse = try decoder.decode(ServerError.self, from: data)
                        self.modelData?.networkManager.serverError = decodedResponse
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                        }
                    }
                    else {
                        let decodedResponse = try decoder.decode(AuthenticatedUser.self, from: data)
                        let authenticatedUser = decodedResponse
                        keychain["access_token"] = authenticatedUser.token
                        keychain["refresh_token"] = authenticatedUser.refreshToken
                        //print("token: " + authenticatedUser.token!)
                        //print("refresh_token: " + authenticatedUser.refreshToken!)
                        
                        // Retrieve and save user account information here
                        let jwt = try! decode(jwt: authenticatedUser.token!)
                        let json = jwt.body
                        let enterprises = json["epicore_custom/enterprises"] as? Array<Any>
                        var enterpriseName = ""

                        // go through array to find correct enterprise user entered
                        let enterpriseAndSiteID = modelData?.enterpriseSiteCode
                        let splitCode = enterpriseAndSiteID!.split(separator: "-")
                        // This is here for debugging - remove for release
                        if splitCode.isEmpty {
                            return
                        }
                        let enterpriseIdLookingFor = splitCode[0]
                        if enterprises != nil {
                            for index in 0..<enterprises!.count {
                                let enterprise =  enterprises![index] as? [String: Any]
                                let eIdExist = enterprise?["enterprise_id"] as? NSNull
                                if eIdExist != nil {
                                    continue
                                }
                                else {
                                    let indexEnterpriseId = enterprise!["enterprise_id"] as! String
                                    if enterpriseIdLookingFor == indexEnterpriseId {
                                        enterpriseName = enterprise!["name"] as! String
                                        break
                                    }
                                }
                            }
                        }

                        // if "role" == "CH_USER" then want to store off "enterprise_id" and "site_id" in keychain
                        // The db_roles can have multiple enterpise/sites in existence

                        var userRole = ""
                        var enterpriseId = ""
                        let roles = json["epicore_custom/db_roles"] as? Array<Any>
                        if roles != nil {
                            for index in 0..<roles!.count {
                                let role = roles![index] as? [String: Any]
                                let eIdExist = role?["enterprise_id"] as? NSNull
                                if eIdExist != nil {
                                    continue
                                }
                                else {
                                    let indexEnterpriseId = role!["enterprise_id"] as! String
                                    if enterpriseIdLookingFor == indexEnterpriseId {
                                        userRole = role!["role"] as! String
                                        enterpriseId = role!["enterprise_id"] as! String
                                        break
                                    }
                                }
                            }
                        }

                        let userID = json["epicore_custom/user_id"]

                        DispatchQueue.main.async {

                            self.modelData?.CH_UserID = (userID as? String)!
                            self.modelData?.CH_UserRole = userRole
                            self.modelData?.CH_EnterpriseName = enterpriseName
                            self.modelData?.jwtEnterpriseID = enterpriseId
                            self.modelData?.jwtSiteID = String(splitCode[1])

                            // Store enterprise and site ID to keychain - used for existing user onboarding flow
                            keychain["email_address"] = self.modelData?.userEmailAddress
                            keychain["enterpriseId_siteCode"] = self.modelData?.enterpriseSiteCode
                            keychain["enterprise_name"] = self.modelData?.CH_EnterpriseName
                            keychain["jwt_enterprise_id"] = self.modelData?.jwtEnterpriseID
                            keychain["jwt_site_id"] = self.modelData?.jwtSiteID

                            keychain["currentApiServer"] = self.modelData?.epicoreHost

                            keychain["user_id"] = self.modelData?.CH_UserID
                            keychain["user_role"] = self.modelData?.CH_UserRole

                            // Used to test code failure view
                            self.modelData?.userAuthenticated = 1
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                var serverError = ServerError()
                serverError.error = error.localizedDescription
                serverError.errorDescription = error.localizedDescription
                logger.error("AuthenicateWithCode", attributes: ["HTTP request failed": error.localizedDescription])
                self.modelData?.networkManager.serverError = serverError
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                }
            }
            
        }.resume()
    }
    
    func getUserHistoryStats() {
        let keychain = Keychain(service: keychainAppBundleId)
        if let token = keychain["access_token"] {
            let startLocalDate = generateCurrentLocalDateMinus30Days()
            let endLocalDate = generateCurrentLocalDate()
            var components = URLComponents()
            components.scheme = scheme
            components.host = modelData!.epicoreHost
            components.path = "/api/external/user-stats"
            components.queryItems = [
                URLQueryItem(name: "start", value: startLocalDate),
                URLQueryItem(name: "end", value: endLocalDate)
            ]
            let url = components.url
            print("url = " + url!.absoluteString)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.httpShouldHandleCookies = true
            request.setValue("2", forHTTPHeaderField: "api-version")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            if (languageCode == "ja") {
                request.addValue("language=\"ja\"; selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
            }
            else {
                request.addValue("selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in

                if let data = data {
                    let errorCheckString = String(decoding: data, as: UTF8.self)
                    //print("data = " + errorCheckString)
                    do {
                        let decoder = JSONDecoder()
                        if errorCheckString.contains("error") {
                            let decodedResponse = try decoder.decode(ServerError.self, from: data)
                            self.serverError = decodedResponse
                            logger.error("getUserHistoryStats", attributes: ["error": self.serverError?.error])
                            DispatchQueue.main.async {
                                self.modelData?.networkAPIError = true
                                self.modelData?.userHistoryStatsSuccess = false
                            }
                        }
                        else {
                            let decodedResponse = try decoder.decode(UserHistoryStats.self, from: data)
                            self.modelData!.userHistoryStats = decodedResponse

                            DispatchQueue.main.async {
                                self.modelData?.userHistoryStatsSuccess = true
                            }
                        }
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                    var userServerError = ServerError()
                    userServerError.error = "\(ErrorCodes.localHTTPError)"
                    userServerError.errorDescription = error.localizedDescription
                    self.serverError = userServerError
                    logger.error("getUserHistoryStats", attributes: ["HTTP request failed": error.localizedDescription])
                    DispatchQueue.main.async {
                        self.modelData?.networkAPIError = true
                    }
                }
                
            }.resume()
        }
    }

    func getAvgSweatVolumeSodiumConcentration() {
        let keychain = Keychain(service: keychainAppBundleId)
        if let token = keychain["access_token"] {
            var components = URLComponents()
            components.scheme = scheme
            components.host = modelData!.epicoreHost
            components.path = "/api/external/avg-sweat-volume-sodium-concentration"
            let url = components.url
            print("url = " + url!.absoluteString)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("2", forHTTPHeaderField: "api-version")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            if (languageCode == "ja") {
                request.addValue("language=\"ja\"; selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
            }
            else {
                request.addValue("selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in

                if let data = data {
                    let errorCheckString = String(decoding: data, as: UTF8.self)
                    //print("data = " + errorCheckString)
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        if errorCheckString.contains("error") {
                            let decodedResponse = try decoder.decode(ServerError.self, from: data)
                            self.serverError = decodedResponse
                            DispatchQueue.main.async {
                                self.modelData?.networkAPIError = true
                                self.modelData?.userAvgSweatSodiumConcentrationSuccess = false
                            }
                        }
                        else {
                            let decodedResponse = try decoder.decode(AvgSweatVolumeSodiumConcentration.self, from: data)
                            self.modelData!.userAvgSweatSodiumConcentration = decodedResponse
                            print("sweatVolumeMl: \(self.modelData!.userAvgSweatSodiumConcentration!.data.sweatVolumeMl)")
                            print("sodiumConcentrationMm: \(self.modelData!.userAvgSweatSodiumConcentration!.data.sodiumConcentrationMm)")

                            DispatchQueue.main.async {
                                self.modelData?.userAvgSweatSodiumConcentrationSuccess = true
                            }
                        }
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                    var updateUserServerError = ServerError()
                    updateUserServerError.error = "\(ErrorCodes.localHTTPError)"
                    updateUserServerError.error = error.localizedDescription
                    self.serverError = updateUserServerError
                    logger.error("getAvgSweatVolumeSodiumConcentration", attributes: ["HTTP request failed": error.localizedDescription])
                    DispatchQueue.main.async {
                        self.modelData?.networkAPIError = true
                    }
                }
                
            }.resume()
        }
    }
    
    func updateUser(enterpriseId: String, siteId: String, userInfo: [String: Any]) {
        // Request body
        let keychain = Keychain(service: keychainAppBundleId)
        if let refreshToken = keychain["refresh_token"],
           let token = keychain["access_token"] {
            let requestBody: [String: Any] = ["enterpriseCode": enterpriseId + "-" + siteId, "userInfo": userInfo, "refreshToken": refreshToken]
            let jsonData = try! JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            var components = URLComponents()
            components.scheme = scheme
            components.host = modelData!.epicoreHost
            components.path = "/api/external/onboarding/update-user"
            let url = components.url
            print("url = " + url!.absoluteString)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.setValue("2", forHTTPHeaderField: "api-version")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            if (languageCode == "ja") {
                request.addValue("language=\"ja\"; selectedUserRoles=[{\"enterprise_id\": \"\(enterpriseId)\",\"role\":\"CH_USER\",\"site_id\": \"\(siteId)\"}]", forHTTPHeaderField: "Cookie")
            }
            else {
                request.addValue("selectedUserRoles=[{\"enterprise_id\": \"\(enterpriseId)\",\"role\":\"CH_USER\",\"site_id\": \"\(siteId)\"}]", forHTTPHeaderField: "Cookie")
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let data = data {
                    let errorCheckString = String(decoding: data, as: UTF8.self)
                    //print("data = " + errorCheckString)
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        if errorCheckString.contains("error") {
                            if errorCheckString.contains("message") {
                                let decodedResponse = try decoder.decode(UpdateUserServerError.self, from: data)
                                self.serverError = ServerError(error: decodedResponse.message, errorDescription: decodedResponse.message)
                            }
                            else {
                                let decodedResponse = try decoder.decode(ServerError.self, from: data)
                                self.serverError = decodedResponse
                            }
                            DispatchQueue.main.async {
                                self.modelData?.networkAPIError = true
                                self.modelData?.updatedUserSuccess = 0
                                self.modelData?.updateUserSuccess = false
                                self.modelData?.userUpdateAPIFailure = true
                            }
                        }
                        else {
                            let keychain = Keychain(service: keychainAppBundleId)
                            let decodedResponse = try decoder.decode(AuthenticatedUser.self, from: data)
                            let authenticatedUser = decodedResponse
//                            print("token: " + authenticatedUser.token!)
                            keychain["access_token"] = authenticatedUser.token
//                            print("refresh_token: " + authenticatedUser.refreshToken!)
                            keychain["refresh_token"] = authenticatedUser.refreshToken
                            
                            // Retrieve and save user account information here
                            let jwt = try! decode(jwt: authenticatedUser.token!)
                            let json = jwt.body
                            let enterprises = json["epicore_custom/enterprises"] as? Array<Any>
                            var enterpriseName = ""
                            
                            let enterpriseIdLookingFor = enterpriseId
                            if enterprises != nil {
                                for index in 0..<enterprises!.count {
                                    let enterprise =  enterprises![index] as? [String: Any]
                                    let eIdExist = enterprise?["enterprise_id"] as? NSNull
                                    if eIdExist != nil {
                                        continue
                                    }
                                    else {
                                        let indexEnterpriseId = enterprise!["enterprise_id"] as! String
                                        if enterpriseIdLookingFor == indexEnterpriseId {
                                            enterpriseName = enterprise!["name"] as! String
                                            break
                                        }
                                    }
                                }
                            }

                            // if "role" == "CH_USER" then want to store off "enterprise_id" and "site_id" in keychain
                            // The db_roles can have multiple enterpise/sites in existence

                            var userRole = ""
                            var enterpriseIdSet = ""
                            var siteIdSet = ""
                            let siteIdLookingFor = siteId
                            let roles = json["epicore_custom/db_roles"] as? Array<Any>
                            if roles != nil {
                                for index in 0..<roles!.count {
                                    let role = roles![index] as? [String: Any]
                                    let roleType = role?["role"] as? String
                                    
                                    // Only check for "CH_USER" role as it's the only db role that applies to the app.
                                    if roleType != "CH_USER" {
                                        continue
                                    }
                                    // This is "CH_USER" role, check to confirm the new enterprise ID and site ID were set correctly.
                                    else {
                                        guard let indexEnterpriseId = role!["enterprise_id"] as? String else {
                                            continue
                                        }
                                        
                                        guard let indexSiteId = role!["site_id"] as? String else {
                                            continue
                                        }
                                        
                                        if ((enterpriseIdLookingFor == indexEnterpriseId) && (siteIdLookingFor == indexSiteId)) {
                                            userRole = role!["role"] as! String
                                            enterpriseIdSet = role!["enterprise_id"] as! String
                                            siteIdSet = role!["site_id"] as! String
                                            break
                                        }
                                    }
                                }
                            }

                            let userID = json["epicore_custom/user_id"]

                            DispatchQueue.main.async {
                                
                                self.modelData?.CH_UserID = (userID as? String)!
                                self.modelData?.CH_UserRole = userRole
                                self.modelData?.CH_EnterpriseName = enterpriseName
                                self.modelData?.jwtEnterpriseID = enterpriseIdSet
                                self.modelData?.jwtSiteID = siteIdSet
                                self.modelData?.enterpriseSiteCode = enterpriseIdSet + "-" + siteIdSet
                                
                                // Store enterprise and site ID to keychain - used for existing user onboarding flow
                                keychain["email_address"] = self.modelData?.userEmailAddress
                                keychain["enterpriseId_siteCode"] = self.modelData?.enterpriseSiteCode
                                keychain["enterprise_name"] = self.modelData?.CH_EnterpriseName
                                keychain["jwt_enterprise_id"] = self.modelData?.jwtEnterpriseID
                                keychain["jwt_site_id"] = self.modelData?.jwtSiteID

                                keychain["currentApiServer"] = self.modelData?.epicoreHost

                                keychain["user_id"] = self.modelData?.CH_UserID
                                keychain["user_role"] = self.modelData?.CH_UserRole
                                
                                self.modelData?.updatedUserSuccess = 1
                                self.modelData?.updateUserSuccess = true
                                self.modelData?.userUpdateAPIFailure = false
                            }
                        }
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                        self.serverError = ServerError(error: "Data Corrupted", errorDescription: "Data Corrupted")
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                            self.modelData?.userUpdateAPIFailure = true
                        }
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                        self.serverError = ServerError(error: "JSON key not found", errorDescription: "JSON key not found")
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                            self.modelData?.userUpdateAPIFailure = true
                        }
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                        self.serverError = ServerError(error: "JSON value not found", errorDescription: "JSON value not found")
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                            self.modelData?.userUpdateAPIFailure = true
                        }
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                        self.serverError = ServerError(error: "JSON type mismatch", errorDescription: "JSON type mismatch")
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                            self.modelData?.userUpdateAPIFailure = true
                        }
                    } catch {
                        print("error: ", error)
                        self.serverError = ServerError(error: "Server error", errorDescription: "Server error")
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                            self.modelData?.userUpdateAPIFailure = true
                        }
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                    var updateUserServerError = ServerError()
                    updateUserServerError.error = "\(ErrorCodes.localHTTPError)"
                    updateUserServerError.error = error.localizedDescription
                    self.serverError = updateUserServerError
                    logger.error("updateUser", attributes: ["HTTP request failed": self.serverError?.error])
                    DispatchQueue.main.async {
                        self.modelData?.networkAPIError = true
                        self.modelData?.userUpdateAPIFailure = true
                    }
                }
                
            }.resume()
        }
    }
    
    func GetUserInfo() {
        var components = URLComponents()
        components.scheme = scheme
        components.host = modelData!.epicoreHost
        components.path = "/api/external/user-info"
        let url = components.url
        print("url = " + url!.absoluteString)
        
        let keychain = Keychain(service: keychainAppBundleId)
        let token = keychain["access_token"]
        
        if token == nil {
            logger.error("GetUserInfo", attributes: ["error": "keychain access_token is nil"])
            return
        }
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("2", forHTTPHeaderField: "api-version")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")
        if (languageCode == "ja") {
            request.addValue("language=\"ja\"; selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
        }
        else {
            request.addValue("selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            
            if let data = data {
                let errorCheckString = String(decoding: data, as: UTF8.self)
                //print("data = " + errorCheckString)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if errorCheckString.contains("error") {
                        let decodedResponse = try decoder.decode(ServerError.self, from: data)
                        self.serverError = decodedResponse
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                        }
                    }
                    else{
                        // User privacy settings
                        let userPrivacySettings = try decoder.decode(UserPrivacyInfo.self, from: data)
                        var siteSharing = false
                        if userPrivacySettings.agreements.shareStatsWithSite != nil {
                            siteSharing = (userPrivacySettings.agreements.shareStatsWithSite?[self.modelData!.enterpriseSiteCode] ?? false) as Bool? ?? false
                        }

                        // User physiology settings
                        let heightCm: UInt8 = UInt8(userPrivacySettings.userInfo.height ?? "125") ?? 125
                        self.modelData?.userPrefsData.setUserWeightNetwork(weight: userPrivacySettings.userInfo.weight ?? "100")
                        self.modelData?.userPrefsData.setUserHeightCm(cm: heightCm)
                        let heightInInches = (Double(heightCm)) / 2.54
                        let heightFeet = "\(Int(heightInInches / 12.0))"
                        let heightInch = "\(Int(round(heightInInches.truncatingRemainder(dividingBy: 12.0))))"
                        self.modelData?.userPrefsData.setUserHeightInch(inches: heightInch)
                        self.modelData?.userPrefsData.setUserHeightFeet(feet: heightFeet)
                        let gender = userPrivacySettings.userInfo.gender ?? "male"
                        self.modelData?.userPrefsData.setUserGender(gender: gender.caseInsensitiveCompare("male") == .orderedSame ? "M" : "F")

                        DispatchQueue.main.async {
                            self.modelData?.shareAnonymousDataEnterprise = siteSharing
                            self.modelData?.shareAnonymousDataEpicore = userPrivacySettings.agreements.shareStatsWithEpicore ?? false
                            self.modelData?.networkAPIError = false
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                var serverError = ServerError()
                serverError.error = error.localizedDescription
                serverError.errorDescription = error.localizedDescription
                self.modelData?.networkManager.serverError = serverError
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                }
            }
            
        }.resume()
    }

    func SetUserInfo(epicore: Bool, site: Bool) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = modelData!.epicoreHost
        components.path = "/api/external/user-info"
        let url = components.url
        print("url = " + url!.absoluteString)
        
        let keychain = Keychain(service: keychainAppBundleId)
        let token = keychain["access_token"]

        if token == nil {
            logger.error("SetUserInfo", attributes: ["error": "keychain access_token is nil"])
            return
        }
        
        let requestBody: [String: Any] = ["agreements": ["share_stats_with_epicore": epicore, "share_stats_with_site": [modelData!.enterpriseSiteCode : site]]]
        let jsonData = try! JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)

        var request = URLRequest(url: url!)
        request.httpMethod = "PATCH"
        request.httpBody = jsonData
        request.setValue("2", forHTTPHeaderField: "api-version")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")
        if (languageCode == "ja") {
            request.addValue("language=\"ja\"; selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
        }
        else {
            request.addValue("selectedUserRoles=[{\"enterprise_id\": \"\(modelData!.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\": \"\(modelData!.jwtSiteID)\"}]", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let errorCheckString = String(decoding: data, as: UTF8.self)
                //print("data = " + errorCheckString)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if errorCheckString.contains("error") {
                        let decodedResponse = try decoder.decode(ServerError.self, from: data)
                        self.serverError = decodedResponse
                        DispatchQueue.main.async {
                            self.modelData?.networkAPIError = true
                        }
                    }
                    else{
                        let userPrivacySettings = try decoder.decode(UserPrivacyInfo.self, from: data)
                        if userPrivacySettings.agreements.shareStatsWithSite != nil {
                            DispatchQueue.main.async {
                                self.modelData!.shareAnonymousDataEnterprise = (userPrivacySettings.agreements.shareStatsWithSite?[self.modelData!.enterpriseSiteCode] ?? false) as Bool? ?? false
                            }
                        }
                        else {
                            self.modelData!.shareAnonymousDataEnterprise = false
                        }
                        DispatchQueue.main.async {
                            self.modelData!.shareAnonymousDataEpicore = userPrivacySettings.agreements.shareStatsWithEpicore ?? false
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                var serverError = ServerError()
                serverError.error = error.localizedDescription
                serverError.errorDescription = error.localizedDescription
                self.modelData?.networkManager.serverError = serverError
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                }
            }
            
        }.resume()
    }

    // Auth0 - refresh token renewal
    // New standard using: https://auth0.com/docs/get-started/authentication-and-authorization-flow/call-your-api-using-the-authorization-code-flow-with-pkce#example-post-to-token-url
    
    func getNewRefreshToken() {
        // PKCE
        let keychain = Keychain(service: keychainAppBundleId)
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        let currRefreshToken = keychain["refresh_token"]
        if currRefreshToken == nil {
            return
        }
        let postData = NSMutableData(data: "grant_type=refresh_token".data(using: String.Encoding.utf8)!)

        postData.append(modelData!.clientId.data(using: String.Encoding.utf8)!)

        postData.append(("&refresh_token=" + currRefreshToken!).data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(url: NSURL(string: "https://" + modelData!.auth0Url + "/oauth/token")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                print(error as Any)
                self.serverError = ServerError(error: error?.localizedDescription, errorDescription: error?.localizedDescription)
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                }
            } else {
                if let data = data {
                    let errorCheckString = String(decoding: data, as: UTF8.self)
//                    print("data = " + errorCheckString)
                    if errorCheckString.contains("error") {
                        logger.error("getNewRefreshToken", attributes: ["error": errorCheckString])
                        if errorCheckString.contains("invalid_grant") {
                            logger.info("getNewRefreshToken - force logging user out")
                            // Remove old keychain values - refresh token is messed up for Auth0 refresh
                            // Need to Authenticate - full user login to fix
                            DispatchQueue.main.async {
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
                                
                                self.modelData?.userPrefsData.resetUserPrefs()
                                // NOTE: Can't call logout() because refresh token is no good - just go back to signin
                                self.modelData?.isOnboardingComplete = false
                                self.modelData?.onboardingStep = 1
                                self.modelData?.networkAPIError = false
                                self.modelData?.networkManager.serverError = nil
                                self.modelData?.ebsMonitor.forceDisconnectFromPeripheral()
                                self.modelData?.pairCHDeviceSN = ""
                            }
                        }
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decodedResponse = try decoder.decode(UpdateRefreshToken.self, from: data)
                        let updateRefreshToken = decodedResponse
                        //print("token: " + updateRefreshToken.accessToken)
                        //print("refresh_token: " + updateRefreshToken.refreshToken)
                        //NOTE(tsd): This should be stored off in keychain
                        keychain["access_token"] = updateRefreshToken.accessToken
                        keychain["refresh_token"] = updateRefreshToken.refreshToken
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                }
            }
        }.resume()
    }

    func logOutUser() {
        // PKCE
        let keychain = Keychain(service: keychainAppBundleId)
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        let currRefreshToken = keychain["refresh_token"]
        if currRefreshToken == nil {
            return
        }
        let postData = NSMutableData(data: "grant_type=refresh_token".data(using: String.Encoding.utf8)!)

        postData.append(modelData!.clientId.data(using: String.Encoding.utf8)!)

        postData.append(("&refresh_token=" + currRefreshToken!).data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(url: NSURL(string: "https://" + modelData!.auth0Url + "/logout")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error as Any)
                self.serverError = ServerError(error: error.localizedDescription, errorDescription: error.localizedDescription)
                logger.error("logOutUser", attributes: ["error": self.serverError?.errorDescription])
                DispatchQueue.main.async {
                    self.modelData?.networkAPIError = true
                    self.modelData?.networkManager.serverError = self.serverError
                }
            } else {
                if let data = data {
                    let serverReturnString = String(decoding: data, as: UTF8.self)
                    print("Logout = " + serverReturnString)
                    DispatchQueue.main.async {
                        self.modelData?.isOnboardingComplete = false
                        //self.modelData?.refreshTokenUpdated = true
                        self.modelData?.onboardingStep = 1
                        
                        self.modelData?.networkAPIError = false
                        self.modelData?.networkManager.serverError = nil
                        
                        self.modelData?.ebsMonitor.forceDisconnectFromPeripheral()
                    }
                }
            }
        }.resume()
    }

    func uploadSensorCSVFile(csvFileURL: URL, csvFileName: String) {
        modelData!.csvFileIsUploading = true
        modelData!.networkUploadSuccess = false
        modelData!.networkUploadFailed = false
        modelData!.networkUploadFailedMsg = ""

        let epicoreCloudFileUploadEndpointURL = "https://" + modelData!.epicoreHost + "/api/external/upload"
        
        // Create multipart form data
        var body = Data()
        let boundary = "Boundary-\(UUID().uuidString)"
        let lineBreak = "\r\n"
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Type: text/csv\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(csvFileName + lineBreak + lineBreak)")
        
        let sweatData = try! Data(contentsOf: csvFileURL)
        body.append(sweatData)
        body.append(lineBreak)
        
        body.append(("--\(boundary)--\(lineBreak)").data(using: .utf8)!)
        
        // Write the multipart form data to local data file for uploading in the background
        do {
            try body.write(to: csvFileURL, options: .atomic)
        } catch {
            print("Failed to create/write file")
            print("\(error)")
            logger.error("uploadSensorCSVFile", attributes: ["failed_to_create_write_file": error.localizedDescription])
            return
        }
    
        var fileUploadRequest = URLRequest(url: URL(string: epicoreCloudFileUploadEndpointURL)!)
 
        let keychain = Keychain(service: keychainAppBundleId)
        let token = keychain["access_token"]
        // This is here for debugging - remove for release
        if token == nil {
            logger.error("uploadSensorCSVFile", attributes: ["error": "keychain access_token is nil"])
            return
        }
        let enterpriseAndSiteID = modelData?.enterpriseSiteCode
        let splitCode = enterpriseAndSiteID!.split(separator: "-")
        // This is here for debugging - remove for release
        if splitCode.isEmpty {
            logger.error("uploadSensorCSVFile", attributes: ["error": "Enterprise and site ID not set."])
            return
        }

        fileUploadRequest.httpMethod = "POST"
        fileUploadRequest.setValue("2", forHTTPHeaderField: "api-version")
        fileUploadRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        fileUploadRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        fileUploadRequest.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")
        fileUploadRequest.setValue("selectedUserRoles=[{\"enterprise_id\": \"\(splitCode[0])\",\"role\":\"CH_USER\",\"site_id\": \"\(splitCode[1])\"}]", forHTTPHeaderField: "Cookie")

        // The following code is to support multi-day data downloading from sensor and uploading to cloud.
        if(!(modelData!.sweatDataPreviousDayDownloadingCompleted)) {
            
            // Only upload the file to cloud if the session's user ID and site ID match with the current user information.
            if((modelData!.CH_UserID.prefix(8) == BLEManager.bleSingleton.sweatDataLogSessionUserID) && (modelData!.enterpriseSiteCode == BLEManager.bleSingleton.sweatDataLogSessionSiteID)) {

                let config = URLSessionConfiguration.background(withIdentifier: "epUpload")
                config.allowsCellularAccess = true
                config.isDiscretionary = false

                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                let task = session.uploadTask(with: fileUploadRequest, fromFile: csvFileURL)
                task.resume()
            }
            
            // If no match, remove the file downloaded from sensor.
            else {
                let fm = FileManager.default
                do {
                    if fm.fileExists(atPath: modelData!.sweatDataLogFileURL.path) {
                        // file uploaded so remove it
                        print("Session information not match, removing uploaded CSV file")
                        logger.info("urlSession-removeCSV", attributes: ["fileName" : modelData!.sweatDataLogFileURL])
                        try fm.removeItem(at: modelData!.sweatDataLogFileURL)
                    }
                } catch {
                }
                
                self.modelData!.csvFileIsUploading = false
                self.modelData!.networkUploadSuccess = true

            }

            modelData!.sweatDataPreviousDayDownloadingCompleted = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // After the current day data is downloaded and uploaded to cloud successfully, go ahead to start downloading previous day data.
                self.modelData!.ebsMonitor.scanDeviceData()
            }
        }
        
        else {
            
            // Only upload the file to cloud if the session's user ID and site ID match with the current user information.
            if((modelData!.CH_UserID.prefix(8) == BLEManager.bleSingleton.sweatDataLogSessionUserID) && (modelData!.enterpriseSiteCode == BLEManager.bleSingleton.sweatDataLogSessionSiteID)) {
                
                let config = URLSessionConfiguration.background(withIdentifier: "epUpload")
                config.allowsCellularAccess = true
                config.isDiscretionary = false
                
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                let task = session.uploadTask(with: fileUploadRequest, fromFile: csvFileURL)
                
                task.resume()
            }
            
            // If no match, remove the file downloaded from sensor.
            else {
                let fm = FileManager.default
                do {
                    if fm.fileExists(atPath: modelData!.sweatDataLogFileURL.path) {
                        // file uploaded so remove it
                        print("Session information not match, removing uploaded CSV file")
                        logger.info("urlSession-removeCSV", attributes: ["fileName" : modelData!.sweatDataLogFileURL])
                        try fm.removeItem(at: modelData!.sweatDataLogFileURL)
                    }
                } catch {
                }
                
                self.modelData!.csvFileIsUploading = false
                self.modelData!.networkUploadSuccess = true

            }
            
            modelData!.sweatDataMultiDaySyncWithSensorCompleted = true
            
            modelData!.ebsMonitor.stopDataUploadTimeoutHandler()

            modelData!.syncDate = Date()
            
            print("Data sync end time: " + generateCurrentTimeStamp())
            logger.info("uploadSensorCSVFile", attributes: ["data_sync_end_time": generateCurrentTimeStamp()])

            modelData!.isShareSheetPresented = false
            modelData!.isLongPressShare = false

        }
    }
    
    func isTokenValid() -> Bool {
        let keychain = Keychain(service: keychainAppBundleId)
        
        if let currentToken = keychain["access_token"] {
            
            // Retrieve and save user account information here
            let jwt = try! decode(jwt: currentToken)
            let json = jwt.body
            
            let tokenExpirationTime = json["exp"] as! UInt32
            let currentEpochTime = UInt32(NSDate().timeIntervalSince1970)
            
            // Give an hour as time on the phone might be off without sync with network time.
            if(tokenExpirationTime > (currentEpochTime + 3600)) {
                return true
            }
            else {
                return false
            }
        }
        
        else {
            return false
        }
        
    }

    private func generateCurrentLocalDate () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (formatter.string(from: Date()) as NSString) as String
    }

    private func generateCurrentLocalDateMinus30Days () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var dateComponent = DateComponents()
        dateComponent.day = -29
        //dateComponent.month = 1
        let pastDate = Calendar.current.date(byAdding: dateComponent, to: Date())

        return (formatter.string(from: pastDate!) as NSString) as String
    }

}

extension NetworkManager: URLSessionTaskDelegate, URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        // only remove file if task.response HTTP is 200 - others need retry for file
        // Need to have unique session identifiers so can get file name back to retry upload or remove file if successful
        // Have a AppStorage counter (uploadId) (+1) and add to session identifier ("epUpload" -> "epUpload_%d") in uploadSensorCSVFile.
        // Have a dictionary with key for uploadId. Then can find filename to retry or remove.
        //            if session.configuration.identifier == "epPrevUpload" {
        //                 print("Previous day data sync completed!")
        //             }

        let fm = FileManager.default
        do {
            if fm.fileExists(atPath: modelData!.sweatDataLogFileURL.path) {
                // file uploaded so remove it
                print("Removing uploaded CSV file")
                logger.info("urlSession-removeCSV", attributes: ["didSendBodyData": bytesSent, "totalBytesSent" : totalBytesSent,
                                                       "totalBytesExpectedToSend" : totalBytesExpectedToSend,
                                                       "fileName" : modelData!.sweatDataLogFileURL])
                try fm.removeItem(at: modelData!.sweatDataLogFileURL)
            }
        } catch {
        }
        
        DispatchQueue.main.async {
            self.modelData!.csvFileIsUploading = false
            self.modelData!.networkUploadSuccess = true
        }

        logger.info("urlSession-complete", attributes: ["data_uploading_end_time" : generateCurrentTimeStamp()])

        print("Upload Completed  : \(Int(Float(totalBytesSent) / Float(totalBytesExpectedToSend) * 100))")
        print("Data uploading end time: " + generateCurrentTimeStamp())
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            logger.error("urlSession-error", attributes: ["didCompleteWithError": String(describing: error)])
            print("Download error: %@", String(describing: error))
            DispatchQueue.main.async {
                self.modelData!.csvFileIsUploading = false
                self.modelData!.networkUploadFailed = true
                self.modelData!.networkUploadFailedMsg = String(describing: error)
            }
            return
        }
        
        print("Task finished: %@", task)

        // Check HTTP response and should eventually retry upload if fails.
        // Added this for Datadog logging so can find upload errors
        guard let res = task.response as? HTTPURLResponse else {
            // It should not happen at all
            print("Upload completed with response:\(task.response?.description ?? "undefined")")
            logger.error("uploadSensorCSVFile", attributes: ["error": "Upload completed with response:\(task.response?.description ?? "undefined")"])
            return
        }

        if (200...299).contains(res.statusCode) {
            print("Upload completed successfully. Status code:\(res.statusCode)")
            logger.error("uploadSensorCSVFile", attributes: ["success": "Upload completed successfully. Status code:\(res.statusCode)"])
        }
        else if (400...499).contains(res.statusCode) {
            print("Upload fatal issue. Status code:\(res.statusCode)")
            // Fatal issue, do not retry the upload
            logger.error("uploadSensorCSVFile", attributes: ["error": "Upload fatal issue. Status code:\(res.statusCode)"])
        }
        else if (500...599).contains(res.statusCode) {
            print("Upload issue. Status code:\(res.statusCode)")
            // Schedules a new uploading task for the file
            logger.error("uploadSensorCSVFile", attributes: ["error": "Upload issue. Status code:\(res.statusCode)"])
        }
        else {
            print("Upload completed with status code:\(res.statusCode)")
            logger.error("uploadSensorCSVFile", attributes: ["status": "Upload completed with status code:\(res.statusCode)"])
        }

        modelData!.updateDate = Date()
    }

    func getEnterpriseName(enterpriseId: String) {
        var enterpriseInfo: EnterpriseInfo?
        var components = URLComponents()
        components.scheme = scheme
        components.host = modelData!.epicoreHost
        components.path = "/api/external/onboarding/sites/\(enterpriseId)"
        let url = components.url
        print("url = " + url!.absoluteString)

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("2", forHTTPHeaderField: "api-version")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(modelData!.ch_phone_api_key, forHTTPHeaderField: "ch-phone-api-key")
        if (languageCode == "ja") {
            request.addValue("language=\"ja\"", forHTTPHeaderField: "Cookie")
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let errorCheckString = String(decoding: data, as: UTF8.self)
                print("data = " + errorCheckString)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if errorCheckString.contains("error") {
                        //errorCheckString "{\"message\":\"Site with id CAM1 not found in enterprise EBS\",\"status\":\"info\",\"errorKey\":\"entity_not_found\",\"errorCode\":404}"
                        let decodedResponse = try decoder.decode(EnterpriseNameError.self, from: data)
                        logger.error("getEnterpriseName", attributes: ["error": decodedResponse.message])
                        self.modelData?.networkManager.enterpriseNameErr = decodedResponse
                        DispatchQueue.main.async {
                            self.modelData?.enterpriseNameAvailable = 1
                            self.modelData?.networkAPIError = true
                        }
                    }
                    else {
                        // NOTE(tsd): Ignore all errors because will default to just showing ID - API can be down for security reasons
                        let decodedResponse = try decoder.decode(EnterpriseInfo.self, from: data)
                        enterpriseInfo = decodedResponse
                        //print("Enterpise Name: " + (enterpriseInfo?.enterprise.name ?? ""))
                        DispatchQueue.main.async {
                            self.modelData?.CH_SiteName = enterpriseInfo?.name ?? ""
                            self.modelData?.CH_EnterpriseName = enterpriseInfo?.enterprise.name ?? ""
                            self.modelData?.enterpriseNameAvailable = 1
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                    DispatchQueue.main.async {
                        self.modelData?.enterpriseNameAvailable = 1
                    }
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    DispatchQueue.main.async {
                        self.modelData?.enterpriseNameAvailable = 1
                    }
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    DispatchQueue.main.async {
                        self.modelData?.enterpriseNameAvailable = 1
                    }
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    DispatchQueue.main.async {
                        self.modelData?.enterpriseNameAvailable = 1
                    }
                } catch {
                    print("error: ", error)
                    DispatchQueue.main.async {
                        self.modelData?.enterpriseNameAvailable = 1
                    }
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                var serverError = ServerError()
                serverError.error = error.localizedDescription
                serverError.errorDescription = error.localizedDescription
                logger.error("getEnterpriseName", attributes: ["HTTP request failed": error.localizedDescription])
                self.modelData?.networkManager.serverError = serverError
                DispatchQueue.main.async {
                    self.modelData?.enterpriseNameAvailable = 1
                }
            }
            
        }.resume()
    }

}
