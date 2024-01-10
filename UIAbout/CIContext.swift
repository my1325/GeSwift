//
//  Ge+CIContext.swift
//  Tools
//
//  Created by my on 2023/10/28.
//

#if canImport(UIKit)
import UIKit
#endif
import CoreImage

public extension CIContext {
#if canImport(UIKit)
    func cgImageWithPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let cgImage = createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height)) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    #endif
    
    func pixelBufferWithCGImage(_ cgImage: CGImage) -> CVPixelBuffer? {
        let properties: [String: Any] = [:]
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: properties,
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let width = cgImage.width
        let height = cgImage.height
        let retStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        guard retStatus == kCVReturnSuccess, let pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .init(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .init(rawValue: 0)) }
        render(CIImage(cgImage: cgImage), to: pixelBuffer)
        return pixelBuffer
    }
#if canImport(UIKit)

    func blurImage(_ image: CGImage, blurNumber: Double = 50) -> UIImage? {
        let ciImage = CIImage(cgImage: image)
        guard let clampFilter = CIFilter(name: "CIAffineClamp") else { return nil }
        clampFilter.setDefaults()
        clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let clampImage = clampFilter.value(forKey: kCIOutputImageKey) as? CIImage,
              let filter = CIFilter(name: "CIGaussianBlur")
        else {
            return nil
        }
       
        filter.setValue(clampImage, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value: blurNumber), forKey: "inputRadius")
        if let result = filter.value(forKey: kCIOutputImageKey) as? CIImage,
           let cgImage = createCGImage(result, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    #endif
}
