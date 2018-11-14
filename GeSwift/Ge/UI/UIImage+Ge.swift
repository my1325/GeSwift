//
//  UIImage+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/23.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIImage

extension Ge where Base: UIImage {

    /// colorimage
    public static func image(withColor color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    /// 压缩图片到指定大小
    public func compress(toTargetSize size: CGSize =  CGSize(width: 480, height: 640)) -> UIImage? {
        let size = size
        var newImage: UIImage? = nil
        let imageSize = base.size
        
        let width = imageSize.width
        let height = imageSize.height
        let twidth = size.width
        let theight = size.height
        var point = CGPoint(x: 0, y: 0)
        var scaleFactor: CGFloat = 0.0
        var sacaledWidth = twidth
        var scaledHeight = theight
        
        if imageSize != size {
            let widthFactor: CGFloat = twidth / width
            let heightFactor: CGFloat = height / width
            scaleFactor = max(widthFactor, heightFactor)
            
            sacaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            
            if widthFactor > heightFactor { point.y = (theight - scaledHeight) * 0.5 }
            else if widthFactor < heightFactor { point.x = (twidth - sacaledWidth) * 0.5 }
        }
        
        UIGraphicsBeginImageContext(size)
        var thumbnailRect = CGRect.zero;
        thumbnailRect.origin = point;
        thumbnailRect.size.width = sacaledWidth;
        thumbnailRect.size.height = scaledHeight;
        base.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    /// add image a cornerRadius
    ///
    /// - Parameter cornerRadius: cornerRadius
    /// - Returns: new image
    public func image(withCornerRadius cornerRadius: CGFloat) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(base.size, false, UIScreen.main.scale)

        let rect = CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        base.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return image
    }

    /// circle image with a border
    ///
    /// - Parameters:
    ///   - color: border color
    ///   - width: border width
    /// - Returns: UIImage
    public func image(withCircleBorder borderColor: UIColor, width borderWidth: CGFloat) -> UIImage? {

        let imageW = base.size.width + 2 * borderWidth;
        let imageH = base.size.height + 2 * borderWidth;
        let imageSize = CGSize(width: imageW, height: imageH)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()

        borderColor.set()
        let bigRadius = imageW * 0.5
        let centerX = bigRadius
        let centerY = bigRadius
        ctx?.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: bigRadius,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi * 2),
                    clockwise: false)
        ctx?.fillPath()

        let smallRadius = bigRadius - borderWidth
        ctx?.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: smallRadius,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi * 2),
                    clockwise: false)
        ctx?.clip()
        base.draw(in: CGRect(x: borderWidth, y: borderWidth, width: base.size.width, height: base.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
