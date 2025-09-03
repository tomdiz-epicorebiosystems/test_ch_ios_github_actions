//
//  TriangleShape.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/1/23.
//

import SwiftUI

struct Triangle : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}
