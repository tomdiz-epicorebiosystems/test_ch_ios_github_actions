//
//  PatchApplicationView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct PatchApplicationView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen

    var body: some View {
        ScrollViewReader { sp in
            
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack {
                    Text("PATCH APPLICATION")
                        .font(.custom("Oswald-Regular", size: 24))
                        .foregroundColor(Color(hex: "#68C5EA"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)

                    PatchApplicationShareInfo2View()
                    
                    PatchApplicationShareInfo3View()
                    
                    Spacer()
                    
                    Button(action: {
                        self.currInfoScreen = .modulePairing
                    }) {
                        Text("MODULE PAIRING >")
                            .font(.custom("Oswald-Regular", size: 18))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 20)
                            .padding(.trailing, 40)
                            .padding(.bottom, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex:"#4A4A4D"))
            }
            .id(1)
            .onAppear() {
                sp.scrollTo(1, anchor: .top)
            }
            
        }
    }
}
