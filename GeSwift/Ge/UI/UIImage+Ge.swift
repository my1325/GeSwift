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
    public static func with(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    /// 压缩图片到指定大小
    public static func with(image sourceImage: UIImage, targetSize: CGSize =  CGSize(width: 480, height: 640)) -> UIImage? {
        let size = targetSize
        var newImage: UIImage? = nil
        let imageSize = sourceImage.size
        
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
        sourceImage.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    /// 压缩图片到指定大小
    public func to(targetSize: CGSize = CGSize(width: 480, height: 640)) -> UIImage? {
        return UIImage.ge.with(image: base, targetSize: targetSize)
    }
}
