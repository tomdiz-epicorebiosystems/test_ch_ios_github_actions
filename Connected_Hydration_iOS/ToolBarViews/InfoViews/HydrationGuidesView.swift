//
//  HydrationGuidesView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct HydrationGuidesView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen

    var body: some View {
        VStack {
            Text("HYDRATION GUIDES")
                .font(.custom("Oswald-Regular", size: 24))
                .foregroundColor(Color(hex: "#68C5EA"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)

            Spacer()

            Button(action: {
                self.currInfoScreen = .support
            }) {
                Text("SUPPORT >")
                    .font(.custom("Oswald-Regular", size: 18))
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 40)
                    .padding(.bottom, 40)
            }
            .trackRUMTapAction(name: "hydrationguide-support")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#4A4A4D"))
    }
}
