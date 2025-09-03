//
//  ModulePairingView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct ModulePairingView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen

    var body: some View {
        ScrollViewReader { sp in
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Text("MODULE PAIRING")
                        .font(.custom("Oswald-Regular", size: 24))
                        .foregroundColor(Color(hex: "#68C5EA"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                    
                    PairModuleShareInfo1View()
                    
                    Text("Scan the QR code\non the back of the module.")
                        .font(.custom("Roboto-Regular", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                        .padding(.leading, 20)
                    
                    PairModuleShareInfo2View()
                    
                    Spacer()
                    
                    Button(action: {
                        self.currInfoScreen = .sodiumEq
                    }) {
                        Text("SODIUM EQUIVALENTS >")
                            .font(.custom("Oswald-Regular", size: 18))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 40)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .trackRUMTapAction(name: "modulepair-sodiumeq")
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
