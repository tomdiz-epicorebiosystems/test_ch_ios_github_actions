//
//  DebugSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/3/23.
//

import SwiftUI

struct DebugSettingsView: View {

    @State private var isDebugViewPresented = false

    var body: some View {
        VStack {
            Button(action: {
                self.isDebugViewPresented = true
            }) {
                HStack {
                    Text("Debug")
                        .foregroundColor(Color("Button Font Color"))
                        .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                .padding(10)
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1.0)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .edgesIgnoringSafeArea(.horizontal)
        }
        .trackRUMView(name: "DebugSettingsView")
        .navigationDestination(
            isPresented: $isDebugViewPresented) {
                DebugView().navigationBarBackButtonHidden(true)
        }
    }
}
