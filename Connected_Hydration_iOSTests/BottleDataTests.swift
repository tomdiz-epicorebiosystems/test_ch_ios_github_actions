//
//  BottleDataTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class BottleDataTests: XCTestCase {
    
    func testInit() {
        let bottleData = BottleData()
        
        XCTAssertEqual(bottleData.id, 0)
        XCTAssertEqual(bottleData.name, "")
        XCTAssertEqual(bottleData.sodiumAmount, 0)
        XCTAssertEqual(bottleData.sodiumSize, "")
        XCTAssertEqual(bottleData.waterAmount, 0)
        XCTAssertEqual(bottleData.waterSize, "")
        XCTAssertEqual(bottleData.barcode, "")
        XCTAssertEqual(bottleData.imageName, "")
    }
    
    func testInitWithValues() {
        let bottleData = BottleData(id: 1, name: "Test Bottle", imageName: "testImage", barcode: "123456789", sodiumAmount: 100.0, sodiumSize: "mg", waterAmount: 200.0, waterSize: "ml")
        
        XCTAssertEqual(bottleData.id, 1)
        XCTAssertEqual(bottleData.name, "Test Bottle")
        XCTAssertEqual(bottleData.sodiumAmount, 100.0)
        XCTAssertEqual(bottleData.sodiumSize, "mg")
        XCTAssertEqual(bottleData.waterAmount, 200.0)
        XCTAssertEqual(bottleData.waterSize, "ml")
        XCTAssertEqual(bottleData.barcode, "123456789")
        XCTAssertEqual(bottleData.imageName, "testImage")
    }
    
    func testHashable() {
        let bottle1 = BottleData(id: 1, name: "Bottle A", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        let bottle2 = BottleData(id: 2, name: "Bottle B", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        let set: Set<BottleData> = [bottle1, bottle2]
        
        XCTAssertEqual(set.count, 2)
    }
    
    func testCodable() {
        let bottleData = BottleData(id: 1, name: "Test Bottle", imageName: "testImage", barcode: "123456789", sodiumAmount: 100.0, sodiumSize: "mg", waterAmount: 200.0, waterSize: "ml")
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        if let encodedData = try? encoder.encode(bottleData),
           let decodedBottleData = try? decoder.decode(BottleData.self, from: encodedData) {
            
            XCTAssertEqual(decodedBottleData.id, bottleData.id)
            XCTAssertEqual(decodedBottleData.name, bottleData.name)
            XCTAssertEqual(decodedBottleData.sodiumAmount, bottleData.sodiumAmount)
            XCTAssertEqual(decodedBottleData.sodiumSize, bottleData.sodiumSize)
            XCTAssertEqual(decodedBottleData.waterAmount, bottleData.waterAmount)
            XCTAssertEqual(decodedBottleData.waterSize, bottleData.waterSize)
            XCTAssertEqual(decodedBottleData.barcode, bottleData.barcode)
            XCTAssertEqual(decodedBottleData.imageName, bottleData.imageName)
        } else {
            XCTFail("Failed to encode/decode Bottle Data")
        }
    }
    
    func testIdentifiable() {
        let bottle1 = BottleData(id: 1, name: "Test Bottle 1", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        let bottle2 = BottleData(id: 2, name: "Test Bottle 2", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        XCTAssertEqual(bottle1.id, 1)
        XCTAssertEqual(bottle2.id, 2)
    }
    
    func testHashableEquality() {
        let bottle1 = BottleData(id: 1, name: "Bottle A", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        let bottle2 = BottleData(id: 1, name: "Bottle B", imageName: "", barcode: "", sodiumAmount: 0.0, sodiumSize: "", waterAmount: 0.0, waterSize: "")
        
        XCTAssertNotEqual(bottle1.hashValue, bottle2.hashValue)
    }
}
