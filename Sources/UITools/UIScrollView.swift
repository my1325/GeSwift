//
//  UIScrollViewUtils.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/17.
//
#if canImport(UIKit)
import UIKit

public extension UIScrollView {
    /// snap shot for scroll view
    ///
    /// - Parameter size: target image size, if nil use scroll view's content size
    /// - Returns: image
    var snapShot: UIImage? {
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        
        self.frame = CGRect(x: 0,
                            y: self.frame.origin.y,
                            width: self.contentSize.width,
                            height: self.contentSize.height)
        
        UIGraphicsBeginImageContextWithOptions(self.contentSize, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        
        return shotImage
    }
}
#endif
