//
//  SupportView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI
import SwiftUIMailView

struct SupportView: View {
    @Environment(\.presentationMode) var presentation

    @State var isFaqPresented = false
    @State var isToubleShootingresented = false

    @EnvironmentObject var modelData: ModelData
    @State private var showMailView = false
    @State private var mailData = ComposeMailData(subject: "Support Request",
                                                  recipients: ["support@epicorebiosystems.com"],
                                                  message: "",
                                                  attachments: [AttachmentData(data: "Some text".data(using: .utf8)!,
                                                                               mimeType: "text/plain",
                                                                               fileName: "text.txt")
                                                  ])
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        VStack {
            Text("Support")
                .font(.custom("Oswald-Regular", size: 24))
                .foregroundColor(Color(hex: "#68C5EA"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)

            Button(action: {
                self.isToubleShootingresented = true
            }) {
                Text("Troubleshooting")
                    .underline()
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
            }
            .trackRUMTapAction(name: "support-troubleshooting")
            .uiKitFullPresent(isPresented: $isToubleShootingresented, content: { closeHandler in
                EpicoreRequiredView(epicodeLegalView: .troubleshooting)
            })
/*
            Button(action: {
                self.isFaqPresented = true
            }) {
                Text("Frequently Asked Questions")
                    .underline()
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
            }
            .trackRUMTapAction(name: "support-faq")
            .uiKitFullPresent(isPresented: $isFaqPresented, content: { closeHandler in
                EpicoreRequiredView(epicodeLegalView: .faq)
            })
*/
            Button(action: {
                showMailView.toggle()
            }) {
                Text("support@epicorebiosystems.com")
                    .underline()
                    .foregroundColor(Color(.white))
                    .accentColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
            }
            .trackRUMTapAction(name: "support-email")
            .disabled(!MailView.canSendMail)
            .sheet(isPresented: $showMailView) {
                MailView(data: $mailData) { result in
                    print(result)
                }
            }

            Text(languageCode == "ja" ? "" : "+1 (617) 397-3756")
                .underline()
                .foregroundColor(Color(.white))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.leading, 20)
                .onTapGesture {
                    guard let number = URL(string: "tel://+1-617-397-3756") else { return }
                    if UIApplication.shared.canOpenURL(number) {
                        UIApplication.shared.open(number)
                    } else {
                        print("Can't open url on this device")
                    }
                }

            Spacer()
        }
        .onAppear() {
            self.isFaqPresented = false
            self.isToubleShootingresented = false
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#4A4A4D"))
    }
}
