//
//  BottleData.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 2/7/23.
//

import Foundation
import SwiftUI

struct BottleData: Hashable, Codable, Identifiable {
    
    var id: Int                     // Bottle Id
    var name: String                // Name of bottle to display
    var sodiumAmount: Float           // Sodium amount in drink
    var sodiumSize: String          // Sodium amount metrics
    var waterAmount: Float         // Water amount in drink
    var waterSize: String           // Water amount metrics
    var barcode: String             // Product barcode
    var imageName: String           // Name of image asset to load
    
    init() {
        id = 0
        name = ""
        sodiumAmount = 0
        waterAmount = 0
        imageName = ""
        barcode = ""
        sodiumSize  = ""
        waterSize = ""
    }
    
    init(id: Int, name: String, imageName: String, barcode: String, sodiumAmount: Float, sodiumSize: String, waterAmount: Float, waterSize: String) {
        self.id = id
        self.name = name
        self.sodiumAmount = sodiumAmount
        self.waterAmount = waterAmount
        self.imageName = imageName
        self.barcode = barcode
        self.sodiumSize  = sodiumSize
        self.waterSize = waterSize
    }
}
