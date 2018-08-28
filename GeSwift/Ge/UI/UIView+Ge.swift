//
//  UIView+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/20.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIView

extension Ge where Base: UIView {
    
    public func snapShot(size: CGSize?) -> UIImage? {
        var size = size
        if size == nil {
            size = base.bounds.size
        }
        
        UIGraphicsBeginImageContextWithOptions(size!, true, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        base.layer.render(in: context!)
        let shotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return shotImage
    }
    
    public func addConstraint(inSuper attribute: NSLayoutAttribute, constant: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: base.superview,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        base.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(width: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: width)
        base.superview?.addConstraint(constraint)
    }
    
    public func addConstraint(height: CGFloat) {
        let constraint = NSLayoutConstraint(item: base,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: height)
        base.superview?.addConstraint(constraint)
    }
    
    public func updateConstraint(inSuper attribute: NSLayoutAttribute, constant: CGFloat) {
        for constraint in base.superview!.constraints {
            if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == base) ||
            (constraint.firstAttribute == attribute && constraint.secondItem as? UIView == base) {
                constraint.constant = constant
                break
            }
        }
    }
    
    public func updateConstraint(width: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == base {
                constraint.constant = width
            }
        }
    }
    
    public func updateConstrain(height: CGFloat) {
        for constraint in base.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == base {
                constraint.constant = height
            }
        }
    }
    
    /// 虚线边框
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - width: 边框宽度
    ///   - dashPartten: 虚线样式
    public func dashBorder(_ color: CGColor = UIColor.ge.serializeWithString(useingHex: "cccccc").cgColor,
                           _ width: CGFloat = 1 / UIScreen.main.scale,
                           _ dashPartten: [NSNumber] = [4, 2],
                           _ lineCap: String = "square",
                           frame: CGRect) {
        let border = CAShapeLayer()
        border.strokeColor = color
        border.fillColor = nil
        border.path = UIBezierPath(rect: frame).cgPath
        border.frame = frame
        border.lineWidth = width
        border.lineCap = lineCap
        border.lineDashPattern = dashPartten
        
        base.layer.addSublayer(border)
    }
}


protocol Nibloadable {}

extension UIView: Nibloadable {}

extension Nibloadable where Self : UIView{
   
    static func loadNib(named nibNmae: String? = nil) -> Self? {
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as? Self
    }
}

extension Ge where Base: UIView {
    
    public static func loadNib(named nibName: String? = nil) -> Base? {
        return Base.loadNib(named: nibName)
    }
}
