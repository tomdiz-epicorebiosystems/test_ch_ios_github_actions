//
//  PhysiologyInformationView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 2/20/25.
//


//
//  PhysiologyInformationView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import Foundation
import SwiftUI
import BLEManager

struct PhysiologyInformationView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @Environment(\.presentationMode) var presentation
    
    @Binding var isPhysiologyShowing: Bool
    
    let genderList = [String(localized: "Male"), String(localized: "Female")]
    let clothingList = ["Single layer clothing", "Double layer clothing", "Tyvek or Polyolefin suit", "Chem. suit (Tychem) or fire fighter turnout"]
    
    var showHeader: Bool
    var isEditing: Bool
    var showOKCancelOption: Bool
    
    let userHeightInchPickerData = Array(0...11)
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    @Binding var currentWeightValue: String

    @State private var heightFt = 5
    @State private var heightIn = 9

    @State private var heightCm = "175"
    @State private var weight = "165"
    @State private var gender = String(localized: "Male")
    
    @State private var oldUserHeightFeet = ""
    @State private var oldUserHeightInch = ""
    @State private var oldUserHeightCm = ""
    @State private var oldUserWeight = ""
    @State private var oldUserGender = ""
    
    @State var notificationSweatUserInfoSetResponse: Any? = nil
    @State var notificationSensorFwSysInfoPayload: Any? = nil
    
    @State private var isPhysiologyEditPresent = false
    @State private var showPhysiologyConfirmAlert = false
    @State private var showHeightCmOutOfBoundsAlert = false
    @State private var showWeightOutOfBoundsAlert = false

    init(showHeader: Bool, isEditing: Bool, showOKCancelOption: Bool, isPhysiologyShowing: Binding<Bool>, currentWeightValue: Binding<String>) {
        self.showHeader = showHeader
        self.isEditing = isEditing
        self.showOKCancelOption = showOKCancelOption
        _isPhysiologyShowing = isPhysiologyShowing
        _currentWeightValue = currentWeightValue
    }
    
    var body: some View {
        VStack {
            if showHeader {
                HStack {
                    Text("PHYSIOLOGY INFORMATION")
                        .padding(.leading, 10)
                        .foregroundColor(.white)
                        .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                        .accessibility(identifier: "text_physiologyinformationview_title")

                    Spacer()
                    
                    Button(action: {
                        isPhysiologyEditPresent = true
                    }) {
                        Text("EDIT")
                            .underline()
                            .padding(.trailing, 10)
                            .font(.custom("Oswald-Bold", size: settingsHeaderTextFontSize))
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorHydroDarkText))
                            .accessibility(identifier: "text_physiologyinformationview_edit")

                    }
                }
                .trackRUMTapAction(name: "physiology-edit")
                .frame(height: settingsSectionGrayHeight)
                .uiKitFullPresent(isPresented: $isPhysiologyEditPresent, content: { closeHandler in
                    PhysiologyInformationView(showHeader: false, isEditing: true, showOKCancelOption: true, isPhysiologyShowing: $isPhysiologyEditPresent, currentWeightValue: $currentWeightValue)
                        .environmentObject(modelData)
                })
                .background(Color(hex: generalCHAppColors.settingsHeaderBackgroundColor))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibility(identifier: "button_physiologyinformationview_edit")

            }
            
            HStack {
                if showOKCancelOption == true {
                    Text("Height:")
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        .frame(width: 80, alignment: .leading)
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_height")
                }
                else {
                    Text("Height:")
                        .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                        .frame(width: 80, alignment: .leading)
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_height")
                }
                
                if isEditing == false {
                    if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                        if modelData.unitsChanged == "0" {
                            Text(modelData.userPrefsData.getUserHeightCm())
                                .frame(width: 80, height: 40)
                                .multilineTextAlignment(.center)
                                .background(
                                    RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                )
                                .disabled(true)
                                .accessibility(identifier: "text_physiologyinformationview_heightcm")

                        }
                        else {
                            Text(modelData.userPrefsData.getUserHeightInFt())
                                .frame(width: 40, height: 40)
                                .multilineTextAlignment(.center)
                                .background(
                                    RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                )
                                .disabled(true)
                                .accessibility(identifier: "text_physiologyinformationview_heightin")

                        }
                    }
                }
                else {
                    if modelData.unitsChanged == "0" {
                        TextField("", text: $heightCm)
                            .onReceive(heightCm.publisher.collect()) {
                                heightCm = String($0.prefix(3))
                                
                                let cm = UInt16(heightCm) ?? 0
                                if cm < 125 || cm > 212 {
                                    showHeightCmOutOfBoundsAlert = true
                                }
                                else {
                                    showHeightCmOutOfBoundsAlert = false
                                }
                                
                            }
                            .onAppear() {
                                heightCm = modelData.userPrefsData.getUserHeightCm()
                                modelData.userPrefsData.setUserHeightCm(cm: (UInt8(heightCm) ?? 175))

                            }
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            ).padding()
                            .autocorrectionDisabled(true)
                            .frame(width: 100, height: 40, alignment: .center)
                            .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(.leading, 5)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }.tint(.blue)
                                }
                            }
                            .accessibility(identifier: "textfield_physiologyinformationview_heightcm")

                    }
                    else {
                        Picker("", selection: $heightFt.onChange(unitsHeightFtChanged)) {
                            Text("4").tag(0)
                            Text("5").tag(1)
                            Text("6").tag(2)
                        }
                        .accentColor(Color.gray)
                        .pickerStyle(.menu)
                        .padding(.leading, 10)
                        .accessibility(identifier: "picker_physiologyinformationview_heightft")

                    }
                }
                
                if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                    if showOKCancelOption == true {
                        Text(modelData.userPrefsData.getUserHeightMajorUnitString())
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                            .accessibility(identifier: "text_physiologyinformationview_heightmajor")

                    }
                    else {
                        Text(modelData.userPrefsData.getUserHeightMajorUnitString())
                            .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                            .accessibility(identifier: "text_physiologyinformationview_heightmajor")

                    }
                }
                
                if isEditing == false {
                    if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                        if modelData.unitsChanged == "0" {
                        }
                        else {
                            Text(modelData.userPrefsData.getUserHeightIn())
                                .frame(width: 40, height: 40)
                                .multilineTextAlignment(.center)
                                .background(
                                    RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                        .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                )
                                .disabled(true)
                                .padding(.leading, 40)
                                .accessibility(identifier: "text_physiologyinformationview_heightin")

                        }
                    }
                }
                else {
                    if modelData.unitsChanged == "0" {
                    }
                    else {
                        Picker("", selection: $heightIn.onChange(unitsHeightInChanged)) {
                            ForEach(userHeightInchPickerData, id: \.self) {
                                Text(String($0)).tag($0)
                            }
                        }
                        .accentColor(Color.gray)
                        .pickerStyle(.menu)
                        .accessibility(identifier: "picker_physiologyinformationview_heightin")

                    }
                }
                
                if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                    if showOKCancelOption == true {
                        if modelData.unitsChanged == "1" {
                            Text(modelData.userPrefsData.getUserHeightMinorUnitString())
                                .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                                .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                                .accessibility(identifier: "text_physiologyinformationview_heightminor_imperial")

                        }
                    }
                    else {
                        if modelData.unitsChanged == "1" {
                            Text(modelData.userPrefsData.getUserHeightMinorUnitString())
                                .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                                .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                                .accessibility(identifier: "text_physiologyinformationview_heightminor_metric")

                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, showOKCancelOption ? 60 : 0)
            
            HStack {
                if showOKCancelOption == true {
                    Text("Weight:")
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .frame(width: 80, alignment: .leading)
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_weight")

                }
                else {
                    Text("Weight:")
                        .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .frame(width: 80, alignment: .leading)
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_weight")

                }

                if isEditing == false {
                    if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                        Text(modelData.userPrefsData.getUserWeight())
                            .frame(width: 80, height: 40)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            )
                            .disabled(true)
                            .accessibility(identifier: "text_physiologyinformationview_weight_value")

                    }
                }
                else {
                    if modelData.unitsChanged == "1" {
                        TextField("", text: $weight)
                            .onAppear() {
                                weight = modelData.userPrefsData.getUserWeight()
                            }
                            .onReceive(weight.publisher.collect()) {
                                weight = String($0.prefix(3))
                                
                                let weightInLb = Int(weight) ?? 0
                                if weightInLb < 50 {
                                    showWeightOutOfBoundsAlert = true
                                }
                                else {
                                    showWeightOutOfBoundsAlert = false
                                }
                                
                                currentWeightValue = weight
                            }
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            ).padding()
                            .autocorrectionDisabled(true)
                            .frame(width: 100, height: 40, alignment: .center)
                            .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(.leading, 5)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }.tint(.blue)
                                }
                            }
                            .accessibility(identifier: "textfield_physiologyinformationview_weight")

                    }
                    else {
                        TextField("", text: $weight)
                            .onAppear() {
                                weight = modelData.userPrefsData.getUserWeight()
                            }
                            .onReceive(weight.publisher.collect()) {
                                weight = String($0.prefix(3))
                                
                                let weightInKg = Int(weight) ?? 0
                                if weightInKg < 23 {
                                    showWeightOutOfBoundsAlert = true
                                }
                                else {
                                    showWeightOutOfBoundsAlert = false
                                }

                                currentWeightValue = weight
                            }
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            ).padding()
                            .autocorrectionDisabled(true)
                            .frame(width: 100, height: 40, alignment: .center)
                            .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(.leading, 5)
                            .keyboardType(.numberPad)
                            .accessibility(identifier: "textfield_physiologyinformationview_weight")

                    }
                }
                
                if modelData.unitsChanged == "1" || modelData.unitsChanged == "0" {
                    if showOKCancelOption == true {
                        Text(modelData.userPrefsData.getUserWeightString())
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                            .accessibility(identifier: "text_physiologyinformationview_weight_value")

                    }
                    else {
                        Text(modelData.userPrefsData.getUserWeightString())
                            .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Oswald-Regular", size: settingsHeaderTextFontSize))
                            .accessibility(identifier: "text_physiologyinformationview_weight_value")

                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                if showOKCancelOption == true {
                    Text("Sex:")
                        .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .frame(width: 80, alignment: .leading)
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_sex")

                }
                else {
                    Text("Sex:")
                        .foregroundColor(showHeader == false ? Color(UIColor.lightGray) : Color(hex: generalCHAppColors.settingsColorCoalText))
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom("Roboto-Regular", size: settingsInfoTextFontSize))
                        .frame(width: 80, alignment: .leading)
                        .padding(.leading, 40)
                        .accessibility(identifier: "text_physiologyinformationview_sex")

                }
                
                if isEditing == false {
                    VStack {
                        TextField("", text: $gender)
                            .frame(width: 90, height: 40)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                                    .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                            )
                            .disabled(true)
                            .accessibility(identifier: "textfield_physiologyinformationview_gender")

                        Text("Assigned at birth.")
                            .foregroundColor(showOKCancelOption == false ? Color.gray : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Roboto-Bold", size: 10))
                            .accessibility(identifier: "text_physiologyinformationview_birth")

                    }
                    .padding(.top, 0)
                    .padding(.leading, languageCode == "ja" ? 0 : 0)
                }
                else {
                    VStack {
                        Picker(selection: $gender.onChange(unitsGenderChanged), label: Text(gender)) {
                            ForEach(genderList, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .frame(width: 100, height: 30, alignment: .leading)
                        .accentColor(Color.gray)
                        .padding(.leading, 5)
                        .pickerStyle(.menu)
                        .accessibility(identifier: "picker_physiologyinformationview_gender")

                        Text("Assigned at birth.")
                            .foregroundColor(showOKCancelOption == false ? Color.gray : Color(hex: generalCHAppColors.settingsColorCoalText))
                            .font(.custom("Roboto-Bold", size: 10))
                            .accessibility(identifier: "text_physiologyinformationview_assigned")

                    }
                    .padding(.leading, languageCode == "ja" ? 10 : 5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if showHeader == false {
                Picker(selection: $modelData.unitsChanged.onChange(unitsChanged), label: Text("")) {
                    Text("METRIC").tag("0")
                    Text("IMPERIAL").tag("1")
                }
                .pickerStyle(.segmented)
                .padding(.top, 40)
                .padding(.trailing, 20)
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(identifier: "picker_physiologyinformationview_metrics")

            }
            
                
            if showHeightCmOutOfBoundsAlert == true {
                Text("Height must be between 125cm and 212cm")
                    .font(.custom("Roboto-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.red)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_physiologyinformationview_height_values")

            }

            if showWeightOutOfBoundsAlert == true {
                Text("Weight must be greater than 50lbs or 23kg")
                    .font(.custom("Roboto-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.red)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .accessibility(identifier: "text_physiologyinformationview_weight_values")

            }

            if showOKCancelOption == true {
                
                Spacer()
                
                HStack {
                    Button(action: {
                        if modelData.unitsChanged == "0" {
                            let cm = UInt16(heightCm) ?? 0
                            if cm < 125 || cm > 212 {
                                showHeightCmOutOfBoundsAlert = true
                                return
                            }
                            else {
                                showHeightCmOutOfBoundsAlert = false
                            }
                            
                            let weightInKg = Int(weight) ?? 0
                            if weightInKg < 23 {
                                showWeightOutOfBoundsAlert = true
                            }
                            else {
                                showWeightOutOfBoundsAlert = false
                            }
                            
                        }
                        else {
                            let weightInLb = Int(weight) ?? 0
                            if weightInLb < 50 {
                                showWeightOutOfBoundsAlert = true
                                return
                            }
                            else {
                                showWeightOutOfBoundsAlert = false
                            }
                        }

                        if oldUserHeightFeet != modelData.userPrefsData.getUserHeightInFt() || oldUserHeightInch != modelData.userPrefsData.getUserHeightIn() ||  oldUserWeight != weight || oldUserGender != (gender == String(localized: "Male") ? "M" : "F") || oldUserHeightCm != heightCm {
                            showPhysiologyConfirmAlert = true
                        }
                        else {
                            isPhysiologyShowing = false
                            self.presentation.wrappedValue.dismiss()
                        }
                    }) {
                        Text("OK")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 100, height: 20)
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                .shadow(color: .gray, radius: 1, x: 0, y: 2))
                            .accessibility(identifier: "text_physiologyinformationview_ok")

                    }
                    .alert(isPresented: $showPhysiologyConfirmAlert) {
                        Alert(
                            title: Text("Confirm"),
                            message: Text("Are you sure you want to update your physiology information?"),
                            primaryButton: .destructive(Text("Cancel"), action: {
                                isPhysiologyShowing = false
                                self.presentation.wrappedValue.dismiss()
                            }),
                            secondaryButton: .default(Text("OK"), action: {
                                                                
                                modelData.userPrefsData.setUserWeight(weight: weight)
                                modelData.userPrefsData.setUserGender(gender: gender == String(localized: "Male") ? "M" : "F")
                                
                                if (oldUserHeightFeet == "0" && heightFt == 2) {
                                    modelData.userPrefsData.setUserHeightCm(cm: 183)
                                    modelData.userPrefsData.setUserHeightFeet(feet: "6")
                                }

                                if modelData.unitsChanged == "0" {
                                    modelData.userPrefsData.setUserHeightCm(cm: UInt8(heightCm) ?? 175)
                                    
                                    let heightInInches = (Double(modelData.userPrefsData.getUserHeightCm()) ?? 175) / 2.54

                                    let heightFeet = "\(Int(heightInInches / 12.0))"
                                    let heightInch = "\(Int(round(heightInInches.truncatingRemainder(dividingBy: 12.0))))"

                                    modelData.userPrefsData.setUserHeightInch(inches: heightInch)
                                    modelData.userPrefsData.setUserHeightFeet(feet: heightFeet)
                                    
                                    // Update new values to server side
                                    let userInfo = [/*"firstName": "", "lastName": "",*/ "height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                                    modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                                    modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: weight, gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
                                }
                                
                                else {
                                    
                                    let userHeightInInches : UInt8 = UInt8(round((Double(modelData.userPrefsData.getUserHeightInFt()) ?? 5))) * 12 + UInt8(round((Double(modelData.userPrefsData.getUserHeightIn()) ?? 9)))
                                    let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))

                                    modelData.userPrefsData.setUserHeightCm(cm: userHeightInCms)
                                    
                                    // Update new values to server side
                                    let userInfo = [/*"firstName": "", "lastName": "",*/ "height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                                    modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                                    modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: weight, gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
                                }
                                
                                isPhysiologyShowing = false
                                self.presentation.wrappedValue.dismiss()
                            })
                        )
                    }
                    .accessibility(identifier: "button_physiologyinformationview_ok")

                    Spacer()
                    
                    Button(action: {
                        isPhysiologyShowing = false
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("CANCEL")
                            .font(.custom("Oswald-Regular", size: 18))
                            .frame(width: 100, height: 20)
                            .foregroundColor(Color(hex: generalCHAppColors.settingsColorCoalText))
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: generalCHAppColors.settingsColorHydroDarkText), lineWidth: 1)
                                .shadow(color: .gray, radius: 1, x: 0, y: 2))
                            .accessibility(identifier: "text_physiologyinformationview_cancel")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                .padding(.bottom, 60)
                .accessibility(identifier: "button_physiologyinformationview_cancel")

            }
        }
        .onAppear() {
            
            let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

            if (languageCode == "ja") {
                modelData.bottle_list = load("preset_bottle_list_jap.json")
            }
            else if modelData.userPrefsData.useUnits == "1" {
                modelData.bottle_list = load("preset_bottle_list.json")
            }
            
            else {
                modelData.bottle_list = load("preset_bottle_list_metric.json")
            }
            
            oldUserHeightFeet = modelData.userPrefsData.getUserHeightInFt()
            oldUserHeightInch = modelData.userPrefsData.getUserHeightIn()
            oldUserHeightCm = modelData.userPrefsData.getUserHeightCm()
            oldUserWeight = modelData.userPrefsData.getUserWeight()
            oldUserGender = modelData.userPrefsData.getUserGender()
            
            // Only enable notification handling after onboarding is complete
            if(showHeader) {
                if (notificationSweatUserInfoSetResponse == nil) {
                    notificationSweatUserInfoSetResponse = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SweatUserInfoSetResponse), object: nil, queue: OperationQueue.main) {_ in self.updateUserInfoSetStatus() }
                }
                
                if (notificationSensorFwSysInfoPayload == nil) {
                    notificationSensorFwSysInfoPayload = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: RCNotifications.SensorFwSysInfoPayload), object: nil, queue: OperationQueue.main) { notification in self.updateUserInfo() }
                }
            }
            
            // Guard against empty weight
            if weight == "" {
                weight = "165"
            }

            // Guard against empty weight
            if heightCm == "" {
                heightCm = "175"
            }

            heightCm = modelData.userPrefsData.getUserHeightCm()
            weight = modelData.userPrefsData.getUserWeight()
            heightFt = modelData.userPrefsData.getUserHeightFtIndex()
            heightIn = modelData.userPrefsData.getUserHeightInchesIndex()
            gender = modelData.userPrefsData.getUserGender() == "M" ? String(localized: "Male") : String(localized: "Female")
            
            // Check sensor firmware revision and user info
            guard BLEManager.bleSingleton.sensorConnected == true else { return }
            guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
            
            let sensorFirmwareRev = Data(hexString: "50")
            peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
            peripheralConnected.writeValue(sensorFirmwareRev!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
            
        }
        .onDisappear() {
            modelData.userPrefsData.useUnits = modelData.unitsChanged

            NotificationCenter.default.removeObserver(self)

            // User onboarding - store off for later
            if ((showHeader == false) && (showOKCancelOption == false)) {
                
                modelData.userPrefsData.setUserGender(gender: gender == String(localized: "Male") ? "M" : "F")
                modelData.userPrefsData.setUserWeight(weight: weight)
                //modelData.userPrefsData.setUserHeightCm(cm: UInt8(heightCm) ?? 0)

                if modelData.unitsChanged == "0" {
                    modelData.userPrefsData.setUserHeightCm(cm: UInt8(heightCm) ?? 175)
                    
                    let heightInInches = (Double(modelData.userPrefsData.getUserHeightCm()) ?? 175) / 2.54

                    let heightFeet = "\(Int(heightInInches / 12.0))"
                    let heightInch = "\(Int(round(heightInInches.truncatingRemainder(dividingBy: 12.0))))"

                    modelData.userPrefsData.setUserHeightInch(inches: heightInch)
                    modelData.userPrefsData.setUserHeightFeet(feet: heightFeet)
                    
                    // Update new values to server side
                    let userInfo = [/*"firstName": "", "lastName": "",*/ "height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                    modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                    modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: weight, gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
                }
                
                else {
                    
                    let userHeightInInches : UInt8 = UInt8(round((Double(modelData.userPrefsData.getUserHeightInFt()) ?? 5))) * 12 + UInt8(round((Double(modelData.userPrefsData.getUserHeightIn()) ?? 9)))
                    let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))

                    modelData.userPrefsData.setUserHeightCm(cm: userHeightInCms)
                    
                    // Update new values to server side
                    let userInfo = [/*"firstName": "", "lastName": "",*/ "height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
                    modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)

                    modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: weight, gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
                }
                return
            }
        }
    }
    
    func updateUserInfo() {
        modelData.UserSubjectID = BLEManager.bleSingleton.subjectID

        let localweightKg = UInt16(modelData.userPrefsData.getUserWeightKg()) ?? 0
        //let localweightLb = modelData.userPrefsData.getUserWeightLb()
        let localGender = modelData.userPrefsData.getUserGender()
        let localHeightCm = UInt8(modelData.userPrefsData.getUserHeightCm()) ?? 0
        let localHeightIn = modelData.userPrefsData.getUserHeightIn()
        let localHeightFt = modelData.userPrefsData.getUserHeightInFt()
        //let clothTypeCode = clothingList.firstIndex(of: clothing) ?? 0

        let weightRange = ((BLEManager.bleSingleton.subjectWeightInKg == 0) ? 0 : BLEManager.bleSingleton.subjectWeightInKg-1)...BLEManager.bleSingleton.subjectWeightInKg+1
        let heightRange = ((BLEManager.bleSingleton.subjectHeightInCm == 0) ? 0 : BLEManager.bleSingleton.subjectHeightInCm-1)...BLEManager.bleSingleton.subjectHeightInCm+1

        let deviceHeightIn = BLEManager.bleSingleton.subjectHeightInch.isEmpty ? "0" : BLEManager.bleSingleton.subjectHeightInch
        let deviceHeightFt = BLEManager.bleSingleton.subjectHeightFeet.isEmpty ? "0" : BLEManager.bleSingleton.subjectHeightFeet

        //print(modelData.userPrefsData.getUserHeightInFt() + " " + modelData.userPrefsData.getUserHeightIn() + " " + modelData.userPrefsData.getUserWeightLb() + " " + modelData.userPrefsData.getUserWeightKg() + " " + modelData.userPrefsData.getUserGender())
        
        //print(BLEManager.bleSingleton.subjectGender + " \(BLEManager.bleSingleton.subjectWeightInKg)")
        //print("\(BLEManager.bleSingleton.subjectHeightInCm) " + BLEManager.bleSingleton.subjectHeightInch)
        //print(BLEManager.bleSingleton.subjectHeightFeet)

        // If local values do not match device, then update device values
        if (!weightRange.contains(localweightKg) || localGender != BLEManager.bleSingleton.subjectGender || !heightRange.contains(localHeightCm) || localHeightIn != deviceHeightIn || localHeightFt != deviceHeightFt) {
            
            if modelData.unitsChanged == "0" {
                modelData.ebsMonitor.saveUserInfoMetric(heightInCm: modelData.userPrefsData.getUserHeightCm(), weightInKg: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
            }
            
            else {
                modelData.ebsMonitor.saveUserInfo(feet: modelData.userPrefsData.getUserHeightInFt(), inches: modelData.userPrefsData.getUserHeightIn(), weight: modelData.userPrefsData.getUserWeight(), gender: modelData.userPrefsData.getUserGender() == "M" ? "Male" : "Female", clothTypeCode: 0)
            }
//            modelData.ebsMonitor.saveUserInfo(feet: localHeightFt, inches: localHeightIn, weight: modelData.userPrefsData.getUserWeightLb(), gender: localGender == "M" ? "Male" : "Female", clothTypeCode: clothTypeCode)

        }
        
        // Retry if update user API fails
        if (modelData.userUpdateAPIFailure) {
            modelData.userUpdateAPIFailure = false
            // Update new values to server side
            let userInfo = [/*"firstName": "", "lastName": "",*/ "height": modelData.userPrefsData.getUserHeightCm(), "weight": modelData.userPrefsData.getUserWeightNetwork(), "biologicalSex": modelData.userPrefsData.getUserGender() == "M" ? "male" : "female"] as [String : Any]
            modelData.networkManager.updateUser(enterpriseId: modelData.jwtEnterpriseID, siteId: modelData.jwtSiteID, userInfo: userInfo)
        }
        
/*
        modelData.userPrefsData.setUserHeightCm(cm: BLEManager.bleSingleton.subjectHeightInCm)
        modelData.userPrefsData.setUserHeightInch(inches: BLEManager.bleSingleton.subjectHeightInch)
        modelData.userPrefsData.setUserHeightFeet(feet: BLEManager.bleSingleton.subjectHeightFeet)
        modelData.userPrefsData.setUserWeightFromSensor(weightInKg: BLEManager.bleSingleton.subjectWeightInKg)

//        weight = BLEManager.bleSingleton.subjectWeight
        weight = modelData.userPrefsData.getUserWeight()
        
        if BLEManager.bleSingleton.subjectGender == "M" {
            gender = "Male"
        }
        else {
            gender = "Female"
        }
        
        modelData.UserGender = gender == "Male" ? "M" : "F"
*/
        if(modelData.unitsChanged == "1") {
            print(modelData.userPrefsData.getUserHeightInFt() + " " + modelData.userPrefsData.getUserHeightIn() + " " + modelData.userPrefsData.getUserWeight() + " " + modelData.userPrefsData.getUserGender())
        }
        else {
            print(modelData.userPrefsData.getUserHeightCm() + " "  + modelData.userPrefsData.getUserWeight() + " " + modelData.userPrefsData.getUserGender())
        }
    }
    
    func updateUserInfoSetStatus() {
        
        modelData.deviceUserInfoFailed = false
        
        // Check sensor firmware revision and user info
        guard BLEManager.bleSingleton.sensorConnected == true else { return }
        guard let peripheralConnected = BLEManager.bleSingleton.peripheralToConnect else { return }
        
        let sensorFirmwareRev = Data(hexString: "50")
        peripheralConnected.setNotifyValue(true, for: BLEManager.bleSingleton.rxCharacteristic!)
        peripheralConnected.writeValue(sensorFirmwareRev!, for: BLEManager.bleSingleton.txCharacteristic!, type: .withoutResponse)
    }
    
    func unitsChanged(_ tag: String) {
        //print("tag: \(tag)")
        weight = modelData.userPrefsData.setUserWeight(weight: weight, units: Int(tag)!)
        modelData.unitsChanged = tag
        modelData.userPrefsData.useUnits = tag
        
        if modelData.userPrefsData.useUnits == "1" {
//            let heightInInches = Double(modelData.userPrefsData.getUserHeightCm())! / 2.54
            
            if (Int(heightCm) ?? 175) < 125 {
                heightCm = "125"
            }
            
            if (Int(heightCm) ?? 175) > 212 {
                heightCm = "212"
            }
            
            let heightInInches = (Double(heightCm) ?? 175) / 2.54
            
            let heightFeet = "\(Int(heightInInches / 12.0))"
            let heightInch = "\(Int(round(heightInInches.truncatingRemainder(dividingBy: 12.0))))"
            
            modelData.userPrefsData.setUserHeightInch(inches: heightInch)
            modelData.userPrefsData.setUserHeightFeet(feet: heightFeet)
            
            heightFt = modelData.userPrefsData.getUserHeightFtIndex()
            heightIn = modelData.userPrefsData.getUserHeightInchesIndex()
            
        }
        
        else {
            let userHeightInInches : UInt8 = UInt8(round(Double(modelData.userPrefsData.getUserHeightInFt()) ?? 5 )) * 12 + UInt8(round(Double(modelData.userPrefsData.getUserHeightIn()) ?? 9))
            let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))
            
            modelData.userPrefsData.setUserHeightCm(cm: userHeightInCms)
            
            heightCm = modelData.userPrefsData.getUserHeightCm()
        }
        
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        if (languageCode == "ja") {
            modelData.bottle_list = load("preset_bottle_list_jap.json")
        }
        else if modelData.userPrefsData.useUnits == "1" {
            modelData.bottle_list = load("preset_bottle_list.json")
        }
        else {
            modelData.bottle_list = load("preset_bottle_list_metric.json")
        }
        
    }
    
    func unitsHeightFtChanged(_ tag: Int) {
        //print("height ft tag: \(tag)")
        if tag == 0 {
            modelData.userPrefsData.setUserHeightFeet(feet: "4")
        }
        else if tag == 1 {
            modelData.userPrefsData.setUserHeightFeet(feet: "5")
        }
        else {
            modelData.userPrefsData.setUserHeightFeet(feet: "6")
        }
        
        // Update cm
        let userHeightInInches : UInt8 = UInt8(round((Double(modelData.userPrefsData.getUserHeightInFt()) ?? 5))) * 12 + UInt8(round((Double(modelData.userPrefsData.getUserHeightIn()) ?? 9)))
        let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))
        modelData.userPrefsData.setUserHeightCm(cm: userHeightInCms)
    }

    func unitsHeightInChanged(_ tag: Int) {
        //print("height in tag: \(tag)")
        modelData.userPrefsData.setUserHeightInch(inches: String(tag))
        let userHeightInInches : UInt8 = UInt8(round((Double(modelData.userPrefsData.getUserHeightInFt()) ?? 5))) * 12 + UInt8(round((Double(modelData.userPrefsData.getUserHeightIn()) ?? 9)))
        let userHeightInCms : UInt8 = UInt8(round(Double(userHeightInInches)*2.54))
        modelData.userPrefsData.setUserHeightCm(cm: userHeightInCms)
    }
    
    func unitsGenderChanged(_ tag: String) {
        modelData.userPrefsData.setUserGender(gender: tag == String(localized: "Male") ? "M" : "F")
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: super.intrinsicContentSize.height
        )
    }
}
