//
//  EnterItemManually.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/20/23.
//

import SwiftUI
import Combine

let bottleNamePlaceholder = String(localized:"e.g. Spring Water")
let amountPlaceholder = "           0"

struct EnterItemManually: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @Binding var tabSelection: Tab

    @State private var tabNothing: Tab = .intake

    @State private var rowSelected = false
    @State private var searchText = ""
    @State private var staticPreviewImageName = "static"
    @State private var selectedPreviewImageButton = 0
    
    init(tabSelection: Binding<Tab>) {
        self._tabSelection = tabSelection
    }

    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    HStack {
                        VStack {
                            Text("WATER CONTENT")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(UIColor.darkGray))
                            HStack {
                                
                                TextField(amountPlaceholder, text: $modelData.waterAmountEnterManual)
                                    .onChange(of: $modelData.waterAmountEnterManual.wrappedValue) {
                                        modelData.waterAmountEnterManual = String($0.prefix(4))
                                        modelData.manualUserBottle.waterSize = modelData.userPrefsData.getUserSweatUnitString()
                                    }
                                    .keyboardType(.decimalPad)
                                    .background(RoundedCorners(color: Color("Text Edit Bkgrd"), tl: 10, tr: 0, bl: 10, br: 0))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(minWidth: 80, minHeight: 50)
                                    .multilineTextAlignment(.trailing)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }.tint(.blue)
                                        }

                                    }

                                Text(modelData.userPrefsData.getUserSweatUnitString())
                                    .foregroundColor(Color.gray)
                                    .font(.custom("Oswald-Regular", size: settingsTitleFontSize))
                                
                            }
                        }
                        
                        VStack {
                            Text("SODIUM CONTENT")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(UIColor.darkGray))
                            HStack {
                                
                                TextField(amountPlaceholder, text: $modelData.sodiumAmountEnterManual)
                                    .onChange(of: $modelData.sodiumAmountEnterManual.wrappedValue) {
                                        modelData.sodiumAmountEnterManual = String($0.prefix(4))
                                    }
                                    .keyboardType(.decimalPad)
                                    .background(RoundedCorners(color: Color("Text Edit Bkgrd"), tl: 10, tr: 0, bl: 10, br: 0))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(minWidth: 80, minHeight: 50)
                                    .multilineTextAlignment(.trailing)

                                Text(modelData.userPrefsData.getUserSodiumUnitString())
                                    .foregroundColor(Color.gray)
                                    .font(.custom("Oswald-Regular", size: settingsTitleFontSize))
                            }
                        }
                    }
                    
                    Text("NAME (OPTIONAL)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(UIColor.darkGray))
                    TextField(bottleNamePlaceholder, text: $modelData.manualUserBottle.name)
                        .frame(minHeight: 50)
                        .background(Color("Text Edit Bkgrd"))
                        .cornerRadius(10)
                        .onTapGesture {
                            if modelData.manualUserBottle.name == bottleNamePlaceholder {
                                modelData.manualUserBottle.name = ""
                            }
                        }
                        .onReceive(Just(modelData.manualUserBottle.name)) { _ in limitText(30) }

                    Text("PREVIEW")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color(UIColor.darkGray))

                    HStack(alignment: .top, spacing: 10) {
                        PreviewBottleView(image: "", updateImage: $staticPreviewImageName, selectedPreviewImageButton: $selectedPreviewImageButton, buttonIdx: -1)
                        SingleBottleView(name: $modelData.manualUserBottle.name, waterAmount: $modelData.waterAmountEnterManual, waterSize: $modelData.manualUserBottle.waterSize, sodiumAmount: $modelData.sodiumAmountEnterManual, sodiumSize: $modelData.manualUserBottle.sodiumSize, image: $modelData.manualUserBottle.imageName)
                        PreviewBottleView(image: "", updateImage: $staticPreviewImageName, selectedPreviewImageButton: $selectedPreviewImageButton, buttonIdx: -1)
                    }
                    .padding(.bottom, 10)

                    Spacer()

                    Text("SELECT AN ICON")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(UIColor.darkGray))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 10) {
                            ForEach(0..<modelData.bottlePreviewIcons.count, id: \.self) { index in
                                PreviewBottleView(image: modelData.bottlePreviewIcons[index].imageName, updateImage: $modelData.manualUserBottle.imageName, selectedPreviewImageButton: $selectedPreviewImageButton, buttonIdx: index)
                            }
                        }
                    }
                    .frame(height: 145)
                    .padding(.bottom, 20)

                    Spacer()
                }
            }
            .padding(.leading, 10)

            BgTabIntakeExtensionView(tabSelection: $tabNothing)
                .clipped()
        }
        .trackRUMView(name: "EnterItemManually")
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .padding(10)
        .navigationBarTitle(Text(String(localized:"ENTER MENU ITEM")), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            navigate(.unwind(.intakeAddBottle))
            intakeTabGlobalState = .intakeCancel
            updateIntakeTabState()
        }){
            HStack {
                Image(systemName: "lessthan")
                    .foregroundColor(Color(UIColor.darkGray))
            }
        })
        .navigationBarItems(trailing: Button(action : {
            modelData.cancelFromIntakeSubView = true
            navigate(.unwind(.intakeAddBottle))
            modelData.rootViewId = UUID()
        }){
            HStack {
                Image(systemName: "xmark")
                    .foregroundColor(Color.gray)
            }
        })
    }

    // Function to keep text length in limits
    func limitText(_ upper: Int) {
        if modelData.manualUserBottle.name.count > upper {
            modelData.manualUserBottle.name = String(modelData.manualUserBottle.name.prefix(upper))
        }
    }

    func largeScreenModel() -> Bool {
        if UIDevice.modelName.contains("iPhone 12") {
            return true
        }
        else if UIDevice.modelName.contains("iPhone 13") {
            return true
        }
        else if UIDevice.modelName.contains("iPhone 14") {
            return true
        }
        else if UIDevice.modelName.contains("iPhone 15") {
            return true
        }
        else {
            return false
        }
    }

}
