//
//  InputViewCell.swift
//  GeSwift
//
//  Created by my on 2021/1/26.
//  Copyright © 2021 my. All rights reserved.
//
import UIKit

internal final class InputViewCell: UICollectionViewCell {
    internal lazy var box: UIView = {
        self.contentView.addSubview($0)
        return $0
    }(UIView())
    
    internal lazy var label: UILabel = {
        $0.textAlignment = .center
        self.contentView.insertSubview($0, aboveSubview: box)
        return $0
    }(UILabel())
    
    lazy var shapeLayer: CAShapeLayer = {
        $0.lineWidth = borderWidth
        $0.strokeColor = borderColor.cgColor
        $0.fillColor = boxBackgroundColor?.cgColor
        box.layer.addSublayer($0)
        return $0
    }(CAShapeLayer())
    
    var borderStyle: BorderStyle = .none
    
    var borderWidth: CGFloat = 0 {
        didSet {
            shapeLayer.lineWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = .black {
        didSet {
            shapeLayer.strokeColor = borderColor.cgColor
        }
    }
    
    var borderRadius: CGFloat = 4
    
    var boxBackgroundColor: UIColor? {
        didSet {
            shapeLayer.fillColor = boxBackgroundColor?.cgColor
        }
    }
    
    func reloadBorder() {
        switch borderStyle {
        case .underline:
            renderUnderlineBorder()
        case .box:
            renderBoxBorder()
        case .none:
            renderNoneBorder()
        }
    }
    
    override func layoutSubviews() {
        box.frame = CGRect(x: 5, y: 5, width: bounds.width - 10, height: bounds.height - 10)
        label.frame = box.frame
        reloadBorder()
    }
    
    private func renderNoneBorder() {
        shapeLayer.path = UIBezierPath().cgPath
    }
    
    private func renderUnderlineBorder() {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.move(to: CGPoint(x: 0, y: box.bounds.height))
        path.addLine(to: CGPoint(x: box.bounds.width, y: box.bounds.height))
        path.stroke()

        shapeLayer.path = path.cgPath
    }
    
    private func renderBoxBorder() {
        let path = UIBezierPath(roundedRect: box.bounds, cornerRadius: borderRadius)
        shapeLayer.path = path.cgPath
    }
}
