//
//  HighlightButtonStyle.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/14/23.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(.black)
      .frame(width: 330.0, height: 130.0)
      .background(configuration.isPressed ? Color("Button Select Color") : Color("Button Color"))
      .cornerRadius(10.0)
  }

}
