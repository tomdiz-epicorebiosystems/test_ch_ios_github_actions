//
//  ComplianceView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/13/23.
//

import SwiftUI

struct ComplianceView: View {

    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentation

    var body: some View {
        ZStack {
            BgStatusView() {}
            VStack {
                Text("FCC COMPLIANCE")
                    .foregroundColor(Color.gray)
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("Oswald-SemiBold", size: settingsTitleFontSize))

                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1.0)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ComplianceTextView()
                    }
                    .padding(.bottom, 10)
                }
                .clipped()
            }
            .background(RoundedCorners(color: .white, tl: 10, tr: 10, bl: 10, br: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 60)
            .padding(.top, 50)
        }
        .trackRUMView(name: "ComplianceView")
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading:
            Button(action : {
                self.presentation.wrappedValue.dismiss()
            }){
                HStack {
                    Text("< LEGAL &\n REGULATORY")
                        .font(.custom("Oswald-Regular", size: 12))
                        .foregroundColor(Color(hex: generalCHAppColors.linkStandardText))
                }
            }
            .trackRUMTapAction(name: "tap_back_compliance_view")
        )
    }
}

struct ComplianceTextView: View {
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        Text("Compliance Statements")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("Any modifications made to this device that are not approved by Epicore Biosystems, Inc. may void the authority granted to the user by the FCC to operate equipment.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("For Class B - Unintentional Radiators:")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        Text("This device complies with Part 15 of the FCC Rules. Operation is subject to the following two conditions: (1) this device may not cause harmful interference and (2) this device must accept any interference received, including interference that may cause undesired operation.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        MoreComplianceView()
    }
}

struct MoreComplianceView: View {
    var body: some View {
        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("ICES-003 Class B Notice—Avis NMB-003, Class B This Class B digital apparatus complies with Canadian ICES-003.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("Note: This equipment has been tested and found to comply with the limits for a Class B digital device, pursuant to Part 15 of the FCC Rules. These limits are designed to provide reasonable protection against harmful interference in a residential installation. This equipment generates, uses, and can radiate radio frequency energy and, if not installed and used in accordance with the instructions, may cause harmful interference to radio communications. However, there is no guarantee that interference will not occur in a particular installation. If this equipment does cause harmful interference to radio or television reception, which can be determined by turning the equipment off and on, the user is encouraged to try to correct the interference by one or more of the following measures:")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("• Reorient or relocate the receiving antenna")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 40)
            .padding(.trailing, 20)

        Text("• Increase the separation between the equipment and receiver")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 40)
            .padding(.trailing, 20)

        Text("• Connect the equipment into an outlet on a circuit different from that to which the receiver is connected")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 40)
            .padding(.trailing, 20)

        Text("• Consult the dealer or an experienced radio/TV technician for help")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 40)
            .padding(.trailing, 20)

        Text("RADIATION HAZARD")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        EvenMoreComplianceView()
    }
}

struct EvenMoreComplianceView: View {
    var body: some View {
        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("In order to satisfy the FCC/ISED RF exposure limit for transmitting devices, a separation distance of 20cm (7.8 inches) or more should be maintained while operating the Connected Hydration. To ensure compliance, operations at closer than this distance are not recommended. This minimum safe distance is required between personnel and this antenna of this device.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("This device complies with Industry Canada license-exempt RSS standard(s). Operation is subject to the following two conditions: (1) this device may not cause interference, and (2) this device must accept any interference, including interference that may cause undesired operation of the device.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("Le présent appareil est conforme aux CNR d’Industrie Canada applicables aux appareils radio exempts de licence. L’exploitation est autorisée aux deux conditions suivantes: (1) l’appareil ne doit pas produire de brouillage, et (2) l’utilisateur de l’appareil doit accepter tout brouillage radioélectrique subi, même si le brouillage est susceptible d’en compromettre le fonctionnement.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("This radio transmitter the Connected Hydration has been approved by Industry Canada to operate with the antenna types listed below with the maximum permissible gain and required antenna impedance for each antenna type indicated. Antenna types not included in this list, having a gain greater than the maximum gain indicated for that type, are strictly prohibited for use with this device.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("Le présent émetteur radio (Connected Hydration) a été approuvé par Industrie Canada pour fonctionner avec les types d’antenne énumérés ci-dessous et ayant un gain admissible maximal et l’impédance requise pour chaque type d’antenne. Les types d’antenne non inclus dans cette liste, ou dont le gain est supérieur au gain maximal indiqué, sont strictement interdits pour l’exploitation de l’émetteur.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("• Type of antenna")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        EvenEvenMoreComplianceView()
    }
}

struct EvenEvenMoreComplianceView: View {
    var body: some View {
        Text("ATTENTION")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("Under Industry Canada regulations, this radio transmitter may only operate using an antenna of a type and maximum (or lesser) gain approved for the transmitter by Industry Canada. To reduce potential radio interference to other users, the antenna type and its gain should be so chosen that the equivalent isotropically radiated power (e.i.r.p.) is not more than that necessary for successful communication. Conformément à la réglementation d’Industrie Canada, le présent émetteur radio peut fonctionner avec une antenne d’un type et d’un gain maximal (ou inférieur) approuvé pour l’émetteur par Industrie Canada. Dans le but de réduire les risques de brouillage radioélectrique à l’intention des autres utilisateurs, il faut choisir le type d’antenne et son gain de sorte que la puissance isotrope rayonnée équivalente (p.i.r.e.) ne dépasse pas l’intensité nécessaire à l’établissement d’une communication satisfaisante.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("WARNING")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("There is danger of explosion if batteries are mishandled or incorrectly replaced. On systems with replaceable batteries, replace only with the same manufacturer and type or equivalent type recommended per the instructions provided in the product service manual.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

         Text("Do not disassemble batteries or attempt to recharge them outside the system. Do not dispose of batteries in fire.")
            .font(.custom("Roboto-Regular", size: 18))
             .frame(maxWidth: .infinity, alignment: .leading)
             .foregroundColor(Color.gray)
             .padding(.top, 5)
             .padding(.bottom, 5)
             .padding(.leading, 20)
             .padding(.trailing, 20)

        Text("Dispose of batteries properly in accordance with the manufacturer’s instructions and local regulations.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)

        Text("WARNING")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        Text("DO NOT INCINERATE or subject battery cells to temperatures in excess of 212°F. Such treatment can cause cell rupture.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("WARNING")
            .font(.custom("Roboto-Regular", size: 18))
            .foregroundColor(Color.black)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.leading, 20)

        EvenEvenEvenMoreComplianceView()
    }
}

struct EvenEvenEvenMoreComplianceView: View {
    var body: some View {
        Text("EXPLOSION HAZARD - BATTERIES MUST ONLY BE CHANGED IN AN AREA KNOW TO BE NON-HAZARDOUS.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        Text("AVERTISSEMENT-RISQUE D’EXPLOSION - AFIN D’ÉVITER TOUT RISQUE D’EXPLOSION, S’ASSURER QUE L’EMPLACEMENT EST DÉSIGNÉ NON DANGEREUX AVANT DE CHANGER LA BATTERIE.")
            .font(.custom("Roboto-Regular", size: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }
}
