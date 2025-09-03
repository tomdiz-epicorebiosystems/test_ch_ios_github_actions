//
//  EpicoreRequiredView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/16/23.
//

import Foundation
import SwiftUI
import WebKit

enum EpicoreLegalScreens {
    case faq
    case troubleshooting
    case terms
    case privacy
}

struct EpicoreRequiredView: View {
    @Environment(\.presentationMode) var presentation

    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    var epicodeLegalView: EpicoreLegalScreens

    var body: some View {
        VStack {
            HStack {
                Image("Info Epicore Logo")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                }
                .padding(.trailing, 20)
                .font(.system(size: 24))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack {
                
                if epicodeLegalView == .faq {
                    if (languageCode == "ja") {
                        WebView(url: Bundle.main.url(forResource: "faq_jap", withExtension:"pdf") ?? URL(string: "https://www.epicorebiosystems.com/connected-hydration/faq/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                    else {
                        //WebView(url: Bundle.main.url(forResource: "faq", withExtension:"html") ?? URL(string: "https://www.epicorebiosystems.com/connected-hydration/faq/")!)
                        WebView(url: URL(string: "https://www.epicorebiosystems.com/connected-hydration/faq/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                }
                else if epicodeLegalView == .troubleshooting {
                    if (languageCode == "ja") {
                        WebView(url: Bundle.main.url(forResource: "toubleshooting-jap", withExtension:"pdf") ?? URL(string: "https://www.epicorebiosystems.com/connected-hydration/faq/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                    else {
                        WebView(url: Bundle.main.url(forResource: "troubleshooting", withExtension:"html") ?? URL(string: "https://www.epicorebiosystems.com/connected-hydration/faq/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                }
                else if epicodeLegalView == .privacy {
                    if (languageCode == "ja") {
                        WebView(url: Bundle.main.url(forResource: "privacy-policy-jap", withExtension:"pdf") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                    else {
                        WebView(url: Bundle.main.url(forResource: "PrivacyPolicy", withExtension:"html") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                }
                else if epicodeLegalView == .terms {
                    if (languageCode == "ja") {
                        WebView(url: Bundle.main.url(forResource: "terms-jap", withExtension:"pdf") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                    else {
                        WebView(url: Bundle.main.url(forResource: "TermsConditions", withExtension:"html") ?? URL(string: "https://www.epicorebiosystems.com/privacy/")!)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 20)
                            .background(Color(hex:"#FFFFFF"))
                    }
                }
            }
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .trackRUMView(name: "EpicoreReqiuredView")
        .background(Color(hex:"#4A4A4D")
            .edgesIgnoringSafeArea(.all))
    }
}
