//
//  Label.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/26.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

@IBDesignable
public final class Label: View {

    /// inherit properties
    @IBInspectable
    public var text: String = ""
    
    @IBInspectable
    public var textColor: UIColor = UIColor.black
    
    @IBInspectable
    public var fontSize: CGFloat = 17

    @IBInspectable
    public var alignment: NSTextAlignment = .left
    
    @IBInspectable
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    /// custom properties
    
    /// 渐变文字属性
    public var gradientTextColors: [UIColor] = []
    
    /// 渐变属性位置
    public var gradientLocations: [CGFloat] = []
    
    /// 渐变属性起始位置, default is zero
    public var gradientStartPoint: CGPoint = .zero
    
    /// 渐变属性终止位置, default is 1, 0
    public var gradientEndPoint: CGPoint = CGPoint(x: 1, y: 0)
    
    
    private lazy var gradientBackgroundLayer: CAGradientLayer = CAGradientLayer()
    
    private lazy var textLayer: CATextLayer = CATextLayer()
}

extension Label {
    
    private func resetGradientBackgroundLayer() {
        if self.gradientTextColors.count == 0  && self.gradientLocations.count == 0{
            self.gradientTextColors = [self.textColor, self.textColor]
            self.gradientLocations = [0, 1]
        } else if self.gradientTextColors.count == 1 && self.gradientLocations.count == 0 {
            self.gradientTextColors = [self.textColor, self.gradientTextColors[0]]
            self.gradientLocations = [0, 1]
        } else if self.gradientTextColors.count == 1 && self.gradientLocations.count == 1 {
            self.gradientTextColors = [self.textColor, self.gradientTextColors[0]]
            self.gradientLocations = [0, self.gradientLocations[0]]
        } else if self.gradientTextColors.count == 1 {
            self.gradientTextColors = [self.textColor, self.gradientTextColors[0]]
        } else if self.gradientLocations.count == 1 {
            self.gradientLocations = [0, self.gradientLocations[0]]
        }
        
        self.gradientBackgroundLayer.colors = self.gradientTextColors.map({ $0.cgColor })
        self.gradientBackgroundLayer.locations = self.gradientLocations.map({ NSNumber(value: Float($0)) })
        self.gradientBackgroundLayer.startPoint = self.gradientStartPoint
        self.gradientBackgroundLayer.endPoint = self.gradientEndPoint
        
        if self.gradientBackgroundLayer.superlayer == nil {
            self.layer.addSublayer(self.gradientBackgroundLayer)
            self.gradientBackgroundLayer.mask = self.textLayer
        }
    }
    
    private func resetTextLayer() {
        self.textLayer.string = self.text
        self.textLayer.fontSize = self.fontSize
        self.textLayer.contentsScale = UIScreen.main.scale
        self.textLayer.alignmentMode = self.alignment.alignmentModeForCA
        self.textLayer.isWrapped = true
        self.textLayer.truncationMode = .end
    }
}

extension Label {
    
    public func reset() {
        self.resetTextLayer()
        self.resetGradientBackgroundLayer()
    }
    
    /// 字体大小动画
    public func animateToFontSize(_ size: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) -> Animation {
        return Animation(target: self.textLayer, duration: duration, completion: completion).addBasicAnimation(for: "fontSize", to: NSNumber(value: Float(size)))
    }
    
    /// 过渡到某字体颜色动画
    public func animateToForegroundColor(_ foregroundColor: UIColor, duration: TimeInterval, completion: (() -> Void)? = nil) -> Animation {
        return Animation(target: self.gradientBackgroundLayer, duration: duration, completion: completion).addBasicAnimation(for: "colors", to: [foregroundColor.cgColor, foregroundColor.cgColor])
    }
}

extension Label {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLayer.frame = CGRect(x: self.edgeInsets.left,
                                      y: self.edgeInsets.top,
                                      width: self.ge.width - self.edgeInsets.left - self.edgeInsets.right,
                                      height: self.ge.height - self.edgeInsets.top - self.edgeInsets.bottom)
        
        self.gradientBackgroundLayer.frame = CGRect(x: self.edgeInsets.left,
                                                    y: self.edgeInsets.top,
                                                    width: self.ge.width - self.edgeInsets.left - self.edgeInsets.right,
                                                    height: self.ge.height - self.edgeInsets.top - self.edgeInsets.bottom)

    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.resetTextLayer()
        self.resetGradientBackgroundLayer()
    }
    
    public override func sizeToFit() {
        self.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
    }
    
    @discardableResult
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let attributeText = NSAttributedString(string: self.text, attributes: [.font: UIFont.systemFont(ofSize: self.fontSize)])
        let size = attributeText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
        self.bounds = CGRect(origin: self.bounds.origin, size: CGSize(width: size.width + edgeInsets.left + edgeInsets.right, height: size.height + edgeInsets.top + edgeInsets.bottom))
        return size
    }
}

extension NSTextAlignment {
    
//    CATextLayerAlignmentMode
    fileprivate var alignmentModeForCA: CATextLayerAlignmentMode {
        switch self {
        case .center:
            return .center
        case .justified:
            return .justified
        case .left:
            return .left
        case .natural:
            return .natural
        case .right:
            return .right
        @unknown default:
            fatalError()
        }
    }
}
