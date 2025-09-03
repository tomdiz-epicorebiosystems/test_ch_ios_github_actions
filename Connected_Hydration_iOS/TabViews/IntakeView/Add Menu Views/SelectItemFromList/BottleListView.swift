//
//  BottleListView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/8/23.
//

import SwiftUI

struct BottleListView: View {
    //let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W", "X","Y", "Z"]

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var rowSelected = false
    @State private var searchText = ""
    @State private var tabNothing: Tab = .intake

    @Binding var tabSelection: Tab

    var body: some View {
        ZStack {
            VStack {
                SearchBar(text: $searchText)

                List(modelData.getTotalPresetBottles().filter({ searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText) })) { bottle in
                    BottleRow(bottle: bottle)
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitle("SELECT ITEM(S)", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action : {
                    navigate(.unwind(.intakeAddBottle))
                }){
                    HStack {
                        Image(systemName: "lessthan")
                            .foregroundColor(Color.gray)
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
            
            BgTabIntakeExtensionView(tabSelection: $tabNothing)
                .clipped()
        }
        .trackRUMView(name: "BottleListView")
    }
}
