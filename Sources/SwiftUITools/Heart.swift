//
//  File.swift
//  
//
//  Created by mayong on 2024/6/17.
//

import SwiftUI

public struct Heart: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let sideOne = rect.width * 0.4
        let sideTwo = rect.height * 0.3
        let arcRadius = sqrt(sideOne * sideOne + sideTwo * sideTwo) / 2

        //Left Hand Curve
        path.addArc(
            center: CGPoint(x: rect.width * 0.3, y: rect.height * 0.4),
            radius: arcRadius,
            startAngle: Angle(degrees: 135),
            endAngle: Angle(degrees: 315),
            clockwise: false
        )

        //Top Centre Dip
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height * 0.25))

        //Right Hand Curve
        path.addArc(
            center: CGPoint(x: rect.width * 0.7, y: rect.height * 0.4),
            radius: arcRadius,
            startAngle: Angle(degrees: 225),
            endAngle: Angle(degrees: 45),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.9))
        path.closeSubpath()
        return path
    }
}
