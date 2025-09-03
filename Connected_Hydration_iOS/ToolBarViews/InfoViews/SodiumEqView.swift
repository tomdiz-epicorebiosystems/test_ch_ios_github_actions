//
//  SodiumEqView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/2/23.
//

import SwiftUI

struct SodiumEqView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var currInfoScreen: InfoScreen
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        
        ScrollViewReader { sp in
            
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack {
                    TopSodiumEqView()
                    
                    HStack (spacing: 5) {
                        Image("Info Sodium Eq - Burger")
                            .padding(.top, 20)
                            .padding(.leading, 15)
                        
                        VStack {
                            Text("ONE BIG MAC")
                                .font(.custom("Oswald-Regular", size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("1,010mg")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.leading, 15)
                    }
                    
                    HStack (spacing: 5) {
                        Image("Info Sodium Eq - Pizza")
                            .padding(.leading, 15)
                        
                        VStack {
                            Text("ONE MEDIUM DOMINO'S\nPEPPERONI PIZZA")
                                .font(.custom("Oswald-Regular", size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("1,020mg")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 15)
                        .padding(.leading, 15)
                    }
                    
                    HStack (spacing: 5) {
                        Image("Info Sodium Eq - Fries")
                            .padding(.leading, 15)
                        
                        VStack {
                            Text("2-1/2 LARGE MCDONALD'S\nFRIES")
                                .font(.custom("Oswald-Regular", size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("400mg each")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 15)
                        .padding(.leading, 15)
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                    
                    HStack (spacing: 20) {
                        VStack {
                            Text("We need\nsodium for:")
                                .font(.system(size: languageCode == "ja" ? 20 : 24))
                                .foregroundColor(Color(hex: "#68C5EA"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Text("Balancing the\nbody's fluid levels")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Text("Digestion")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Text("Nerve function")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Text("Muscle control")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Spacer()
                        }
                        
                        VStack {
                            Text("But too much\ncan lead to:")
                                .font(.system(size: languageCode == "ja" ? 20 : 24))
                                .foregroundColor(Color(hex: "#68C5EA"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                                .padding(.trailing, 10)
                            
                            Text("High blood pressure")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            
                            Text("Stroke")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Text("Heart disease")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                                .padding(.leading, 20)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.currInfoScreen = .urineColorChart
                    }) {
                        Text("URINE COLOR CHART >")
                            .font(.custom("Oswald-Regular", size: 18))
                            .foregroundColor(Color(.white))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 40)
                            .padding(.bottom, 40)
                    }
                    .trackRUMTapAction(name: "sodiumeq-support")
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

struct TopSodiumEqView: View {

    var body: some View {
        Text("SODIUM EQUIVALENTS")
            .font(.custom("Oswald-Regular", size: 24))
            .foregroundColor(Color(hex: "#68C5EA"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            .padding(.leading, 20)

        HStack {
            Image("Info Sodium Eq - Salt")
                .padding(.top, 20)
                .padding(.leading, 15)

            VStack {
                HStack (spacing: 5) {
                    Text("TABLE SALT")
                        .font(.custom("Oswald-Regular", size: 24))
                        .foregroundColor(.white)

                    Text("(per Mayo Clinic)")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("1 teaspoon = 2,325mg sodium")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 15)
        }
        
        Text("When you *deplete* 1,000mg\nsodium, it roughly equals:")
            .font(.system(size: 24, weight: Font.Weight.bold))
            .foregroundColor(.white)
            .padding(.top, 10)
    }
}
