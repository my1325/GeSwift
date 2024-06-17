//
//  GradientLabel.swift
//  YYDSlots
//
//  Created by mayong on 2024/2/8.Ïƒ
//

import UIKit

public final class GradientLabel: UIView {
    
    private lazy var gradientLayer: CAGradientLayer = {
        $0.startPoint = .zero
        $0.endPoint = CGPoint(x: 1, y: 1)
        self.layer.addSublayer($0)
        return $0
    }(CAGradientLayer())
    
    private(set) lazy var label: UILabel = {
        $0.textColor = .white
        self.addSubview($0)
        return $0
    }(UILabel())
    
    public var numberOfLines: Int {
        get { label.numberOfLines }
        set { label.numberOfLines = newValue }
    }
    
    public var font: UIFont! {
        get { label.font }
        set { label.font = newValue }
    }
    
    public var startPoint: CGPoint = CGPoint.zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    public var locations: [CGFloat] = [] {
        didSet {
            gradientLayer.locations = locations.map({ NSNumber(value: $0) })
        }
    }
    
    public var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    public var colors: [UIColor] = [.black] {
        didSet {
            gradientLayer.colors = colors.map(\.cgColor)
        }
    }
    
    public var text: String! {
        get { label.text }
        set { label.text = newValue }
    }
    
    public var textAlignment: NSTextAlignment {
        get { label.textAlignment }
        set { label.textAlignment = newValue }
    }
    
    public override func layoutSubviews() {
        label.frame = bounds
        gradientLayer.frame = bounds
        gradientLayer.mask = label.layer
    }
    
    public override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }
}
