//
//  AddBottleView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/14/23.
//

import SwiftUI

struct AddBottleView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var tabNothing: Tab = .intake

    @Binding var tabSelection: Tab

    var body: some View {
        VStack {
            Text("PICK METHOD:")
                .font(.headline)
                .foregroundColor(Color(UIColor.lightGray))

            Button(action: {
                navigate(.push(.intakeBottleList))
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 60))
                        .foregroundColor(Color("Button Font Color"))
                    Text("Select Item From List")
                        .foregroundColor(Color("Button Font Color"))
                }
            }
            .trackRUMTapAction(name: "bottle-list")
            .buttonStyle(HighlightButtonStyle())
            .font(.system(size: 17))
            .font(.footnote.bold())
            .foregroundColor(Color("Button Font Color"))
            .frame(width: 300.0, height: 100.0)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color("Button Color"))
                .shadow(color: .gray, radius: 2, x: 0, y: 2))

            Button(action: {
                intakeTabGlobalState = .intakeAdd
                updateIntakeTabState()
                navigate(.push(.intakeEnterManually))
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 60))
                        .foregroundColor(Color("Button Font Color"))
                    Text("Enter Item Manually")
                        .foregroundColor(Color("Button Font Color"))
                }
            }
            .trackRUMTapAction(name: "bottle-enter")
            .buttonStyle(HighlightButtonStyle())
            .font(.system(size: 17))
            .foregroundColor(Color("Button Font Color"))
            .frame(width: 300.0, height: 100.0)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color("Button Color"))
                .shadow(color: .gray, radius: 2, x: 0, y: 2))
            
            BgTabIntakeExtensionView(tabSelection: $tabNothing)
                .clipped()
        }
        .trackRUMView(name: "AddBottleView")
        .onAppear() {
            modelData.cancelFromIntakeSubView = true
        }
        .onDisappear() {
            modelData.cancelFromIntakeSubView = false
        }
        .navigationBarTitle("ADD A MENU ITEM", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            navigate(.unwind(.intakeAddBottle))
        }){
            Image(systemName: "lessthan")
                .foregroundColor(Color.gray)
        })
        .navigationBarItems(trailing: Button(action : {
            navigate(.unwind(.intakeAddBottle))
        }){
            Image(systemName: "xmark")
                .foregroundColor(Color.gray)
        })
    }
}
