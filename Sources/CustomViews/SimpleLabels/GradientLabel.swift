//
//  GradientLabel.swift
//  YYDSlots
//
//  Created by mayong on 2024/2/8.Ïƒ
//

import UIKit

internal final class GradientLabel: UIView {
    
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
    
    var numberOfLines: Int {
        get { label.numberOfLines }
        set { label.numberOfLines = newValue }
    }
    
    var font: UIFont! {
        get { label.font }
        set { label.font = newValue }
    }
    
    var startPoint: CGPoint = CGPoint.zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    var locations: [CGFloat] = [] {
        didSet {
            gradientLayer.locations = locations.map({ NSNumber(value: $0) })
        }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    var colors: [UIColor] = [.black] {
        didSet {
            gradientLayer.colors = colors.map(\.cgColor)
        }
    }
    
    var text: String! {
        get { label.text }
        set { label.text = newValue }
    }
    
    var textAlignment: NSTextAlignment {
        get { label.textAlignment }
        set { label.textAlignment = newValue }
    }
    
    override func layoutSubviews() {
        label.frame = bounds
        gradientLayer.frame = bounds
        gradientLayer.mask = label.layer
    }
    
    override var intrinsicContentSize: CGSize {
        label.intrinsicContentSize
    }
}
