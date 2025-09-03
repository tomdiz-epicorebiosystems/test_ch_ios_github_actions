//
//  NetworkProgressView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/19/23.
//

import SwiftUI

struct NetworkProgressView: View {

    @State private var isRotating = 0.0

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("Progress Spinner")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .rotationEffect(.degrees(isRotating))
                    .onAppear {
                        withAnimation(.linear(duration: 1)
                            .speed(0.1).repeatForever(autoreverses: false)) {
                                isRotating = 360.0
                            }
                    }
                
                Text("VERIFYING...")
                    .font(.custom("Oswald-Regular", size: 24))
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(UIColor.white))
                
                Spacer()
            }
            //.zIndex(0)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all))
    }
}
