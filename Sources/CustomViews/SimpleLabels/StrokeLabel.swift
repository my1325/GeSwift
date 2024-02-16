//
//  StrokeLabel.swift
//  YYDSlots
//
//  Created by mayong on 2024/2/8.
//

import UIKit

internal final class StrokeLabel: UILabel {
        
    var strokeWidth: CGFloat?
    
    var strokeColor: UIColor?
    
    override func drawText(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let strokeWidth,
                let strokeColor
        else {
            super.drawText(in: rect)
            return
        }
        
        context.setLineWidth(strokeWidth)
        context.setLineJoin(.round)
        
        let strokeOffset = strokeWidth * 0.5
        let drawRect = CGRect(origin: CGPoint(x: rect.origin.x + strokeOffset, y: rect.origin.y), size: CGSize(width: rect.size.width + strokeWidth, height: rect.size.height + strokeWidth))
        let oldTextColor = textColor

        do {
            context.setTextDrawingMode(.stroke)
            textColor = strokeColor
            super.drawText(in: drawRect)
        }
        
        do {
            context.setTextDrawingMode(.fill)
            textColor = textColor
            super.drawText(in: drawRect)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard let strokeWidth else {
            return super.intrinsicContentSize
        }
        
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + strokeWidth, height: size.height + strokeWidth)
    }
}
