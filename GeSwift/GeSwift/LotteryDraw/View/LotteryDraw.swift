//
//  LotteryDraw.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/9.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class LotteryDraw: UIView {
    
    internal final class DisplayLinkTarget: NSObject {
        typealias DisplayLinkSelector = () -> Void
        let selector: DisplayLinkSelector
        weak var target: AnyObject?
        init(target: AnyObject, selector: @escaping DisplayLinkSelector) {
            self.target = target
            self.selector = selector
            super.init()
        }
        
        @objc func handleDisplayLink() {
            if target != nil {
                self.selector()
            }
        }
    }

    var displayLink: CADisplayLink!
    
    var indexCount: Int = 0
    var stopIndex: Int = 0
    var stopCount: Int = Int.min
    func handleDisplayLinkCallback() {
        self.indexCount = (self.indexCount + 1) % 28
        if self.stopCount > Int.min {
            self.stopCount += 1
            if self.stopCount == self.stopIndex {
                self.displayLink.invalidate()
            } else {
                self.displayLink.preferredFramesPerSecond = self.stopIndex - self.stopCount
            }
        }
        self.setNeedsDisplay()
    }
    
    func run() {
        self.displayLink =  CADisplayLink(target: DisplayLinkTarget(target: self, selector: self.handleDisplayLinkCallback),
                                                               selector: #selector(DisplayLinkTarget.handleDisplayLink))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: RunLoop.current, forMode: .common)
    }
    
    /// 停止的索引
    func stopAtIndex(_ stopIndex: Int) {
        let subCount = stopIndex - self.indexCount
        self.stopCount = self.indexCount
        if subCount > 10 {
            /// 大于十个以上就在当前圈停止
            self.stopIndex = stopIndex
        } else {
            /// 否则在下一圈停止
            self.stopIndex = stopIndex + 28
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        /// 第一个渐变图层
        var inset: CGFloat = 0
        self.drawLinearGradientForRect(rect.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)), in: context,
                                       colors: [UIColor.ge.color(with: 0xFFC62F).cgColor, UIColor.ge.color(with: 0xFF9522).cgColor],
                                       locations: [0.0, 1.0])
        /// 第二个纯色背景图层
        inset = 20
        self.drawBackgroundColorForRect(rect.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)),
                                        in: context,
                                        backgroundColor: UIColor.ge.color(with: 0xFE7F00).cgColor)
        
        let itemSize: CGFloat = 26
        let spacing = (rect.width - (7 * itemSize) - 2 * (inset + 10)) / 6
        var offsetX: CGFloat = inset + 10
        var offsetY: CGFloat = 10
        for index in 0 ..< 28 {
            if index < 7 {
                self.drawImageAtLocation(CGPoint(x: offsetX + itemSize * 0.5, y: offsetY), in: context, image: ((index % 7) % 2 == 0 ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!, scale: self.indexCount == index ? 1.3 : 1)
                offsetX += (itemSize + spacing)
            } else if index >= 7 && index < 14 {
                if index == 7 {
                    offsetX = rect.width - 10
                    offsetY = inset + 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX, y: offsetY + itemSize * 0.5), in: context, image: ((index - 7) % 2 == 0 ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!, scale: self.indexCount == index ? 1.3 : 1)
                offsetY += (itemSize + spacing)
            } else if index >= 14 && index < 21 {
                if index == 14 {
                    offsetX = rect.width - inset - 10
                    offsetY = rect.height - 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX - itemSize * 0.5, y: offsetY), in: context, image: ((index % 7) % 2 == 0 ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!, scale: self.indexCount == index ? 1.3 : 1)
                offsetX -= (itemSize + spacing)
            } else {
                if index == 21 {
                    offsetX = 10
                    offsetY = rect.height - inset - 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX, y: offsetY - itemSize * 0.5), in: context, image: ((index - 7) % 2 == 0 ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!, scale: self.indexCount == index ? 1.3 : 1)
                offsetY -= (itemSize + spacing)
            }
        }
    }
    
    /// 渐变背景
    private func drawLinearGradientForRect(_ rect: CGRect, in context: CGContext, colors: [CGColor], locations: [CGFloat]) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
        let pathRect = path.cgPath.boundingBox
        
        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()
        context.drawLinearGradient(CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                               colors: colors as CFArray,
                                               locations: locations)!,
                                    start: CGPoint(x: pathRect.minX, y: pathRect.minY),
                                    end: CGPoint(x: pathRect.minX, y: pathRect.maxY),
                                    options: .drawsBeforeStartLocation)
        context.restoreGState()
    }
    
    /// 纯色背景
    private func drawBackgroundColorForRect(_ rect: CGRect, in context: CGContext, backgroundColor: CGColor) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
        context.saveGState()
        context.addPath(path.cgPath)
        context.setFillColorSpace(CGColorSpaceCreateDeviceRGB())
        context.setFillColor(backgroundColor)
        context.fillPath()
        context.restoreGState()
    }
    
    /// 在某个位置画图片
    private func drawImageAtLocation(_ location: CGPoint, in context: CGContext, image: UIImage, scale: CGFloat) {
        context.saveGState()
        image.draw(in: CGRect(x: location.x - (image.size.width * scale) / 2,
                              y: location.y - (image.size.height * scale) / 4,
                              width: image.size.width * scale,
                              height: image.size.height * scale))
        context.restoreGState()
    }
}
