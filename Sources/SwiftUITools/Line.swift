//
//  SwiftUIView.swift
//  
//
//  Created by mayong on 2023/12/22.
//

import SwiftUI

public struct Line: Shape {
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: rect.origin)
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        }
    }
}
