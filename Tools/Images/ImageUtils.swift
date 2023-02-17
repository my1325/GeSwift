//
//  ImageUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import UIKit

extension CGImageSource {
    func frameDurationAtIndex(_ index: Int) -> Double {
        var frameDuration = Double(0.1)
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [AnyHashable: Any], let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? [AnyHashable: Any] else {
            return frameDuration
        }

        if let unclampedDuration = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber {
            frameDuration = unclampedDuration.doubleValue
        } else {
            if let clampedDuration = gifProperties[kCGImagePropertyGIFDelayTime] as? NSNumber {
                frameDuration = clampedDuration.doubleValue
            }
        }

        if frameDuration < 0.011 {
            frameDuration = 0.1
        }

        return frameDuration
    }

    var frameDurations: [Double] {
        let frameCount = CGImageSourceGetCount(self)
        return (0 ..< frameCount).map { self.frameDurationAtIndex($0) }
    }
}

public extension UIImage {
    var thumbanilImage: UIImage? {
        guard let data = self.jpegData(compressionQuality: 0.6),
              let imageSource = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: NSNumber(value: false)] as CFDictionary),
              let writeData = CFDataCreateMutable(nil, 0),
              let imageType = CGImageSourceGetType(imageSource)
        else { return self }

        let frameCount = CGImageSourceGetCount(imageSource)
        if let imageDestination = CGImageDestinationCreateWithData(writeData, imageType, frameCount, nil) {
            let options = [
                kCGImageSourceCreateThumbnailFromImageIfAbsent: NSNumber(value: true),
                kCGImageSourceThumbnailMaxPixelSize: NSNumber(value: 120 * UIScreen.main.scale),
                kCGImageSourceShouldCache: NSNumber(value: false),
                kCGImageSourceCreateThumbnailWithTransform: NSNumber(value: true)
            ] as CFDictionary

            if frameCount > 1 {
                let frameDurations = imageSource.frameDurations
                let resizedImageFrames = (0 ..< frameCount).compactMap { CGImageSourceCreateThumbnailAtIndex(imageSource, $0, options) }
                zip(resizedImageFrames, frameDurations).forEach {
                    let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: $1, kCGImagePropertyGIFUnclampedDelayTime: $1]]
                    CGImageDestinationAddImage(imageDestination, $0, frameProperties as CFDictionary)
                }
            } else {
                if let imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) {
                    CGImageDestinationAddImage(imageDestination, imageRef, nil)
                }
            }
            CGImageDestinationFinalize(imageDestination)
            return UIImage(data: writeData as Data)
        }
        return self
    }

    /// 检测到的二维码
    var qrCode: String? {
        var qrCode: String?
        /// 检测图片中是否有二维码
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        if let cgImage = self.cgImage {
            let ciImages = CIImage(cgImage: cgImage)
            let features = detector?.features(in: ciImages, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) ?? []
            if let feature = features.first as? CIQRCodeFeature, let messageString = feature.messageString {
                qrCode = messageString
            }
        }
        return qrCode
    }

    /// colorimage
    static func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// add image a cornerRadius
    ///
    /// - Parameter cornerRadius: cornerRadius
    /// - Returns: new image
    func withCornerRadius(_ cornerRadius: CGFloat, corners: UIRectCorner = .allCorners) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if corners == .allCorners {
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        } else {
            UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).addClip()
        }
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return image
    }

    internal func withBorder(_ borderColor: UIColor, borderWidth: CGFloat, with corner: UIRectCorner = .allCorners, radius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        borderColor.setStroke()
        var _radius = radius
        if _radius == -1 { _radius = size.height * 0.5 }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let _path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: _radius))
        _path.addClip()

        draw(in: rect)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: _radius))
        path.lineWidth = borderWidth * UIScreen.main.scale
        path.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 渐变图片
    ///
    /// - Parameters:
    /// - colors: colors
    ///   - sPoint: startPoint
    ///   - ePoint: endPoint
    ///   - size: image size
    /// - Returns: image
    static func gradientImage(colors: [UIColor],
                              startPoint sPoint: CGPoint,
                              endPoint ePoint: CGPoint,
                              locations: [CGFloat],
                              size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = colors.map { $0.cgColor }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
        // 第二个参数是起始位置，第三个参数是终止位置
        context?.drawLinearGradient(gradient,
                                    start: CGPoint(x: sPoint.x * size.width, y: sPoint.y * size.height),
                                    end: CGPoint(x: ePoint.x * size.width, y: ePoint.y * size.height),
                                    options: .drawsAfterEndLocation)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// 二维码图片
    ///
    /// - Parameters:
    ///   - url: 二维码
    ///   - image: 中间的icon
    /// - Returns: UIImage
    static func imageWithQrCodeURL(_ url: String, image: UIImage? = nil) -> UIImage {
        // 创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        // 将url加入二维码
        filter?.setValue(url.data(using: String.Encoding.utf8), forKey: "inputMessage")
        // 取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            // 生成清晰度更好的二维码
            let qrCodeImage = self.hightDefinitionImage(outputImage, size: 300)
            // 如果有一个头像的话，将头像加入二维码中心
            if let image = image {
                // 合成图片
                let newImage = qrCodeImage.withSyntheticImage(image, width: 60, height: 60)
                return newImage
            }
            return qrCodeImage
        }
        return UIImage()
    }

    // image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    func withSyntheticImage(_ iconImage: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        // 开启图片上下文
        UIGraphicsBeginImageContext(self.size)
        // 绘制背景图片
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))

        let x = (self.size.width - width) * 0.5
        let y = (self.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        // 取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        // 返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }

    // MARK: - 生成高清的UIImage

    static func hightDefinitionImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)

        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!

        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!

        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion)
        bitmapRef.draw(bitmapImage, in: integral)
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
}
