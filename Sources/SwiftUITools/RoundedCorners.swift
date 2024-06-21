//
//  RoundedCorners.swift
//  JokyNote
//
//  Created by mayong on 2023/11/23.
//

import SwiftUI

public struct RoundedCorners: Shape {
    public enum Corner: Sendable {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        var startAngle: Angle {
            switch self {
            case .topRight: return Angle(degrees: -90)
            case .bottomRight: return Angle(degrees: 0)
            case .bottomLeft: return Angle(degrees: 90)
            case .topLeft: return Angle(degrees: 180)
            }
        }
        
        var endAngle: Angle {
            switch self {
            case .topRight: return Angle(degrees: 0)
            case .bottomRight: return Angle(degrees: 90)
            case .bottomLeft: return Angle(degrees: 180)
            case .topLeft: return Angle(degrees: 270)
            }
        }
        
        func drawCorner(
            in size: CGSize,
            radius: CGFloat,
            with path: inout Path
        ) {
            let centerRadius = min(
                min(radius, size.height * 0.5),
                size.width * 0.5
            )
            let startPoint: CGPoint
            let center: CGPoint
            switch self {
            case .topRight:
                startPoint = CGPoint(
                    x: size.width - centerRadius,
                    y: 0
                )
                center = CGPoint(
                    x: size.width - centerRadius,
                    y: centerRadius
                )
            case .bottomRight:
                startPoint = CGPoint(
                    x: size.width,
                    y: size.height - centerRadius
                )
                center = CGPoint(
                    x: size.width - centerRadius,
                    y: size.height - centerRadius
                )
            case .bottomLeft:
                startPoint = CGPoint(
                    x: centerRadius,
                    y: size.height
                )
                center = CGPoint(
                    x: centerRadius,
                    y: size.height - centerRadius
                )
            case .topLeft:
                startPoint = CGPoint(
                    x: 0,
                    y: centerRadius
                )
                center = CGPoint(
                    x: centerRadius,
                    y: centerRadius
                )
            }
            
            path.addLine(to: startPoint)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
    }
    
    public struct CornersRadius: Sendable {
        let topLeft: CGFloat
        let topRight: CGFloat
        let bottomLeft: CGFloat
        let bottomRight: CGFloat
    }
    
    public let cornersRadius: CornersRadius
    public init(cornersRadius: CornersRadius) {
        self.cornersRadius = cornersRadius
    }
    
    public init(cornerRadius: CGFloat) {
        self.cornersRadius = .init(
            topLeft: cornerRadius,
            topRight: cornerRadius,
            bottomLeft: cornerRadius,
            bottomRight: cornerRadius
        )
    }
    
    public init(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) {
        self.cornersRadius = .init(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
    }
    
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.size.width * 0.5, y: 0))
            Corner.topRight
                .drawCorner(
                    in: rect.size,
                    radius: cornersRadius.topRight,
                    with: &path
                )
            Corner.bottomRight
                .drawCorner(
                    in: rect.size,
                    radius: cornersRadius.bottomRight,
                    with: &path
                )
            Corner.bottomLeft
                .drawCorner(
                    in: rect.size,
                    radius: cornersRadius.bottomLeft,
                    with: &path
                )
            Corner.topLeft
                .drawCorner(
                    in: rect.size,
                    radius: cornersRadius.topLeft,
                    with: &path
                )
            path.closeSubpath()
        }
    }
}
