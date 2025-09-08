//
//  NetworkManagerTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }

    func testSendCode() {
        let expectation = XCTestExpectation(description: "Send code")
        
        networkManager.modelData = ModelData()
        networkManager.modelData?.epicoreHost = "example.com"
        networkManager.modelData?.ch_phone_api_key = "API_KEY"
        
        networkManager.sendCode(email: "test@example.com", enterpriseCode: "1234")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotNil(self.networkManager.sendCode)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testDecodeServerError() {
        let serverErrorData = """
        {
            "error": "error",
            "errorDescription": "description"
        }
        """.data(using: .utf8)!
        
        let decodedServerError = try? JSONDecoder().decode(ServerError.self, from: serverErrorData)
        
        XCTAssertNotNil(decodedServerError)
        XCTAssertEqual(decodedServerError?.error, "error")
        XCTAssertEqual(decodedServerError?.errorDescription, "description")
    }
    
    func testDecodeSendCodeServerError() {
        let sendCodeServerErrorData = """
        {
            "error": true,
            "message": "message"
        }
        """.data(using: .utf8)!
        
        let decodedSendCodeServerError = try? JSONDecoder().decode(SendCodeServerError.self, from: sendCodeServerErrorData)
        
        XCTAssertNotNil(decodedSendCodeServerError)
        XCTAssertEqual(decodedSendCodeServerError?.error, true)
        XCTAssertEqual(decodedSendCodeServerError?.message, "message")
    }
    
    func testEncodeUpdateRefreshToken() {
        let updateRefreshToken = UpdateRefreshToken(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", scope: "scope", expiresIn: 3600, tokenType: "tokenType")
        
        let encodedUpdateRefreshToken = try? JSONEncoder().encode(updateRefreshToken)
        
        XCTAssertNotNil(encodedUpdateRefreshToken)
    }
    
    func testDecodeAvgSweatVolumeSodiumConcentration() {
        let avgSweatVolumeSodiumConcentrationData = """
        {
            "status": "status",
            "data": {
                "sweatVolumeMl": 100.0,
                "sodiumConcentrationMm": 10.0
            }
        }
        """.data(using: .utf8)!
        
        let decodedAvgSweatVolumeSodiumConcentration = try? JSONDecoder().decode(AvgSweatVolumeSodiumConcentration.self, from: avgSweatVolumeSodiumConcentrationData)
        
        XCTAssertNotNil(decodedAvgSweatVolumeSodiumConcentration)
        XCTAssertEqual(decodedAvgSweatVolumeSodiumConcentration?.status, "status")
        XCTAssertEqual(decodedAvgSweatVolumeSodiumConcentration?.data.sweatVolumeMl, 100.0)
        XCTAssertEqual(decodedAvgSweatVolumeSodiumConcentration?.data.sodiumConcentrationMm, 10.0)
    }

    func testAuthenicateWithCode() {
        // Given
        let email = "test@example.com"
        let verificationCode = "123456"

        networkManager.modelData = ModelData()
        networkManager.modelData?.epicoreHost = "example.com"

        // When
        networkManager.AuthenicateWithCode(email: email, verificationCode: verificationCode)
        
        // Then
        // Add assertions here to verify the expected behavior
    }
    
    func testGetListOfSites() {
        // Given
        let email = "test@example.com"
        let enterpriseId = "123"
        let siteId = "456"
        
        networkManager.modelData = ModelData()
        networkManager.modelData?.epicoreHost = "example.com"

        // When
        networkManager.GetListOfSites(email: email, enterpriseId: enterpriseId, siteId: siteId)
        
        // Then
        // Add assertions here to verify the expected behavior
    }
    
    func testUpdateUser() {
        // Given
        let enterpriseId = "123"
        let siteId = "456"
        
        let userInfo: [String: Any] = [
            "firstName": "John",
            "lastName": "Doe",
            "height": 180,
            "weight": 75,
            "biologicalSex": "Male"
            // Add more properties as needed for testing
        ]

        networkManager.modelData = ModelData()
        networkManager.modelData?.epicoreHost = "example.com"

       // When
       networkManager.updateUser(enterpriseId: enterpriseId, siteId: siteId, userInfo: userInfo)
       
       // Then
       // Add assertions here to verify the expected behavior
   }
   
   func testGetNewRefreshToken() {
       networkManager.modelData = ModelData()
       networkManager.modelData?.clientId = "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT"

       // When
       networkManager.getNewRefreshToken()
       
       // Then
       // Add assertions here to verify the expected behavior
   }
   
   func testLogOutUser() {
       networkManager.modelData = ModelData()
       networkManager.modelData?.clientId = "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT"

       // When
       networkManager.logOutUser()
       
       // Then
       // Add assertions here to verify the expected behavior
   }

}
