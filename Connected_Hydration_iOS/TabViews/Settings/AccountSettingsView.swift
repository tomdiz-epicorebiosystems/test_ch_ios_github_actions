//
//  AccountSettingsView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/10/23.
//

import SwiftUI
import SwiftUIMailView

struct AccountSettingsView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var mailData = ComposeMailData(subject: "Deletion Request",
                                                  recipients: ["support@epicorebiosystems.com"],
                                                  message: "The user wants to request deletion of account or download/xfer of data.",
                                                  attachments: [AttachmentData(data: "Some text".data(using: .utf8)!,
                                                                               mimeType: "text/plain",
                                                                               fileName: "text.txt")
                                                  ])
    @State private var showMailView = false
    @State private var isEnterpriseEditPresent = false

    var body: some View {
        HStack {
            Text("ACCOUNT")
                .padding(.leading, 10)
                .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
            
            Spacer()

            Button(action: {
                self.isEnterpriseEditPresent = true
            }) {
                Text("EDIT")
                    .underline()
                    .padding(.trailing, 10)
                    .font(.custom("Oswald-Bold", size: settingsHeaderTextFontSize))
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
            }
            .trackRUMTapAction(name: "tap_account_settings_edit")
        }
        .frame(height: settingsSectionGrayHeight)
        .uiKitFullPresent(isPresented: $isEnterpriseEditPresent, content: { closeHandler in
            EditEnterpriseSiteIdView(isEnterpriseEditPresent: $isEnterpriseEditPresent)
                .environmentObject(modelData)
        })
        .padding(.vertical, 2)
        .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)

        let userEmail = modelData.userEmailAddress
        let enterpriseAndSiteID = modelData.enterpriseSiteCode
        let splitCode = enterpriseAndSiteID.split(separator: "-")
        
        HStack {
            VStack {
                Text("Email")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Enterprise")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Site")
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 40)
            
            VStack {
                Text(userEmail)
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("RobotoCondensed-Regular", size: settingsInfoTextFontSize))
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.top, 8)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(splitCode.isEmpty ? "" : splitCode[0])
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("RobotoCondensed-Regular", size: settingsInfoTextFontSize))
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(splitCode.isEmpty ? "" : splitCode[1])
                    .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                    .font(.custom("RobotoCondensed-Regular", size: settingsInfoTextFontSize))
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .trackRUMView(name: "AccountSettingsView")
        .padding(5)
    }
}
