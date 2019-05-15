//
//  UIImage+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/23.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIImage

extension Ge where Base: UIImage {
    
    /// 检测到的二维码
    public var detectedQrCode: String? {
        var qrCode: String?
        /// 检测图片中是否有二维码
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        if let cgImage = self.base.cgImage {
            let ciImages = CIImage(cgImage: cgImage)
            let features = detector?.features(in: ciImages, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) ?? []
            if let feature = features.first as? CIQRCodeFeature, let messageString = feature.messageString {
                qrCode = messageString
            }
        }
        return qrCode
    }

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

    /// 渐变图片
    ///
    /// - Parameters:
    /// - colors: colors
    ///   - sPoint: startPoint
    ///   - ePoint: endPoint
    ///   - size: image size
    /// - Returns: image
    public static func gradientImage(colors: [UIColor],
                                     startPoint sPoint: CGPoint,
                                     endPoint ePoint: CGPoint,
                                     size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map({ $0.cgColor })
//            colors.map {(color: UIColor) -> AnyObject! in return color.CGColor as AnyObject! } as NSArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!
        // 第二个参数是起始位置，第三个参数是终止位置
        context?.drawLinearGradient(gradient, start: sPoint, end: ePoint, options: CGGradientDrawingOptions.init(rawValue: 0))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// 二维码图片
    ///
    /// - Parameters:
    ///   - url: 二维码
    ///   - image: 中间的icon
    /// - Returns: UIImage
    public static func qrCodeImage(withURL url: String, image: UIImage? = nil) -> UIImage {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //将url加入二维码
        filter?.setValue(url.data(using: String.Encoding.utf8), forKey: "inputMessage")
        //取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            //生成清晰度更好的二维码
            let qrCodeImage = hightDefinitionImage(outputImage, size: 300)
            //如果有一个头像的话，将头像加入二维码中心
            if let image = image {
                //给头像加一个白色圆边（如果没有这个需求直接忽略）
                //            image = circleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
                //合成图片
                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 60, height: 60)
                return newImage
            }
            return qrCodeImage
        }
        return UIImage()
    }


    //image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    public static func syntheticImage(_ image: UIImage, iconImage:UIImage, width: CGFloat, height: CGFloat) -> UIImage{
        //开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        //绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let x = (image.size.width - width) * 0.5
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }

    //MARK: - 生成高清的UIImage
    public static func hightDefinitionImage(_ image: CIImage, size: CGFloat) -> UIImage {

        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)

        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!

        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!

        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
}
