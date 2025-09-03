//
//  BgTabIntakeExtensionView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 6/13/23.
//

import SwiftUI

struct BgTabIntakeExtensionView: View {

    @EnvironmentObject var modelData: ModelData

    private let viewWidth = 250.0

    @Binding var tabSelection: Tab
    
    var body : some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Circle()
                    .foregroundColor(Color.white.opacity(0.1))
                    //.foregroundColor(Color.red.opacity(0.3))   // use for debugging
                    .frame(width: viewWidth, height: 80)
                    .clipped()
                    .padding(.leading, (geometry.size.width / 2.0) - (viewWidth / 2))
                    .padding(.top, geometry.size.height - 38)
                    .onTapGesture {
                        print("BgTabIntakeExtensionView was tapped")
                        
                        if(self.tabSelection != .intake) {
                            self.tabSelection = .intake
                        }
                        
                        if(self.tabSelection == .intake) {
                            
                            switch intakeTabGlobalState {
                            case .intakeNormal:
                                modelData.loadUserBottleMenuItems()
                                intakeTabGlobalState = .intakeClose
                                updateIntakeTabState()
                                break
                            case .intakeCancel:
                                modelData.cancelFromIntakeSubView = true
                                modelData.rootViewId = UUID()
                                intakeTabGlobalState = .intakeClose
                                updateIntakeTabState()
                                break
                            case .intakeAdd:
                                if modelData.currentBottleListSelections.count >= 1 {
                                    modelData.addSelectedBottlesMenuItem()
                                }
                                else {
                                    modelData.addNewUserBottleMenuItem()
                                }
                                modelData.currentBottleListSelections.removeAll()
                                modelData.cancelFromIntakeSubView = true
                                modelData.rootViewId = UUID()
                                intakeTabGlobalState = .intakeNormal
                                updateIntakeTabState()
                                break
                            case .intakeClose:
                                // open today view
                                modelData.currentUserIntakeItems.removeAll()
                                modelData.currentBottleCounts.removeAll()
                                modelData.currentBottleListSelections.removeAll()
                                modelData.totalWaterAmount = 0
                                modelData.totalSodiumAmount = 0
                                intakeTabGlobalState = .intakeNormal
                                updateIntakeTabState()
                                self.tabSelection = .today
                                break
                            case .intakeSave:
                                modelData.ebsMonitor.saveFuildIntakeToDevice()
                                modelData.currentUserIntakeItems.removeAll()
                                modelData.currentBottleCounts.removeAll()
                                modelData.currentBottleListSelections.removeAll()
                                modelData.newBottlesAdded.removeAll()
                                modelData.totalWaterAmount = 0
                                modelData.totalSodiumAmount = 0
                                intakeTabGlobalState = .intakeNormal
                                updateIntakeTabState()
                                self.tabSelection = .today
                                break
                            case .intakeUpdate:
                                break
                            }
                        }
                                                
                    }
            }
        }
    }
}
