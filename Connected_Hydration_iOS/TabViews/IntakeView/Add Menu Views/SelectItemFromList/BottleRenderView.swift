//
//  BottleRenderView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/22/23.
//

import SwiftUI

struct BottleRenderView: View {

    @EnvironmentObject var modelData: ModelData

    @Binding var totalWaterAmount: Double
    @Binding var totalSodiumAmount: Double
    @Binding var showBottleModifierPopover: BottleModifierData?
    @Binding var bottleViewRect: CGRect

    @State var color: String = ""
    @State var longPressLocation: CGPoint = CGPoint.zero

    @State private var isOutlined = false
    @State private var isHidden = true
    @State private var isOutlinedOnce = false

    private let heightBottleIcon = 175.0

    var bottle: BottleData
    var showName: Bool
    var isIntake: Bool
    var isAllowHitTest: Bool

    var body: some View {
        if isHidden == true {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        if isIntake == true {
                            RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                .frame(width: 80, height: 100)
                        }
                        else {
                            RoundedRectangle(cornerRadius: 7).fill(Color(hex: chHydrationColors.waterFull))
                                .frame(width: 120, height: 120)
                            RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                .frame(width: 100, height: 100)
                        }
                        
                        Image(bottle.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .opacity(0.4)
                        
                        VStack {
                            if modelData.unitsChanged == "1" {
                                Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                    .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                    .foregroundColor(.white)
                                    .bold()
                                Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", bottle.waterAmount / 29.574) + " " + "oz")
                                    .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            else {
                                Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", round(bottle.waterAmount)) + " " + bottle.waterSize)
                                    .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                    .foregroundColor(.white)
                                    .bold()
                                Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                    .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }
                        
                        if isIntake == true {
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
                                .font(.custom("Roboto-Regular", size: isIntake == true ? 12 : (bottle.name.count > 30) ? 12 : 14))
                                .hidden()
                        }
                    }
                    .onAppear() {
                        if isIntake == false && isOutlinedOnce == false {
                            for id in modelData.newBottlesAdded {
                                if id == bottle.id {
                                    isOutlined = true
                                }
                            }
                        }
                        
                        isHidden = false
                    }
                }
                .frame(height: isIntake ? heightBottleIcon-15 : heightBottleIcon)
                .aspectRatio(0.7, contentMode: .fill)
            }
        }
        else {
            if isOutlined == true {
                GeometryReader { geometry in
                    VStack {
                        ZStack {
                            if isIntake == true {
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                    .frame(width: 80, height: 100)
                            }
                            else {
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: chHydrationColors.waterFull))
                                    .frame(width: 120, height: 120)
                                    .glow()
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                    .frame(width: 100, height: 100)
                            }
                            
                            Image(bottle.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .opacity(0.4)
                            
                            VStack {
                                if modelData.unitsChanged == "1" {
                                    Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", bottle.waterAmount / 29.574) + " " + "oz")
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                else {
                                    Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", round(bottle.waterAmount)) + " " + bottle.waterSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            }
                            
                            if isIntake == true {
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
                        }
                        .padding(4)
                        .onTapGesture {
                            if isIntake == false {
                                modelData.addIntakeBottle(bottle: bottle)
                                totalWaterAmount += Double(bottle.waterAmount)
                                totalSodiumAmount += Double(bottle.sodiumAmount)
                            }
                        }
                        .gesture(LongPressGesture(minimumDuration: 1).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                            .onEnded { value in
                                if isIntake == false {
                                    //print("Long Press Action")
                                    switch value {
                                    case .second(true, let drag):
                                        longPressLocation = drag?.location ?? .zero
                                    default:
                                        break
                                    }
                                    bottleViewRect = geometry.frame(in: CoordinateSpace.global)
                                    //print("bottleViewRect = \(bottleViewRect)")
                                    //print("longPressLocation = \(longPressLocation)")
                                    if longPressLocation.x > UIScreen.main.bounds.width - 20 {
                                        print("Too close to edge of screen to open")
                                        return
                                    }
                                    showBottleModifierPopover = BottleModifierData(type: .fractional, bottle: bottle)
                                }
                            })
                        .allowsHitTesting(isAllowHitTest)
                        
                        if showName == true {
                            Text(bottle.name)
                                .padding(.top, -20)
                                .frame(width: 100)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.custom("Roboto-Regular", size: isIntake == true ? 12 : (bottle.name.count > 30) ? 12 : 14))
                        }
                    }
                    .onAppear() {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            isOutlined = false
                            isOutlinedOnce = true
                        }
                        
                        color = chHydrationColors.waterQuarter
                        
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
                    }
                }
                .frame(height: isIntake ? heightBottleIcon-15 : heightBottleIcon)
                .aspectRatio(0.7, contentMode: .fill)
            }
            else {
                GeometryReader { geometry in
                    VStack {
                        ZStack {
                            if isIntake == true {
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                    .frame(width: 80, height: 100)
                            }
                            else {
                                RoundedRectangle(cornerRadius: 7).fill(.clear)
                                    .frame(width: 120, height: 120)
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: color))
                                    .frame(width: 100, height: 100)
                            }
                            Image(bottle.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .opacity(0.4)
                            VStack {
                                if modelData.unitsChanged == "1" {
                                    Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", bottle.waterAmount / 29.574) + " " + "oz")
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                else {
                                    Text(bottle.waterAmount == 0 ? "" : String(format: "%.1f", round(bottle.waterAmount)) + " " + bottle.waterSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 17 : 20))
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(bottle.sodiumAmount == 0 ? "" : String(bottle.sodiumAmount) + " " + bottle.sodiumSize)
                                        .font(.custom("Roboto-Regular", size: isIntake == true ? 13 : 16))
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            }
                            
                            if isIntake == true {
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
                        }
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            if isIntake == false {
                                modelData.addIntakeBottle(bottle: bottle)
                                totalWaterAmount += Double(bottle.waterAmount)
                                totalSodiumAmount += Double(bottle.sodiumAmount)
                            }
                        }
                        .gesture(LongPressGesture(minimumDuration: 1).sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                            .onEnded { value in
                                if isIntake == false {
                                    //print("Long Press Action")
                                    switch value {
                                    case .second(true, let drag):
                                        longPressLocation = drag?.location ?? .zero
                                    default:
                                        break
                                    }
                                    bottleViewRect = geometry.frame(in: CoordinateSpace.global)
                                    //print("bottleViewRect = \(bottleViewRect)")
                                    //print("longPressLocation = \(longPressLocation)")
                                    if longPressLocation.x > UIScreen.main.bounds.width - 20 {
                                        print("Too close to edge of screen to open")
                                        return
                                    }
                                    showBottleModifierPopover = BottleModifierData(type: .fractional, bottle: bottle)
                                }
                            })
                        .allowsHitTesting(isAllowHitTest)
                        
                        if showName == true {
                            Text(bottle.name)
                                .padding(.top, isIntake == true ? -10 : -20)
                                .frame(width: 100)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.custom("Roboto-Regular", size: isIntake == true ? 12 : (bottle.name.count > 30) ? 12 : 14))
                        }
                    }
                    .onAppear() {
                        
                        // See if need to outline bottle
                        if isIntake == false && isOutlinedOnce == false {
                            for id in modelData.newBottlesAdded {
                                if id == bottle.id {
                                    isOutlined = true
                                }
                            }
                        }
                        
                        color = chHydrationColors.waterQuarter
                        
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
                    }
                }
                .frame(height: isIntake ? heightBottleIcon-15 : heightBottleIcon)
                .aspectRatio(0.7, contentMode: .fill)
            }
        }
    }
}

struct Glow: ViewModifier {
    @State private var glow = false
    @State private var glow2 = true

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: glow ? 45 : 15) // 3:59
                .scaleEffect(glow2 ? 1.0 : 0)
                .animation(glow2 == false ? .easeIn(duration: 1.0) : .easeOut(duration: 1.0).repeatForever(autoreverses: true), value: 1.0)
                .onAppear() {
                    glow.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        glow2 = false
                    }
                }
        }
    }
}

extension View {
    func glow() -> some View {
        modifier(Glow())
    }
}
