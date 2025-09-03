//
//  RecommendedIntakePieView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/23/23.
//

import SwiftUI

struct RecommendedIntakePieView: View {
    public var innerRadiusFraction = 0.5
    public var endAngle: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // Gray 360 in background
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    
                    path.move(to: center)
                    
                    path.addArc(
                        center: center,
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + Angle(degrees: 0.0),
                        endAngle: Angle(degrees: -90.0) + Angle(degrees: 360.0),
                        clockwise: false)
                    
                }
                .fill(Color.gray)

                // Black - adjust to percent of intake
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    
                    path.move(to: center)
                    
                    path.addArc(
                        center: center,
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + Angle(degrees: 0.0),
                        endAngle: Angle(degrees: -90.0) + Angle(degrees: endAngle),
                        clockwise: false)
                    
                }
                .fill(Color.black)

                Circle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)

            }
        }
        .trackRUMView(name: "RecommendedIntakePieView")
        .aspectRatio(1, contentMode: .fit)
    }
}

struct RecommendedIntakePieView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedIntakePieView(endAngle: 220.0)
    }
}
