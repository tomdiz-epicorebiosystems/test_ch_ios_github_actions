//
//  EditEnterpriseSiteIdView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/11/23.
//

import SwiftUI

struct EditEnterpriseSiteIdView: View {

    @EnvironmentObject var modelData: ModelData

    @Environment(\.presentationMode) var presentation

    @Binding var isEnterpriseEditPresent: Bool

    @State var newEnterpriseCode = ""
    @State var oldEnterpriseCode = ""

    @State var newSiteIdCode = ""
    @State var oldSiteIdCode = ""

    @State var buttonTapOnce = false

    @State var showNetworkProgressView = false
    @State private var handlingNetworkAPI = false

    var body: some View {
        if self.modelData.updatedUserSuccess == 1 {
            VStack {}
            .onAppear() {
                buttonTapOnce = false
                // Save off since values are good and no server API failures
                self.presentation.wrappedValue.dismiss()
                self.isEnterpriseEditPresent = false
                self.modelData.updatedUserSuccess = 0
                handlingNetworkAPI = false
                self.modelData.networkAPIError = false
                                
            }
            .onDisappear() {
                
                modelData.enterpriseSiteCodeUpdated = true
                // Update enterprise and site name after successful edit/update.
                modelData.networkManager.enterpriseNameErr = nil
                modelData.onboardingEnterpriseSiteCode = modelData.jwtEnterpriseID + "-" + modelData.jwtSiteID
                modelData.CH_EnterpriseName = ""
                modelData.CH_SiteName = ""
                modelData.networkAPIError = false
                modelData.networkManager.modelData = modelData
                modelData.networkManager.getEnterpriseName(enterpriseId: modelData.onboardingEnterpriseSiteCode)
            }
        }
        else if showNetworkProgressView == true && handlingNetworkAPI == false {
            VStack {}
            .onAppear() {
                buttonTapOnce = false
                self.showNetworkProgressView = false
            }
        }
        else {
            ZStack {
                VStack {
                    HStack {
                        Text("Enterprise")
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(.leading, 40)
                            .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                            .accessibility(identifier: "text_editenterprisesiteidview_enterprise")

                        Spacer()
                        
                        TextField("", text: $newEnterpriseCode)
                            .frame(width: 150, height: 40)
                            .multilineTextAlignment(.center)
                            .keyboardType(.alphabet)
                            .autocapitalization(.allCharacters)
                            .autocorrectionDisabled(true)
                            .submitLabel(.done)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            ).padding(.trailing, 80)
                            .accessibility(identifier: "textfield_editenterprisesiteidview_enterprise")

                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        Text("Site ID")
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(.leading, 40)
                            .font(.custom("Oswald-Regular", size: settingsInfoTextFontSize))
                            .accessibility(identifier: "text_editenterprisesiteidview_site")

                        Spacer()
                        
                        TextField("", text: $newSiteIdCode)
                            .frame(width: 150, height: 40)
                            .multilineTextAlignment(.center)
                            .keyboardType(.alphabet)
                            .autocapitalization(.allCharacters)
                            .autocorrectionDisabled(true)
                            .submitLabel(.done)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            ).padding(.trailing, 80)
                            .accessibility(identifier: "textfield_editenterprisesiteidview_site")

                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    if self.modelData.networkAPIError {
                        if let serverError = modelData.networkManager.serverError {
//                            Text(serverError.error ?? "Unknown server API issue")
                            Text("Enterprise code or site ID is invalid")
                                .font(.custom("Roboto-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.red)
                                .padding(.bottom, 10)
                                .onAppear() {
                                    buttonTapOnce = false
                                    handlingNetworkAPI = false
                                }
                                .accessibility(identifier: "text_editenterprisesiteidview_invalid")

                        }
                        else {
                            Text("Unknown server API issue")
                                .font(.custom("Roboto-Regular", size: 14))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.red)
                                .padding(.bottom, 10)
                                .onAppear() {
                                    buttonTapOnce = false
                                    handlingNetworkAPI = false
                                }
                                .accessibility(identifier: "text_editenterprisesiteidview_unknown")

                        }
                    }
                    
                    else {
                        if buttonTapOnce {
                            
                        }
                    }

                    HStack {
                        Button(action: {
                            if buttonTapOnce {
                                return
                            }
                            buttonTapOnce = true
                            if oldEnterpriseCode != newEnterpriseCode || oldSiteIdCode != newSiteIdCode {
                                
                                let userInfo = ["height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                                modelData.networkManager.updateUser(enterpriseId: newEnterpriseCode, siteId: newSiteIdCode, userInfo: userInfo)

                                handlingNetworkAPI = true
                                showNetworkProgressView = true
                            }
                            else {
                                self.presentation.wrappedValue.dismiss()
                                self.isEnterpriseEditPresent = false
                            }
                        }) {
                            Text("OK")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 120, height: 20)
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                                .padding(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 2))
                                .accessibility(identifier: "text_editenterprisesiteidview_ok")

                        }
                        .trackRUMTapAction(name: "editenterprise-ok")
                        .disabled(buttonTapOnce)
                        .accessibility(identifier: "button_editenterprisesiteidview_ok")

                        Spacer()
                        
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                            self.isEnterpriseEditPresent = false
                        }) {
                            Text("CANCEL")
                                .font(.custom("Oswald-Regular", size: 18))
                                .frame(width: 120, height: 20)
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                                .padding(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 2))
                                .accessibility(identifier: "text_editenterprisesiteidview_cancel")

                        }
                        .trackRUMTapAction(name: "editenterprise-cancel")
                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .padding(.bottom, 60)
                    .accessibility(identifier: "button_editenterprisesiteidview_cancel")

                }
                .padding(.top, 50)
                .onAppear() {
                    let codeId = modelData.onboardingEnterpriseSiteCode
                    let splitCode = codeId.split(separator: "-")
                    if splitCode.count <= 0 {
                        return
                    }
                    let enterpriseCode = String(splitCode[0])
                    oldEnterpriseCode = enterpriseCode
                    newEnterpriseCode = enterpriseCode
                    let siteId = String(splitCode[1])
                    oldSiteIdCode = siteId
                    newSiteIdCode = siteId
                }

                if showNetworkProgressView == true {
                    NetworkProgressView()
                }
            } // ZStack
            .trackRUMView(name: "EditEnterpriseSiteIdView")
        }
    }
}
