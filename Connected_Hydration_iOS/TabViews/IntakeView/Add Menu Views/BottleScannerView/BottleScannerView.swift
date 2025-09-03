//
//  BottleScannerView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/29/23.
//

import SwiftUI
import CodeScanner

struct BottleScannerView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    @Binding var isBottleScannerPresented: Bool

    @State private var isCodeViewPresented = true
    @State private var barcodeScanFailed = false
    @State private var pushCodeEditConfirmView = false

    @State private var scanErrorString = "Camera permissions failed."
    @State private var scanErrorTitle = "SCAN UNSUCCESSFUL"
    
    @State private var tabNothing: Tab = .intake

    var body: some View {
        ZStack {
            if isCodeViewPresented {
                CodeScannerView(codeTypes: [.qr, .ean8, .upce, .ean13, .code128], scanMode: .once , scanInterval: 0.5, showViewfinder: true) { response in
                    if case let .success(result) = response {
                        var barcodeString = result.string
                        barcodeString.remove(at: barcodeString.startIndex)
                        print("scannedCode = " + barcodeString)
                        isCodeViewPresented = false
                        if let bottleIndx = modelData.searchFirstBottleDataBarCodes(barcode: barcodeString) {
                            print("Found Bottle:")
                            let bottleName = modelData.bottles[bottleIndx].name
                            let imageName = modelData.bottles[bottleIndx].imageName
                            let sodiumAmount = modelData.bottles[bottleIndx].sodiumAmount
                            let sodiumSize = modelData.bottles[bottleIndx].sodiumSize
                            let waterAmount = modelData.bottles[bottleIndx].waterAmount
                            let waterSize = modelData.bottles[bottleIndx].waterSize
                            let barcode = modelData.bottles[bottleIndx].barcode
                            print("Bottle name = \(bottleName)")
                            modelData.newUserBottle = BottleData(id: 0, name: bottleName, imageName: imageName, barcode: barcode, sodiumAmount: sodiumAmount, sodiumSize: sodiumSize, waterAmount: waterAmount, waterSize: waterSize)
                        }
                        else if let bottle2Indx = modelData.searchSecondBottleDataBarCodes(barcode: barcodeString) {
                            print("Found Preset Bottle:")
                            let bottleName = modelData.bottle_list[bottle2Indx].name
                            let imageName = modelData.bottle_list[bottle2Indx].imageName
                            let sodiumAmount = modelData.bottle_list[bottle2Indx].sodiumAmount
                            let sodiumSize = modelData.bottle_list[bottle2Indx].sodiumSize
                            let waterAmount = modelData.bottle_list[bottle2Indx].waterAmount
                            let waterSize = modelData.bottle_list[bottle2Indx].waterSize
                            let barcode = modelData.bottles[bottle2Indx].barcode
                            print("Bottle preset name = \(bottleName)")
                            modelData.newUserBottle = BottleData(id: 0, name: bottleName, imageName: imageName, barcode: barcode, sodiumAmount: sodiumAmount, sodiumSize: sodiumSize, waterAmount: waterAmount, waterSize: waterSize)
                        }
                        else {
                            barcodeScanFailed = true
                            scanErrorString = ""
                            scanErrorTitle  = "SCANNED ITEM NOT FOUND"
                        }
                    }
                    if case .failure(.permissionDenied) = response {
                        isCodeViewPresented = false
                        barcodeScanFailed = true
                        scanErrorString = "Camera permissions denied"
                    }
                    if case .failure(.badInput) = response {
                        isCodeViewPresented = false
                        barcodeScanFailed = true
                        scanErrorString = "Camera failed to read barcode or QR code"
                    }
                    if case .failure(.badOutput) = response {
                        isCodeViewPresented = false
                        barcodeScanFailed = true
                        scanErrorString = "Camera does not support reading barcode or QR code"
                    }
                }
            }
            else {
                if barcodeScanFailed == true {
                    VStack {
                        Spacer()
                        Text(scanErrorTitle)
                            .foregroundColor(Color(UIColor.darkGray))
                        Image("Scan Error")
                        Text(scanErrorString)
                            .foregroundColor(Color(UIColor.darkGray))
                        Spacer()
                    }
                }
                else {
                    VStack {
                    }
                    .onAppear() {
                        //print("*************** BottleScanner VStack OnAppear")
                        self.presentation.wrappedValue.dismiss()
                        if modelData.bottleInMenu(barcode: modelData.newUserBottle.barcode) == false {
                            modelData.addNewUserBottleMenuItem()
                        }
                        modelData.currentBottleListSelections.removeAll()
                        intakeTabGlobalState = .intakeNormal
                        modelData.rootViewId = UUID()
                    }
                }
            }
            
            BgTabIntakeExtensionView(tabSelection: $tabNothing)
                .clipped()
            
        }
        .padding(10)
        .navigationBarTitle("SCAN ITEM", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.presentation.wrappedValue.dismiss()
            self.isBottleScannerPresented = false
            intakeTabGlobalState = .intakeCancel
            updateIntakeTabState()
        }){
            Image(systemName: "lessthan")
                .foregroundColor(Color(UIColor.darkGray))
        })
        .navigationBarItems(trailing: Button(action : {
            modelData.cancelFromIntakeSubView = true
            self.isBottleScannerPresented = false
            modelData.rootViewId = UUID()
        }){
            Image(systemName: "xmark")
                .foregroundColor(Color.gray)
        })
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
