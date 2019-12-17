//
//  LotteryDraw.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/9.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

protocol LotteryDrawDelegate: NSObjectProtocol {
    
    func lotteryDraw(didTouchStartButton lotteryDraw: LotteryDraw)
    
    func lotteryDraw(didEndAnimation lotteryDraw: LotteryDraw)
}

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

    weak var delegate: LotteryDrawDelegate?
    
    var displayLink: CADisplayLink!
    
    struct LotterySource {
        let image: UIImage
        let text: NSAttributedString
    }
    var source: [LotterySource] = []
    /// 是否在抽奖中
    var isLotteryDrawing: Bool = false
    var indexCount: Int = 0
    var powerCount: Int = 0
    var stopIndex: Int = 0
    var stopCount: Int = Int.min
    func handleDisplayLinkCallback() {
        self.indexCount = (self.indexCount + 1) % 28
        self.powerCount = (self.powerCount + 1) % 8
        if self.stopCount > Int.min {
            self.stopCount += 1
            if self.stopCount == self.stopIndex {
                self.displayLink.invalidate()
                self.delegate?.lotteryDraw(didEndAnimation: self)
            } else {
                self.displayLink.preferredFramesPerSecond = self.stopIndex - self.stopCount
            }
        }
        self.setNeedsDisplay()
    }
    
    /// 重置状态
    func resetWithSource(_ source: [LotterySource]) {
        guard source.count == 8 else { fatalError() }
        self.source = source
        self.isLotteryDrawing = false
        self.setNeedsDisplay()
    }
    
    /// 开始
    func run() {
        self.isLotteryDrawing = true
        self.displayLink =  CADisplayLink(target: DisplayLinkTarget(target: self, selector: self.handleDisplayLinkCallback),
                                                               selector: #selector(DisplayLinkTarget.handleDisplayLink))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: RunLoop.current, forMode: .common)
    }
    
    /// 停止的索引
    func stopAtIndex(_ stopIndex: Int) {
        self.stopCount = self.powerCount
        self.stopIndex = stopIndex + 16
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
        
        var itemSize: CGFloat = 26
        var spacing = (rect.width - (7 * itemSize) - 2 * (inset + 10)) / 6
        var offsetX: CGFloat = inset + 10
        var offsetY: CGFloat = 10
        for index in 0 ..< 28 {
            let isSelected = (index % 7) % 2 == 0 && self.isLotteryDrawing
            if index < 7 {
                self.drawImageAtLocation(CGPoint(x: offsetX + itemSize * 0.5, y: offsetY),
                                         in: context,
                                         image: (isSelected ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!,
                                         scale: self.indexCount == index ? 1.3 : 1)
                offsetX += (itemSize + spacing)
            } else if index >= 7 && index < 14 {
                if index == 7 {
                    offsetX = rect.width - 10
                    offsetY = inset + 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX, y: offsetY + itemSize * 0.5),
                                         in: context, image: (isSelected ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!,
                                         scale: self.indexCount == index ? 1.3 : 1)
                offsetY += (itemSize + spacing)
            } else if index >= 14 && index < 21 {
                if index == 14 {
                    offsetX = rect.width - inset - 10
                    offsetY = rect.height - 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX - itemSize * 0.5, y: offsetY),
                                         in: context, image: (isSelected ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!,
                                         scale: self.indexCount == index ? 1.3 : 1)
                offsetX -= (itemSize + spacing)
            } else {
                if index == 21 {
                    offsetX = 10
                    offsetY = rect.height - inset - 10
                }
                self.drawImageAtLocation(CGPoint(x: offsetX, y: offsetY - itemSize * 0.5),
                                         in: context, image: (isSelected ? UIImage(named: "icon_lottery_draw_normal") : UIImage(named: "icon_lottery_draw_light"))!,
                                         scale: self.indexCount == index ? 1.3 : 1)
                offsetY -= (itemSize + spacing)
            }
        }
        
        offsetX = inset + 10
        offsetY = inset + 10
        spacing = 8
        itemSize = (rect.width - (inset + 10) * 2 - spacing * 2) / 3
        for index in 0 ..< self.source.count {
            let isSelected = index == self.powerCount && self.isLotteryDrawing
            if index < 3 {
                self.drawImageInRect(CGRect(x: offsetX, y: offsetY, width: itemSize, height: itemSize), 
                                     in: context, image: isSelected ? UIImage(named: "icon_lottery_draw_highlight")! : UIImage(named: "icon_lottery_draw_item")!,
                                     text: self.source[index].text,
                                     itemImage: self.source[index].image)
                offsetX += (itemSize + spacing)
            } else if index >= 3 && index < 5 {
                offsetX = rect.width - (inset + 10) - itemSize
                offsetY += (itemSize + spacing)
                self.drawImageInRect(CGRect(x: offsetX, y: offsetY, width: itemSize, height: itemSize),
                                     in: context, image: isSelected ? UIImage(named: "icon_lottery_draw_highlight")! : UIImage(named: "icon_lottery_draw_item")!,
                                     text: self.source[index].text,
                                     itemImage: self.source[index].image)
            } else if index >= 5 && index < 7 {
                offsetY = rect.height - (inset + 10) - itemSize
                offsetX -= (itemSize + spacing)
                self.drawImageInRect(CGRect(x: offsetX, y: offsetY, width: itemSize, height: itemSize),
                                     in: context, image: isSelected ? UIImage(named: "icon_lottery_draw_highlight")! : UIImage(named: "icon_lottery_draw_item")!,
                                     text: self.source[index].text,
                                     itemImage: self.source[index].image)
            } else {
                offsetX = inset + 10
                offsetY -= (itemSize + spacing)
                self.drawImageInRect(CGRect(x: offsetX, y: offsetY, width: itemSize, height: itemSize),
                                     in: context, image: isSelected ? UIImage(named: "icon_lottery_draw_highlight")! : UIImage(named: "icon_lottery_draw_item")!,
                                     text: self.source[index].text,
                                     itemImage: self.source[index].image)
            }
        }
        
        /// 画开始按钮
        let image = self.isLotteryDrawing ? UIImage(named: "icon_lotter_drawing")! : UIImage(named: "icon_lottery_draw")!
        context.saveGState()
        image.draw(in: CGRect(x: inset + 10 + itemSize + spacing, y: inset + 10 + itemSize + spacing, width: itemSize, height: itemSize))
        context.restoreGState()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !self.isLotteryDrawing else { return }
        let location = touch.location(in: self)
        let inset: CGFloat = 20
        let spacing: CGFloat = 8
        let itemSize = (self.bounds.width - (inset + 10) * 2 - spacing * 2) / 3
        let rect = CGRect(x: inset + 10 + itemSize + spacing, y: inset + 10 + itemSize + spacing, width: itemSize, height: itemSize)
        if rect.contains(location) {
            self.delegate?.lotteryDraw(didTouchStartButton: self)
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
    
    /// 在某个位置画图片
    private func drawImageInRect(_ rect: CGRect, in context: CGContext, image: UIImage, text: NSAttributedString, itemImage: UIImage) {
        context.saveGState()
        image.draw(in: rect)
        var drawRect = CGRect(x: rect.midX - itemImage.size.width * 0.5, y: rect.midY - itemImage.size.height, width: itemImage.size.width, height: itemImage.size.height)
        itemImage.draw(in: drawRect)
        
        drawRect = CGRect(x: rect.minX, y: drawRect.maxY + 8, width: rect.width, height: 20)
        text.draw(with: drawRect, options: .usesLineFragmentOrigin, context: nil)
        context.restoreGState()
    }
}
