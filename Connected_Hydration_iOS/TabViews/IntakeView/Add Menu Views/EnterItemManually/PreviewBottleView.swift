//
//  PreviewBottleView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/21/23.
//

import SwiftUI

import SwiftUI

struct PreviewBottleView: View {
    
    var image: String?
    @Binding var updateImage: String
    @Binding var selectedPreviewImageButton: Int
    var buttonIdx: Int?

    var body: some View {
        Button {
            if image != "static" {
                self.updateImage = image!
                self.selectedPreviewImageButton = buttonIdx!
            }
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
        } label: {
            if image?.isEmpty == false {
                Image(image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            }
        }
        .frame(width: 100, height: 100)
        .border(buttonIdx != selectedPreviewImageButton ? Color.clear : Color("AccentColor"), width: 4)
        .cornerRadius(10)
        .disabled(updateImage == "static" ? true : false)
        .background(RoundedRectangle(cornerRadius: 10).fill(RadialGradient(gradient: Gradient(colors: [Color(UIColor.lightGray), .gray]), center: .bottomTrailing, startRadius: 0, endRadius: 100))
            .opacity(image?.isEmpty == false ? 1.0 : 0.2))
    }
}
