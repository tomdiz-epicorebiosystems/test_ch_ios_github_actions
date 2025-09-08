//
//  ModelData_Tests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class ModelDataTest: XCTestCase {
 
    var modelData: ModelData!

    override func setUp() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        modelData = ModelData()
    }

    func testModelDataInitialized() {
        XCTAssertNotNil(modelData.pairedCHDevice)
        XCTAssertEqual(modelData.pairedCHDevice.name, "CH100002")

        XCTAssertEqual(modelData.epicoreHost, "ch.epicorebiosystems.com")
        XCTAssertEqual(modelData.ch_phone_api_jwt_secret, "utbc_23p98Zb")
        XCTAssertEqual(modelData.ch_phone_api_key, "q3m7rvCPykvr3_4")
        XCTAssertEqual(modelData.clientId, "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT")
        XCTAssertEqual(modelData.auth0Url, "auth.ch.epicorebiosystems.com")

        XCTAssertEqual(modelData.bottles.count, 449)
        XCTAssertEqual(modelData.bottle_list.count, 62)
        XCTAssertEqual(modelData.bottlePreviewIcons.count, 31)

        XCTAssertEqual(modelData.currentUserIntakeItems.count, 0)
        XCTAssertEqual(modelData.currentBottleCounts.isEmpty, true)
        XCTAssertEqual(modelData.currentBottleListSelections.isEmpty, true)
        XCTAssertEqual(modelData.CHDeviceArray.count, 0)

        XCTAssertNotNil(modelData.ebsMonitor)
        XCTAssertNotNil(modelData.networkManager)
        XCTAssertNotNil(modelData.userPrefsData)

        XCTAssertEqual(modelData.chDeviceBatteryLvl, 70)
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 0)

        XCTAssertNil(modelData.syncDate)
        XCTAssertNil(modelData.updateDate)

        XCTAssertEqual(modelData.CH_FluidBottleSizeInMl, 500.0)
        XCTAssertEqual(modelData.CH_SodiumPackSizeInMg, 220)
    }

    func testSearchFirstBottleDataBarCodes() {
        let result1 = modelData.searchFirstBottleDataBarCodes(barcode: "786162003515")
        XCTAssertEqual(result1, 447)

        let result2 = modelData.searchFirstBottleDataBarCodes(barcode: "786162080004")
        XCTAssertEqual(result2, 431)

        let result3 = modelData.searchFirstBottleDataBarCodes(barcode: "075880166122")
        XCTAssertEqual(result3, 387)

        let result4 = modelData.searchFirstBottleDataBarCodes(barcode: "889392010381")
        XCTAssertEqual(result4, 77)
    }
    
    func testSearchSecondBottleDataBarCodes() {
        let result = modelData.searchSecondBottleDataBarCodes(barcode: "")
        XCTAssertEqual(result, 0)
    }
    
    func testSearchBottleDataNames() {
        let result1 = modelData.searchBottleDataNames(name: "Vitamin Water Zero XXX 16.9oz")
        XCTAssertEqual(result1, 447)

        let result2 = modelData.searchBottleDataNames(name: "Uptime Zero Sugar Sweet Melon 12oz")
        XCTAssertEqual(result2, 427)
    }
    
    func testGetTotalBottles() {
        let result = modelData.getTotalBottles()
        XCTAssertEqual(result.count, 449)
    }
    
    func testBottleInMenu() {
        modelData.currentBottleMenuItems = [BottleData(id: 0, name: "temp", imageName: "temp", barcode: "123", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"), BottleData(id: 0, name: "temp", imageName: "temp", barcode: "456", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"), BottleData(id: 0, name: "temp", imageName: "temp", barcode: "789", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9")]
        let result = modelData.bottleInMenu(barcode: "456")
        XCTAssertTrue(result)
    }
    
    func testGetTotalPresetBottles() {
        let result = modelData.getTotalPresetBottles()
        XCTAssertEqual(result.count, 62)
    }

    func testAddIntakeBottle() {
        modelData.addIntakeBottle(bottle: BottleData(id: 0, name: "temp", imageName: "temp", barcode: "123", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 1)
        XCTAssertEqual(modelData.currentUserIntakeItems[0].barcode, "123")
        XCTAssertEqual(intakeTabGlobalState, IntakeTabState.intakeSave)
    }

    func testRemoveIntakeBottle() {
        modelData.addIntakeBottle(bottle: BottleData(id: 0, name: "temp1", imageName: "temp", barcode: "123", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))

        XCTAssertEqual(intakeTabGlobalState, IntakeTabState.intakeSave)
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 1)
        XCTAssertEqual(modelData.currentBottleCounts.count, 1)
        XCTAssertEqual(modelData.currentBottleCounts.values.contains("1"), true)

        // Test intake same bottle id - ups bottle count and not array of unique bottles
        modelData.addIntakeBottle(bottle: BottleData(id: 0, name: "temp2", imageName: "temp", barcode: "456", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))

        XCTAssertEqual(modelData.currentBottleCounts.values.contains("2"), true)
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 1)

        // Test unique bottle id for insert
        modelData.addIntakeBottle(bottle: BottleData(id: 1, name: "temp3", imageName: "temp", barcode: "789", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))
        
        XCTAssertEqual(intakeTabGlobalState, IntakeTabState.intakeSave)
        XCTAssertEqual(modelData.currentBottleCounts.values.contains("2"), true)
        XCTAssertEqual(modelData.currentBottleCounts.values.contains("1"), true)
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 2)

        // Remove bottle id 1 and verify still 2 with id 0
        modelData.removeIntakeBottle(bottle: BottleData(id: 1, name: "temp2", imageName: "temp", barcode: "456", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))

        XCTAssertEqual(modelData.currentBottleCounts.values.contains("2"), true)
        XCTAssertEqual(modelData.currentBottleCounts.values.contains("1"), false)
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 1)

        modelData.removeIntakeBottle(bottle: BottleData(id: 0, name: "temp1", imageName: "temp", barcode: "123", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))

        XCTAssertEqual(modelData.currentBottleCounts.values.contains("2"), false)
        XCTAssertEqual(modelData.currentBottleCounts.values.contains("1"), true)
        XCTAssertEqual(modelData.currentUserIntakeItems.count, 1)
        // Make sure last bottle is correct
        XCTAssertEqual(modelData.currentUserIntakeItems[0].barcode, "123")

        modelData.removeIntakeBottle(bottle: BottleData(id: 0, name: "temp1", imageName: "temp", barcode: "123", sodiumAmount: 0.0, sodiumSize: "oz", waterAmount: 0.0, waterSize: "16.9"))

        XCTAssertEqual(modelData.currentUserIntakeItems.count, 0)
        XCTAssertEqual(modelData.currentBottleCounts.isEmpty, true)

        print("modelData.currentBottleCounts = \(modelData.currentBottleCounts)")

        // make currentUserIntakeItems.count = 0 and test for intakeClose
        print("modelData.currentBottleCounts = \(modelData.currentBottleCounts)")
    }

    func testAddMenuBottles() {
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 4), false)
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 0)
        XCTAssertEqual(modelData.userTotalBottleMenuItems, -1)

        modelData.manualUserBottle.name = "test_1"
        modelData.waterAmountEnterManual = "16"
        modelData.sodiumAmountEnterManual = "500"
        modelData.addNewUserBottleMenuItem()
        
        XCTAssertEqual(modelData.newUserBottle.id, 0)
        XCTAssertEqual(modelData.newUserBottle.name, "")
        XCTAssertEqual(modelData.userTotalBottleMenuItems, 0)
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 1)
        XCTAssertEqual(modelData.currentBottleMenuItems[0].name, "test_1")
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 4), false)
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 100000 + (modelData.userTotalBottleMenuItems - 1)), true)

        // Test reloading of data from user defaults storage
        modelData.loadUserBottleMenuItems()

        XCTAssertEqual(modelData.newUserBottle.id, 0)
        XCTAssertEqual(modelData.newUserBottle.name, "")
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 1)
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 100000 + (modelData.userTotalBottleMenuItems - 1)), true)

        modelData.deleteUserBottleMenuItem(id: 100000 + (modelData.userTotalBottleMenuItems - 1))

        XCTAssertEqual(modelData.currentBottleMenuItems.count, 0)
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 100000 + (modelData.userTotalBottleMenuItems - 1)), false)
    }

    //addSelectedBottlesMenuItem
    //currentBottleListSelections
    func testAddSelectedBottlesMenuItem() {
        XCTAssertEqual(modelData.bottleAlreadyExistInList(id: 4), false)
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 0)
        XCTAssertEqual(modelData.userTotalBottleMenuItems, -1)

        modelData.currentBottleListSelections = [0 : "1" , 1 : "2"]
        
        modelData.addSelectedBottlesMenuItem()

        // There is no 0 bottle id, so only 1 should be added to
        modelData.loadUserBottleMenuItems()
        
        XCTAssertEqual(modelData.currentBottleMenuItems.count, 1)
    }
}
