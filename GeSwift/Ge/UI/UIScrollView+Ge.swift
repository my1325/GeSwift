//
//  UIScrollView+Ge.swift
//  GeSwift
//
//  Created by my on 2018/8/23.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit

extension Ge where Base: UIScrollView {
    
    /// snap shot for scroll view
    ///
    /// - Parameter size: target image size, if nil use scroll view's content size
    /// - Returns: image
    public var snapShot: UIImage? {
        
        let savedContentOffset = base.contentOffset
        let savedFrame = base.frame
        
        base.frame = CGRect(x: 0,
                            y: base.frame.origin.y,
                            width: base.contentSize.width,
                            height: base.contentSize.height)
        
        UIGraphicsBeginImageContextWithOptions(base.contentSize, true, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext();
        base.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        base.contentOffset = savedContentOffset
        base.frame = savedFrame
        
        return shotImage
    }
}
