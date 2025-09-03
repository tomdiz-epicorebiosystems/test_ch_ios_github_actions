//
//  BottleRow.swift
//  BottleScanner
//
//  Created by Thomas DiZoglio on 2/7/23.
//

import SwiftUI

struct BottleRow: View {
    
    var bottle: BottleData
    @EnvironmentObject var modelData: ModelData
    @State private var selectedColor = Color.white

    @State private var totalWaterAmount = 0.0
    @State private var totalSodiumAmount = 0.0

    @State private var showBottleModifierPopover: BottleModifierData?
    @State private var bottleViewRect = CGRect.zero

    var body: some View {
        HStack {
            BottleListRenderView(totalWaterAmount: $totalWaterAmount, totalSodiumAmount: $totalSodiumAmount, showBottleModifierPopover: $showBottleModifierPopover, bottle: bottle, showName: false)
            
                VStack(alignment: .leading, spacing: 2) {
                    Text(bottle.name)
                        .font(.custom("Jost-Regular", size: 20))
                    Text(bottle.sodiumAmount == 0 ? "" : String(localized:"Sodium") + ": " + String(format: "%.1f", modelData.userPrefsData.handleUserSodiumConversion(mg: Double(bottle.sodiumAmount))) + " " + modelData.userPrefsData.getUserSodiumUnitString())
                        .font(.custom("JostRoman-Light", size: 16))
                    Text(bottle.waterAmount == 0 ? "" : String(localized:"Water") + ": " + String(format: "%.1f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(bottle.waterAmount))) + " " + modelData.userPrefsData.getUserSweatUnitString())
                        .font(.custom("JostRoman-Light", size: 16))
                }
                
                Spacer()
        }
        .listRowBackground(selectedColor)
        .onTapGesture {
            if selectedColor == Color.white {
                selectedColor = Color("Button Select Color")

                if modelData.currentBottleListSelections.count < 1 {
                    intakeTabGlobalState = .intakeAdd
                    updateIntakeTabState()
                    modelData.globalIntakeButtonChanged = true
                }

                modelData.currentBottleListSelections[bottle.id] = "1"
                
                if modelData.currentBottleListSelections.count == 1 {
                    let bottleName = bottle.name
                    let imageName = bottle.imageName
                    let sodiumAmount = bottle.sodiumAmount
                    let sodiumSize = bottle.sodiumSize
                    let waterAmount = bottle.waterAmount
                    let waterSize = bottle.waterSize
                    let barcode = bottle.barcode
                    print("Bottle name = \(bottleName)")
                    modelData.newUserBottle = BottleData(id: 0, name: bottleName, imageName: imageName, barcode: barcode, sodiumAmount: sodiumAmount, sodiumSize: sodiumSize, waterAmount: waterAmount, waterSize: waterSize)
                }
            }
            else {
                selectedColor = Color.white

                let keyExists = modelData.currentBottleListSelections[bottle.id] != nil
                if keyExists {
                    modelData.currentBottleListSelections.removeValue(forKey: bottle.id)
                }

                if modelData.currentBottleListSelections.isEmpty {
                    intakeTabGlobalState = .intakeCancel
                    updateIntakeTabState()
                    modelData.globalIntakeButtonChanged = true
                }
            }
        }
    }
}

struct BottleListRenderView: View {

    @EnvironmentObject var modelData: ModelData

    @Binding var totalWaterAmount: Double
    @Binding var totalSodiumAmount: Double

    @Binding var showBottleModifierPopover: BottleModifierData?

    var bottle: BottleData
    var showName: Bool

    var body: some View {
        var color = chHydrationColors.waterQuarter

        if bottle.sodiumAmount <= 0 && bottle.waterAmount > 0 {
            color = chHydrationColors.waterFull
        }
        else if bottle.sodiumAmount > 0 && bottle.waterAmount <= 0 {
            color = chHydrationColors.sodiumFull
        }
        if bottle.sodiumAmount > bottle.waterAmount {
            if bottle.sodiumAmount > 500 {
                color = chHydrationColors.sodiumHalf
            }
            else {
                color = chHydrationColors.sodiumQuarter
            }
        }
        else {
            if bottle.waterAmount > 500 {
                color = chHydrationColors.waterHalf
            }
            else {
                color = chHydrationColors.waterQuarter
            }
        }

        let drinkBackgroundView = RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                .frame(width: 80, height: 100)

        return VStack {
            ZStack {
                drinkBackgroundView
                Image(bottle.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .opacity(0.4)
                VStack {
                    Text(bottle.sodiumAmount == 0 ? "" : String(format: "%.1f", modelData.userPrefsData.handleUserSodiumConversion(mg: Double(bottle.sodiumAmount))) + " " + modelData.userPrefsData.getUserSodiumUnitString())
                        .font(.custom("Roboto-Regular", size: 13))
                        .foregroundColor(.white)
                        .bold()
                    Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", modelData.userPrefsData.handleUserSweatConversion(ml: Double(bottle.waterAmount))) + " " + modelData.userPrefsData.getUserSweatUnitString())
                        .font(.custom("Roboto-Regular", size: 17))
                        .foregroundColor(.white)
                        .bold()
                }

                let keyExists = modelData.currentBottleCounts[bottle.id] != nil
                if keyExists {
                    let count = (modelData.currentBottleCounts[bottle.id]) ?? "0"
                    if count != "1" {
                        Text(count)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.white)
                            .background(Color(hex: generalCHAppColors.intakeBottleIconStandardText))
                            .clipShape(Circle())
                            .offset(x: 25, y: -35)
                    }
                }
            }

            if showName == true {
                Text(bottle.name)
                    .frame(width: 100)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.custom("Roboto-Regular", size: 12))
            }
        }
    }
}
