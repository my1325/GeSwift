//
//  UILabel+Ge.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/10.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

fileprivate var attributeAssociateValue = "com.ge.attribute.value"
extension Ge where Base: UILabel {
    
    public var attributeText: String? {
        get { return self.attributeValue.text }
        set {
            self.attributeValue.text = newValue
            self.base.attributedText = NSAttributedString(string: newValue ?? "", attributes: self.attributeValue.innerAttributeValue)
        }
    }
    
    fileprivate final class AttributeVlaue {
        var innerAttributeValue: [NSAttributedString.Key: Any] = [:]
        var text: String?
        subscript(key: NSAttributedString.Key) -> Any? {
            get { return self.innerAttributeValue[key] }
            set { self.innerAttributeValue[key] = newValue }
        }
    }
       
    fileprivate var attributeValue: AttributeVlaue {
        var value = objc_getAssociatedObject(self.base, &attributeAssociateValue) as? AttributeVlaue
        if value == nil {
            value = AttributeVlaue()
            objc_setAssociatedObject(self.base, &attributeAssociateValue, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return value!
    }
       
    public var font: UIFont? {
        get { return self.attributeValue[.font] as? UIFont }
        set { self.attributeValue[.font] = newValue }
    }
       
    public var foregroundColor: UIColor? {
        get { return self.attributeValue[.foregroundColor] as? UIColor }
        set { self.attributeValue[.foregroundColor] = newValue }
    }
       
    public var paragraphStyle: NSMutableParagraphStyle? {
        get {
            return self.attributeValue[.paragraphStyle] as? NSMutableParagraphStyle
        } set {
            self.attributeValue[.paragraphStyle] = newValue
        }
    }
       
    public var backgroundColor: UIColor? {
        get { return self.attributeValue[.backgroundColor] as? UIColor }
        set { self.attributeValue[.backgroundColor] = newValue }
    }
       
    public var strikethroughStyle: NSUnderlineStyle? {
        get { return self.attributeValue[.strikethroughStyle] as? NSUnderlineStyle }
        set { self.attributeValue[.strikethroughStyle] = newValue }
    }
       
    public var beselineOffset: CGFloat? {
        get { return self.attributeValue[.baselineOffset] as? CGFloat }
        set { self.attributeValue[.baselineOffset] = newValue }
    }
       
    public var strikethroughColor: UIColor? {
        get { return self.attributeValue[.strikethroughColor] as? UIColor }
        set { self.attributeValue[.strikethroughColor] = newValue }
    }
}

