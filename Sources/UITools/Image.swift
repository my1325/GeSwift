//
//  ImageUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

#if canImport(UIKit)
import Accelerate
import CoreVideo
import UIKit
import VideoToolbox

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
                kCGImageSourceCreateThumbnailWithTransform: NSNumber(value: true),
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

    func withBorder(_ borderColor: UIColor, borderWidth: CGFloat, with corner: UIRectCorner = .allCorners, radius: CGFloat) -> UIImage? {
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

    func redrawWithSize(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1, y: -1)
        if let cgImage = self.cgImage {
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
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
        let proportion: CGFloat = min(size / integral.width, size / integral.height)

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

    private func bitmapInfoWithPixelFormatType(_ inputPixelFormat: OSType, hasAlpha: Bool) -> UInt32 {
        if inputPixelFormat == kCVPixelFormatType_32BGRA {
            var bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | kCGBitmapByteOrder32Host.rawValue
            if !hasAlpha {
                bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | kCGBitmapByteOrder32Host.rawValue
            }
            return bitmapInfo
        } else if inputPixelFormat == kCVPixelFormatType_32ARGB {
            let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            return bitmapInfo
        } else {
            return 0
        }
    }

    func toPixelBuffer(_ type: OSType) -> CVPixelBuffer? {
        guard let image = self.cgImage else { return nil }
        let width = image.width
        let height = image.height
        let hasAlpha = image.alphaInfo != .none
        var keyCallbacks = kCFTypeDictionaryKeyCallBacks
        var valueCallbacks = kCFTypeDictionaryValueCallBacks
        let empty = CFDictionaryCreate(kCFAllocatorDefault, nil, nil, 0, &keyCallbacks, &valueCallbacks)
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey: NSNumber(value: true),
            kCVPixelBufferIOSurfacePropertiesKey: empty ?? ([:] as CFDictionary),
        ] as [CFString: Any]

        var pixelBuffer: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, type, options as CFDictionary, &pixelBuffer) == kCVReturnSuccess,
              let pixelBuffer
        else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapInfo = self.bitmapInfoWithPixelFormatType(kCVPixelFormatType_32BGRA, hasAlpha: hasAlpha)

        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: bitmapInfo)
        else {
            return nil
        }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelBuffer
    }

    static func imageFrom420YpPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        // pixel format is Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).
        // baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct.
        //
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange else {
            return nil
        }

        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            return nil
        }

        defer {
            // be sure to unlock the base address before returning
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }

        // 1st plane is luminance, 2nd plane is chrominance
        guard CVPixelBufferGetPlaneCount(pixelBuffer) == 2 else {
            return nil
        }

        // 1st plane
        guard let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else {
            return nil
        }

        let lumaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let lumaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let lumaBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        var lumaBuffer = vImage_Buffer(
            data: lumaBaseAddress,
            height: vImagePixelCount(lumaHeight),
            width: vImagePixelCount(lumaWidth),
            rowBytes: lumaBytesPerRow
        )

        // 2nd plane
        guard let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1) else {
            return nil
        }

        let chromaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
        let chromaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        let chromaBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)
        var chromaBuffer = vImage_Buffer(
            data: chromaBaseAddress,
            height: vImagePixelCount(chromaHeight),
            width: vImagePixelCount(chromaWidth),
            rowBytes: chromaBytesPerRow
        )

        var argbBuffer = vImage_Buffer()

        defer {
            // we are responsible for freeing the buffer data
            free(argbBuffer.data)
        }

        // initialize the empty buffer
        guard vImageBuffer_Init(
            &argbBuffer,
            lumaBuffer.height,
            lumaBuffer.width,
            32,
            vImage_Flags(kvImageNoFlags)
        ) == kvImageNoError else {
            return nil
        }

        // full range 8-bit, clamped to full range, is necessary for correct color reproduction
        var pixelRange = vImage_YpCbCrPixelRange(
            Yp_bias: 0,
            CbCr_bias: 128,
            YpRangeMax: 255,
            CbCrRangeMax: 255,
            YpMax: 255,
            YpMin: 1,
            CbCrMax: 255,
            CbCrMin: 0
        )

        var conversionInfo = vImage_YpCbCrToARGB()

        // initialize the conversion info
        guard vImageConvert_YpCbCrToARGB_GenerateConversion(
            kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, // Y'CbCr-to-RGB conversion matrix for ITU Recommendation BT.601-4.
            &pixelRange,
            &conversionInfo,
            kvImage420Yp8_CbCr8, // converting from
            kvImageARGB8888, // converting to
            vImage_Flags(kvImageNoFlags)
        ) == kvImageNoError else {
            return nil
        }

        // do the conversion
        guard vImageConvert_420Yp8_CbCr8ToARGB8888(
            &lumaBuffer, // in
            &chromaBuffer, // in
            &argbBuffer, // out
            &conversionInfo,
            nil,
            255,
            vImage_Flags(kvImageNoFlags)
        ) == kvImageNoError else {
            return nil
        }

        // core foundation objects are automatically memory mananged. no need to call CGContextRelease() or CGColorSpaceRelease()
        guard let context = CGContext(
            data: argbBuffer.data,
            width: Int(argbBuffer.width),
            height: Int(argbBuffer.height),
            bitsPerComponent: 8,
            bytesPerRow: argbBuffer.rowBytes,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            return nil
        }

        if let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    // CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32ARGB
    static func imageFrom32ARGBPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let imageBuffer = pixelBuffer as CVImageBuffer
        CVPixelBufferLockBaseAddress(pixelBuffer, .init(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .init(rawValue: 0)) }
        let address = CVPixelBufferGetBaseAddress(imageBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bitmapInfo = kCGBitmapByteOrder32Host.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: address, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo)
        if let cgImage = context?.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    // videoToolBox , Not all CVPixelBuffer pixel formats support conversion into a  CGImage-compatible pixel format.
    static func imageFromPixelBufferWithVideoToolBox(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        if let cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    func resizeAspectFill(_ size: CGSize) -> UIImage? {
        guard let image = self.cgImage else { return nil }
        let width = image.width
        let height = image.height
        let imageRefW = CGFloat(width)
        let imageRefH = CGFloat(height)
        let winScale = size.width / size.height
        let refScale = imageRefW / imageRefH
        if winScale > refScale {
            let newH = imageRefW * size.height / size.width
            let newy = (imageRefH - newH) * 0.5
            if let finalImageRef = image.cropping(to: CGRect(x: 0, y: newy, width: imageRefW, height: newH)) {
                return UIImage(cgImage: finalImageRef)
            }
        }

        if winScale < refScale {
            let newW = imageRefH * winScale
            let newx = imageRefW - newW
            if let finalImageRef = image.cropping(to: CGRect(x: newx, y: 0, width: newW, height: imageRefH)) {
                return UIImage(cgImage: finalImageRef)
            }
        }
        return nil
    }

    func bf_clipsToSize(_ size: CGSize, radius: CGFloat) -> UIImage? {
        guard let image = self.cgImage else { return nil }
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()
//        context?.scaleBy(x: 1, y: -1)
//        context?.translateBy(x: 0, y: -size.height)
        let avatarRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIBezierPath(roundedRect: avatarRect, cornerRadius: radius).addClip()
        context?.draw(image, in: CGRect(origin: .zero, size: size))
        if let cgImage = context?.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
#endif
