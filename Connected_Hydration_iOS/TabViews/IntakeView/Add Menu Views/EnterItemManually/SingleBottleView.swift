//
//  SingleBottleView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/21/23.
//

import SwiftUI

struct SingleBottleView: View {

    @EnvironmentObject var modelData: ModelData

    @Binding var name: String
    @Binding var waterAmount: String
    @Binding var waterSize: String
    @Binding var sodiumAmount: String
    @Binding var sodiumSize: String
    @Binding var image: String

    var body: some View {
        var color = chHydrationColors.waterQuarter

        let sodiumAmountInt = Int(sodiumAmount) ?? 0
        let waterAmountInt = Int(waterAmount) ?? 0

        if sodiumAmountInt <= 0 && waterAmountInt > 0 {
            color = chHydrationColors.waterFull
        }
        else if sodiumAmountInt > 0 && waterAmountInt <= 0 {
            color = chHydrationColors.sodiumFull
        }
        if sodiumAmountInt > waterAmountInt {
            if sodiumAmountInt > 500 {
                color = chHydrationColors.sodiumHalf
            }
            else {
                color = chHydrationColors.sodiumQuarter
            }
        }
        else {
            if waterAmountInt > 500 {
                color = chHydrationColors.waterHalf
            }
            else {
                color = chHydrationColors.waterQuarter
            }
        }

        let drinkBackgroundView = RoundedRectangle(cornerRadius: 10).fill(Color(hex: color))
            .frame(width: 100, height: 100)

        return VStack {
            ZStack {
                drinkBackgroundView
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .opacity(0.4)
                VStack {
                    Text(sodiumAmount.isEmpty ? "" : sodiumAmount + " " + sodiumSize)
                        .font(.custom("Roboto-Regular", size: 16))
                        .foregroundColor(.white)
                        .bold()
                    Text(waterAmount.isEmpty ? "" : waterAmount + " " + waterSize)
                        .font(.custom("Roboto-Regular", size: 18))
                        .foregroundColor(.white)
                        .bold()
                }
            }

            Text(name)
        }
    }
}
