//
//  BottleModifierView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 6/19/23.
//

import SwiftUI

public class BottleModifierData {
    public enum BottleModifierType {
        case fractional, delete

        var backgroundColor: Color {
            return .white
        }
    }

    var type: BottleModifierType = .fractional
    var bottleFractionalAmount = BottleData(id: 0, name: "", imageName: initialPreviewBottleName, barcode: "", sodiumAmount: 0, sodiumSize: "mg", waterAmount: 0, waterSize: "oz")

    init(type: BottleModifierType, bottle: BottleData) {
        self.type = type
        self.bottleFractionalAmount = bottle
    }
}

public struct BottleViewModifier: ViewModifier {

    @EnvironmentObject var modelData: ModelData
    @Binding var bottleOptionMenu: BottleModifierData?
    @Binding var bottleViewFrame: CGRect
    @Binding var totalWaterAmount: Double
    @Binding var totalSodiumAmount: Double

    var menuLocation: CGPoint = CGPoint.zero

    public init(model: Binding<BottleModifierData?>, viewRect: Binding<CGRect>, totalWaterAmount: Binding<Double>, totalSodiumAmount: Binding<Double>) {
        _bottleOptionMenu = model
        _totalWaterAmount = totalWaterAmount
        _totalSodiumAmount = totalSodiumAmount
        _bottleViewFrame = viewRect

        // Figure out menu popup location
        menuLocation.x = bottleViewFrame.origin.x + (bottleViewFrame.size.width / 2) + 50
        menuLocation.y = ((bottleViewFrame.size.height * 2) - 95) * -1
        //print("menuLocation = \(menuLocation)")
    }

    public func body(content: Content) -> some View {
        content.overlay(
            VStack {
                if bottleOptionMenu != nil {
                    GeometryReader { geometry in
                        let viewFrame = geometry.frame(in: CoordinateSpace.global)

                        ZStack {
                            // a transparent rectangle under everything. Used to close view
                            Rectangle()
                                .frame(width: geometry.size.width, height: geometry.size.height + 600)
                                .opacity(0.001)
                                .layoutPriority(-1)
                                .onTapGesture {
                                    bottleOptionMenu = nil
                                }

                            VStack {
                                Triangle()
                                    .foregroundColor(Color.white)
                                    .frame(width: 30, height: 25)
                                    .padding(.bottom, -10)
                                    .padding(.trailing, 40)

                                HStack {

                                    Button(action: {
                                        let fractionalBottleWaterAmount = bottleOptionMenu!.bottleFractionalAmount.waterAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.waterAmount * 0.25
                                        let fractionalBottleSodiumAmount = bottleOptionMenu!.bottleFractionalAmount.sodiumAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.sodiumAmount * 0.25
                                        
                                        let newUserFractionalBottle = BottleData(id: UUID().hashValue, name: bottleOptionMenu!.bottleFractionalAmount.name, imageName: bottleOptionMenu!.bottleFractionalAmount.imageName, barcode: "", sodiumAmount: fractionalBottleSodiumAmount, sodiumSize: "mg", waterAmount: fractionalBottleWaterAmount, waterSize: modelData.userPrefsData.getUserSweatUnitString())
                                        modelData.addIntakeBottle(bottle: newUserFractionalBottle)
                                        bottleOptionMenu = nil
                                        totalWaterAmount += Double(fractionalBottleWaterAmount)
                                        totalSodiumAmount += Double(fractionalBottleSodiumAmount)
                                    }) {
                                        Text("+1/4")
                                            .font(.custom("Oswald-Regular", size: 14))
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(hex: generalCHAppColors.intakeFractionalStandardText))
                                    }
                                    .buttonStyle(FractionalButtonStyle())
                                    .trackRUMTapAction(name: "quarter-bottle")

                                    Divider()
                                        .frame(width: 1)
                                        .overlay(Color(UIColor.lightGray))

                                    Button(action: {
                                        let fractionalBottleWaterAmount = bottleOptionMenu!.bottleFractionalAmount.waterAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.waterAmount * 0.50
                                        let fractionalBottleSodiumAmount = bottleOptionMenu!.bottleFractionalAmount.sodiumAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.sodiumAmount * 0.50
                                        
                                        let newUserFractionalBottle = BottleData(id: UUID().hashValue, name: bottleOptionMenu!.bottleFractionalAmount.name, imageName: bottleOptionMenu!.bottleFractionalAmount.imageName, barcode: "", sodiumAmount: fractionalBottleSodiumAmount, sodiumSize: "mg", waterAmount: fractionalBottleWaterAmount, waterSize: modelData.userPrefsData.getUserSweatUnitString())
                                        modelData.addIntakeBottle(bottle: newUserFractionalBottle)
                                        bottleOptionMenu = nil
                                        totalWaterAmount += Double(fractionalBottleWaterAmount)
                                        totalSodiumAmount += Double(fractionalBottleSodiumAmount)
                                  }) {
                                        Text("+1/2")
                                            .font(.custom("Oswald-Regular", size: 14))
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(hex: generalCHAppColors.intakeFractionalStandardText))
                                    }
                                    .buttonStyle(FractionalButtonStyle())
                                    .trackRUMTapAction(name: "half-bottle")

                                    Divider()
                                        .frame(width: 1)
                                        .overlay(Color(UIColor.lightGray))

                                    Button(action: {
                                        let fractionalBottleWaterAmount = bottleOptionMenu!.bottleFractionalAmount.waterAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.waterAmount * 0.75
                                        let fractionalBottleSodiumAmount = bottleOptionMenu!.bottleFractionalAmount.sodiumAmount == 0 ? 0 : bottleOptionMenu!.bottleFractionalAmount.sodiumAmount * 0.75
                                        
                                        let newUserFractionalBottle = BottleData(id: UUID().hashValue, name: bottleOptionMenu!.bottleFractionalAmount.name, imageName: bottleOptionMenu!.bottleFractionalAmount.imageName, barcode: "", sodiumAmount: fractionalBottleSodiumAmount, sodiumSize: "mg", waterAmount: fractionalBottleWaterAmount, waterSize: modelData.userPrefsData.getUserSweatUnitString())
                                        modelData.addIntakeBottle(bottle: newUserFractionalBottle)
                                        bottleOptionMenu = nil
                                        totalWaterAmount += Double(fractionalBottleWaterAmount)
                                        totalSodiumAmount += Double(fractionalBottleSodiumAmount)
                                    }) {
                                        Text("+3/4")
                                            .font(.custom("Oswald-Regular", size: 14))
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(hex: generalCHAppColors.intakeFractionalStandardText))
                                    }
                                    .buttonStyle(FractionalButtonStyle())
                                    .trackRUMTapAction(name: "three_quarter-bottle")

                                    Divider()
                                        .frame(width: 1)
                                        .overlay(Color(UIColor.lightGray))

                                    Button(action: {
                                        modelData.deleteUserBottleMenuItem(id: bottleOptionMenu!.bottleFractionalAmount.id)
                                        bottleOptionMenu = nil
                                    }) {
                                        Image(systemName: "trash")
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(hex: generalCHAppColors.intakeFractionalStandardText))
                                    }
                                    .buttonStyle(FractionalButtonStyle())
                                    .trackRUMTapAction(name: "delete-bottle")

                                }
                                //.onAppear() {
                                //    print("*** viewFrame.origin.x = \(viewFrame.origin.x)")
                                //}
                                .frame(width: 250, height: 50, alignment: .leading)
                                .background(bottleOptionMenu?.type.backgroundColor ?? .clear)
                                .cornerRadius(7)
                                .shadow(radius: 10, y: 15)
                                .foregroundColor(Color(UIColor.lightGray))
                                .offset(x: (viewFrame.origin.x + viewFrame.size.width) > UIScreen.main.bounds.width ? -(((viewFrame.origin.x + viewFrame.size.width) - UIScreen.main.bounds.width) - 110) : viewFrame.origin.x < 0 ? (viewFrame.origin.x * -1) - 10 : 0)
                            }
                        }
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .position(x: menuLocation.x, y: menuLocation.y)
            .animation(.spring(), value: 1.0)
            .trackRUMView(name: "BottleViewModifier")
        )
    }

}

struct FractionalButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .background(configuration.isPressed ? Color(hex:"#BFECF9") : Color(.white))
      .cornerRadius(5)
  }

}
