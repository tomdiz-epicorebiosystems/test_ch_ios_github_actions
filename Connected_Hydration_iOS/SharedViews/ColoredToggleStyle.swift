//
//  ColoredToggleStyle.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI

struct ColoredToggleStyle: ToggleStyle {
    var label = ""
    var labelFontSize = 14.0
    var onColor = Color(UIColor.green)
    var offColor = Color(UIColor.systemGray5)
    var thumbColor = Color.white
    var isShowHeading = true
    var fixedHorz = false
    var fixedVert = true

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Text(label)
                .foregroundColor(isShowHeading ? Color(hex: generalCHAppColors.settingsColorCoalText) : .white)
                .fixedSize(horizontal: fixedHorz, vertical: fixedVert)
                .font(.custom("Roboto-Regular", size: labelFontSize))

            Spacer()
            Button(action: { configuration.isOn.toggle() } )
            {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(thumbColor)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(1.5)
                            .offset(x: configuration.isOn ? 10 : -10))
                    .animation(Animation.easeInOut(duration: 0.1), value: 1.0)
            }
        }
        .padding(.horizontal)
    }
}
