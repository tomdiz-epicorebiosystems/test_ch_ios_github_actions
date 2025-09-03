//
//  SetUnitButtonView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/27/23.
//

import SwiftUI

enum UnitType {
    case water
    case sodium
}

struct SetUnitButtonView: View {
    @EnvironmentObject var modelData: ModelData
    
    @State var unitType: UnitType?
    @State private var isUnitModalPresented = false
    
    var body: some View {
        Button(action: {
            //isUnitModalPresented = true
        }) {
            if unitType == .sodium {
                Text(modelData.userPrefsData.getUserSodiumUnitTodayButtonString())
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 120, height: 20)
                    .background(Color.white)
                    .foregroundColor(Color.gray)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.lightGray), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            else {
                Text(modelData.userPrefsData.getUserSweatUnitTodayButtonString())
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 120, height: 20)
                    .background(Color.white)
                    .foregroundColor(Color.gray)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.lightGray), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
        }
        .disabled(true)
    }
}
