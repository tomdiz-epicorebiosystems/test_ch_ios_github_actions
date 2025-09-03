//
//  IntakeView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/9/23.
//

import Foundation
import SwiftUI
import BLEManager

struct IntakeView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @Binding var tabSelection: Tab
    @Binding var hideFractionalMenu: Bool

    @State private var recommendedWaterIntakePercentage = 0.0
    @State private var recommendedWaterIntakeDegrees = 0.0
    @State private var recommendedSodiumIntakePercentage = 0.0
    @State private var recommendedSodiumIntakeDegrees = 0.0
    @State private var showBottleModifierPopover: BottleModifierData?
    @State private var bottleViewRect = CGRect.zero
    @State private var showCancel = false

    init(tabSelection: Binding<Tab>, hideFractionalMenu: Binding<Bool>) {
        _tabSelection = tabSelection
        _hideFractionalMenu = hideFractionalMenu
    }

    var body: some View {
        if hideFractionalMenu {
            //print("*** hideFractionalMenu is true")
            DispatchQueue.main.async {
                self.showBottleModifierPopover = nil
                hideFractionalMenu = false
            }
        }
        
        return ZStack {
            VStack {
                HStack {
                    Text("MENU")
                        .font(.custom("Oswald-Bold", size: 18))
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        .padding(.leading, 15)
                    
                    Button(action: {
                        navigate(.push(.intakeAddBottle))
                        intakeTabGlobalState = .intakeCancel
                        updateIntakeTabState()
                        modelData.newBottlesAdded.removeAll()
                        stopTimer()
                    }) {
                        Image(systemName: "plus")
                            .font(Font.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    }
                    .padding(.leading, 10)

                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            logger.info("intakeSaved", attributes: ["intake" : "canceled"])
                            modelData.currentUserIntakeItems.removeAll()
                            modelData.totalWaterAmount = 0
                            modelData.totalSodiumAmount = 0
                            intakeTabGlobalState = .intakeNormal
                            self.tabSelection = .today
                            modelData.newBottlesAdded.removeAll()
                            stopTimer()
                        }
                    }) {
                        if intakeTabGlobalState == .intakeSave || showCancel == true {
                            Text("CANCEL")
                                .font(.custom("Oswald-Regular", size: 18))
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        }
                        else {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        }
                    }
                    .padding(.trailing, 20)
                    
                }
                .padding(.top, 20)
                
                if modelData.currentBottleMenuItems.count == 0 {
                    HStack {
                        Image("Intake - Add Arrow")
                        
                        Text("Tap + above to add to your first preset. Long-press item for additional options.")
                            .font(.custom("Roboto-Regular", size: 16))
                            .foregroundColor(Color(UIColor.darkGray))
                            .padding(.top, 20)
                            .padding(.trailing, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, 60)
                    .padding(.bottom, 20)
                }
                else {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(modelData.currentBottleMenuItems) { bottle in
                                    BottleRenderView(totalWaterAmount: $modelData.totalWaterAmount, totalSodiumAmount: $modelData.totalSodiumAmount, showBottleModifierPopover: $showBottleModifierPopover, bottleViewRect: $bottleViewRect, bottle: bottle, showName: true, isIntake: false, isAllowHitTest: true)
                                        .padding(.bottom, 10)
                                }
                                .onAppear() {
                                    if modelData.newBottlesAdded.count > 0 {
                                        DispatchQueue.main.async {
                                            reader.scrollTo(modelData.currentBottleMenuItems[modelData.currentBottleMenuItems.count - 1].id, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 180)
                        .padding(.trailing, 15)
                    }
                    .background(Color(hex: generalCHAppColors.lightGrayStandardBackground))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, -10)
                }
                
                HStack {
                    Text("INTAKE")
                        .font(.custom("Oswald-Bold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        .padding(.leading, 15)
                        .padding(.top, 10)

                    if Double(modelData.totalWaterAmount) / 29.574 >= 48.0 {
                        Text(modelData.userPrefsData.getUserExceedWarningString())
                            .font(.custom("Roboto-Bold", size: 14))
                            .padding(.top, 5)
                            .padding(.trailing, 5)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.red)
                    }
                }

                if modelData.currentUserIntakeItems.count == 0 {
                    VStack {
                        Text("Tap item above to add to your recent intake.")
                            .font(.custom("Roboto-Regular", size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(UIColor.darkGray))
                        
                        Text("Long-press item for partial amounts.")
                            .font(.custom("Roboto-Regular", size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(UIColor.darkGray))
                            .onAppear() {
                                intakeTabGlobalState = .intakeClose
                                updateIntakeTabState()
                                tabBarView?.setNeedsLayout()
                            }
                        
                    }
                    .frame(height: 145, alignment: .center)
                    .padding(.leading, 5)
                }
                else if modelData.currentUserIntakeItems.count < 2 {
                    HStack(alignment: .top, spacing: 10) {
                        BottleRenderView(totalWaterAmount: $modelData.totalWaterAmount, totalSodiumAmount: $modelData.totalSodiumAmount, showBottleModifierPopover: $showBottleModifierPopover, bottleViewRect: $bottleViewRect, bottle: modelData.currentUserIntakeItems[0], showName: true, isIntake: true, isAllowHitTest: true)
                            .simultaneousGesture(TapGesture().onEnded {
                                if modelData.currentUserIntakeItems.count >= 1 {
                                    let waterAmount = modelData.currentUserIntakeItems[0].waterAmount
                                    let sodiumAmount = modelData.currentUserIntakeItems[0].sodiumAmount
                                    modelData.removeIntakeBottle(bottle: modelData.currentUserIntakeItems[0])
                                    modelData.totalWaterAmount -= Double(waterAmount)
                                    if modelData.totalWaterAmount < 0 {
                                        modelData.totalWaterAmount = 0
                                    }
                                    modelData.totalSodiumAmount -= Double(sodiumAmount)
                                    if modelData.totalSodiumAmount < 0 {
                                        modelData.totalSodiumAmount = 0
                                    }
                                }
                                if modelData.currentUserIntakeItems.count == 0 {
                                    intakeTabGlobalState = .intakeNormal
                                    updateIntakeTabState()
                                }
                            })
                        VStack {
                            Text("Tap to remove.")
                                .font(.custom("Roboto-Regular", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(UIColor.darkGray))
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 5)
                    .padding(.top, -5)
                }
                else if modelData.currentUserIntakeItems.count < 3 {
                    HStack (alignment: .top, spacing: 10) {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(modelData.currentUserIntakeItems) { bottle in
                                    BottleRenderView(totalWaterAmount: $modelData.totalWaterAmount, totalSodiumAmount: $modelData.totalSodiumAmount, showBottleModifierPopover: $showBottleModifierPopover, bottleViewRect: $bottleViewRect, bottle: bottle, showName: true, isIntake: true, isAllowHitTest: true)
                                        .simultaneousGesture(TapGesture().onEnded {
                                            let waterAmount = bottle.waterAmount
                                            let sodiumAmount = bottle.sodiumAmount
                                            modelData.removeIntakeBottle(bottle: bottle)
                                            modelData.totalWaterAmount -= Double(waterAmount)
                                            if modelData.totalWaterAmount < 0 {
                                                modelData.totalWaterAmount = 0
                                            }
                                            modelData.totalSodiumAmount -= Double(sodiumAmount)
                                            if modelData.totalSodiumAmount < 0 {
                                                modelData.totalSodiumAmount = 0
                                            }
                                        })
                                }
                            }
                        }
                        
                        VStack {
                            Text("Tap to remove.")
                                .font(.custom("Roboto-Regular", size: 16))
                                .frame(maxWidth: 120, alignment: .leading)
                                .foregroundColor(Color(UIColor.darkGray))
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 5)
                    .padding(.top, -5)
                }
                else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(modelData.currentUserIntakeItems) { bottle in
                                BottleRenderView(totalWaterAmount: $modelData.totalWaterAmount, totalSodiumAmount: $modelData.totalSodiumAmount, showBottleModifierPopover: $showBottleModifierPopover, bottleViewRect: $bottleViewRect, bottle: bottle, showName: true, isIntake: true, isAllowHitTest: true)
                                    .simultaneousGesture(TapGesture().onEnded {
                                        let waterAmount = bottle.waterAmount
                                        let sodiumAmount = bottle.sodiumAmount
                                        modelData.removeIntakeBottle(bottle: bottle)
                                        modelData.totalWaterAmount -= Double(waterAmount)
                                        if modelData.totalWaterAmount < 0 {
                                            modelData.totalWaterAmount = 0
                                        }
                                        modelData.totalSodiumAmount -= Double(sodiumAmount)
                                        if modelData.totalSodiumAmount < 0 {
                                            modelData.totalSodiumAmount = 0
                                        }
                                    })
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 5)
                    .padding(.top, -5)
                }   // End of bottle intake view
                
                Divider()
                    .frame(height: 1)
                    .overlay(Color(UIColor.lightGray))
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                
                HStack {
                    VStack {
                        Text("WATER")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)

                        Text(String(format: "%.1f", modelData.userPrefsData.getTotalWaterIntake(amount: modelData.totalWaterAmount)))
                            .font(.custom("Roboto-Bold", size: 38))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)

                        SetUnitButtonView(unitType: .water)
                            .padding(.top, -20)
                        
                        HStack  {
                            RecommendedIntakePieView(endAngle: recommendedWaterIntakeDegrees)

                            Text(String(Int(recommendedWaterIntakePercentage)) + "%")
                                .font(.custom("Roboto-Regular", size: 15))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.gray)
                                .onReceive(modelData.$totalWaterAmount, perform: { total in
                                    print("Total Water Intake \(total)")
                                    if BLEManager.bleSingleton.currentFluidDeficitInOz <= 0 {
                                        recommendedWaterIntakePercentage = 0
                                    }
                                    else {
                                        let mlToOz = modelData.totalWaterAmount / 29.574
                                        let waterDeficit = BLEManager.bleSingleton.currentFluidDeficitInOz
                                        recommendedWaterIntakePercentage = (mlToOz / waterDeficit) * 100
                                        recommendedWaterIntakeDegrees = (recommendedWaterIntakePercentage / 100) * 360
                                    }
                                })
                        }
                        .frame(width: 80.0, height: 80.0)
                        .padding(-20)
                        
                        Text("recommended")
                            .font(Font.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)
                        Text("intake")
                            .font(Font.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)
                    }
                    .frame(width: 135)
                    .padding(.leading, 25)
                    
                    Spacer()
                    
                    VStack {
                        Text("SODIUM")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)

                        Text(String(format: "%.1f", modelData.userPrefsData.getTotalSodiumIntake(amount: modelData.totalSodiumAmount)))
                            .font(.custom("Roboto-Bold", size: 38))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)

                        SetUnitButtonView(unitType: .sodium)
                            .padding(.top, -20)
                        
                        HStack  {
                            RecommendedIntakePieView(endAngle: recommendedSodiumIntakePercentage)
                            
                            Text(String(Int(recommendedSodiumIntakePercentage)) + "%")
                                .font(.custom("Roboto-Regular", size: 15))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.gray)
                                .onReceive(modelData.$totalSodiumAmount, perform: { total in
                                    print("Total Sodium Intake \(total)")
                                    if BLEManager.bleSingleton.currentSodiumDeficitInMg <= 0 {
                                        recommendedSodiumIntakePercentage = 0
                                    }
                                    else {
                                        let sodiumDeficit = BLEManager.bleSingleton.currentSodiumDeficitInMg
                                        recommendedSodiumIntakePercentage = (modelData.totalSodiumAmount / Double(sodiumDeficit)) * 100
                                        recommendedSodiumIntakeDegrees = (recommendedSodiumIntakePercentage / 100) * 360
                                    }
                                })
                        }
                        .frame(width: 80.0, height: 80.0)
                        .padding(-20)
                        
                        Text("recommended")
                            .font(Font.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)
                        Text("intake")
                            .font(Font.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.gray)
                    }
                    .frame(width: 135)
                    .padding(.trailing, 25)
                }
                .modifier(BottleViewModifier(model: $showBottleModifierPopover, viewRect: $bottleViewRect, totalWaterAmount: $modelData.totalWaterAmount, totalSodiumAmount: $modelData.totalSodiumAmount))

                Spacer()
            }
        }
        .trackRUMView(name: "IntakeView")
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 80)
        .onAppear() {
            if modelData.currentUserIntakeItems.count > 0 {
                intakeTabGlobalState = .intakeSave
                updateIntakeTabState()
                startTimer()
                showCancel = true
            }
            else {
                intakeTabGlobalState = .intakeClose
                updateIntakeTabState()
                showCancel = false
            }
        }
        .onDisappear() {
            if(!modelData.cancelFromIntakeSubView) {
                intakeTabGlobalState = .intakeNormal
                updateIntakeTabState()
            }
            else {
                modelData.cancelFromIntakeSubView = false
            }
        }
    }
}
