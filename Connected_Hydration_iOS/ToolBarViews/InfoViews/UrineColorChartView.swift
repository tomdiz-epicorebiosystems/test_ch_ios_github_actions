//
//  UrineColorChartView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct UrineColorChartView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen

    var body: some View {
        VStack {
            Text("URINE COLOR CHART")
                .font(.custom("Oswald-Regular", size: 24))
                .foregroundColor(Color(hex: "#68C5EA"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)

            Text("You can check your hydration level before you complete any physical activity to see if you are starting off dehydrated.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
                .padding(.leading, 20)
                .padding(.trailing, 20)

            Text("• Observe the color of your urine stream, not the toilet water, as the water in the toilet will dilute your urine color.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)

            Text("• Match your urine color to the closest color and its associated hydraion level shown in the chart.")
                .font(.custom("Roboto-Regular", size: 18))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)

            HStack {
                Text("HYDRATED")
                    .font(.custom("Oswald-Medium", size: 24))
                    .foregroundColor(Color.white)
                    .frame(width: 100.0, height: 50.0)
                    .rotationEffect(Angle(degrees: -90))
                    .padding(.trailing, -25)

                VStack {
                    Text("OPTIMAL")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#FAF6D1")))
                        .padding(.bottom, -4)
                    
                    Text("")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#F7F5AE")))
                        .padding(.bottom, -4)
                    
                    Text("WELL HYDRATED")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#F8F299")))
                        .padding(.bottom, -4)
                    
                    Text("")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#F6E32B")))
                        .padding(.bottom, 20)
                }
            }
            .padding(.leading, -15)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("DEHYDRATED")
                    .font(.custom("Oswald-Medium", size: 24))
                    .foregroundColor(Color.white)
                    .frame(width: 140.0, height: 50.0)
                    .rotationEffect(Angle(degrees: -90))
                    .padding(.trailing, -45)

                VStack {
                    Text("DEHYDRATED")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#EDDC5D")))
                        .padding(.bottom, -4)

                    Text("")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#E8C828")))
                        .padding(.bottom, -4)

                    Text("")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(hex:"#4A4A4D"))
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#D2B02A")))
                        .padding(.bottom, -4)

                    Text("SEEK MEDICAL AID")
                        .font(.custom("Oswald-Medium", size: 24))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color.white)
                        .frame(width: 300.0, height: 80.0)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#806729")))
                        .padding(.bottom, -4)
                }
            }
            .padding(.leading, -35)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text("Reference:")
                .font(.custom("Roboto-Regular", size: 12))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

            Text("U.S. Army Public Health Command (provisional)")
                .font(.custom("Roboto-Regular", size: 12))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

            Text("http://phc.amedd.army.mil Cp-070-0510")
                .font(.custom("Roboto-Regular", size: 12))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .padding(.bottom, 40)

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
            .trackRUMTapAction(name: "urinechart-hydrationguide")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex:"#4A4A4D"))
    }
}
