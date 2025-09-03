//
//  DebugView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 7/3/23.
//

import SwiftUI

struct DebugView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation
    
    @State var server = 0       // 0 = Production, 1 = Staging

    var body: some View {
        VStack {
            
            Text("Server:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("Button Font Color"))
                .font(.custom("Oswald-Regular", size: 24))
                .padding(10)
            Picker(selection: $server, label: Text("")) {
                Text("Production").tag(0)
                Text("Staging").tag(1)
            }
            .onAppear() {
                if modelData.epicoreHost == "ch.epicorebiosystems.com" {
                    server = 0
                }
                else {
                    server = 1
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 20)

            Button(action: {
                self.presentation.wrappedValue.dismiss()
                changeServer()
            }) {
                Text("CHANGE SERVER")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 200, height: 20)
                    .foregroundColor(Color.gray)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.lightGray), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            .padding(.bottom, 20)

            Button(action: {
                if let bundleID = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                }
            }) {
                Text("CLEAR USERDEFAULTS DATA")
                    .font(.custom("Oswald-Regular", size: 18))
                    .frame(width: 200, height: 20)
                    .foregroundColor(Color.gray)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.lightGray), lineWidth: 1)
                        .shadow(color: .gray, radius: 1, x: 0, y: 2))
            }
            .padding(.bottom, 20)

            Spacer()
        }
        .trackRUMView(name: "DebugView")
        .navigationBarItems(leading: Button(action : {
            self.presentation.wrappedValue.dismiss()
        }){
            HStack {
                Text("< SETTINGS")
                    .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
            }
        })
    }
    
    func changeServer() {
        modelData.networkManager.logOutUser()
        if server == 0 {
            // Production Server Info
            modelData.epicoreHost = "ch.epicorebiosystems.com"
            modelData.ch_phone_api_jwt_secret = "utbc_23p98Zb"
            modelData.ch_phone_api_key = "q3m7rvCPykvr3_4"
            modelData.clientId = "&client_id=aiGuzIjPCu6Mxm7M34hrkXYERJfhepRT"
            modelData.auth0Url = "auth.ch.epicorebiosystems.com"
        }
        else {
            // Staging Server Info
            modelData.epicoreHost = "epicore.dev"
            modelData.ch_phone_api_jwt_secret = "So0e5En79B3T"
            modelData.ch_phone_api_key = "%{UF)43sVG(#ks3"
            modelData.clientId = "&client_id=aHekjFeRi5qHapVK5XX0d6lr5FyrFeB7"
            modelData.auth0Url = "auth.epicore.dev"
       }
    }
}
