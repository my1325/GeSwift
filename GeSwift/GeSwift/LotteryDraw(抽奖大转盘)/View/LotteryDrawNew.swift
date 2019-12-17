//
//  LotteryDrawNew.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/10.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class LotteryDrawNew: UIView {

    var isLotteryDrawing: Bool = false
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        var drawRect = rect
        /// 画大背景
        self.drawImageInRect(drawRect, image: UIImage(named: "icon_lottery_draw_light_background")!, context: context)
        
        /// 画左上角的指针
        drawRect = CGRect(x: 0, y: 0, width: 90, height: 76)
        self.drawImageInRect(drawRect, image: UIImage(named: "icon_lottery_draw_pointer")!, context: context)
    
        /// 画圆饼
        var angle: CGFloat = 0
        let spacingAngle = Double.pi / 16
        let preangleForItem = (Double.pi * 2 - spacingAngle * 7) / 8
        for index in 0 ..< 1 {
            self.drawImageInRect(rect: CGRect(x: rect.midX - 103 * 0.5, y: 20, width: 103, height: rect.height * 0.5 - 20),
                                 image: UIImage(named: "icon_lottery_draw_cake")!,
                                 context: context,
                                 angle: CGFloat(spacingAngle + preangleForItem) * 3)
            angle += CGFloat(spacingAngle + preangleForItem)
        }
        /// 画中间开始按钮
        drawRect = CGRect(x: rect.midX - 111 * 0.5, y: rect.midY - 111 * 0.5, width: 111, height: 111)
        self.drawImageInRect(drawRect, image: self.isLotteryDrawing ? UIImage(named: "icon_lottery_drawing_button")! : UIImage(named: "icon_lottery_draw_push_button")!, context: context)
    }
    
    /// 在某个矩形画图片
    func drawImageInRect(_ rect: CGRect, image: UIImage, context: CGContext) {
        context.saveGState()
        image.draw(in: rect)
        context.restoreGState()
    }
    
    /// 在某个矩形画图片，并且选择角度
    func drawImageInRect(rect: CGRect, image: UIImage, context: CGContext, angle: CGFloat) {
        context.saveGState()
        let imageRect = rect
        let rotatedTransform = CGAffineTransform.identity.rotated(by: angle)
        var rotatedRect = imageRect.applying(rotatedTransform)
        rotatedRect.origin.x = rect.minX
        rotatedRect.origin.y = rect.minY
           
        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context.rotate(by: angle)
        context.translateBy(x: -rotatedRect.width / 2, y: -rotatedRect.height / 2)
        image.draw(at: rect.origin)

        context.restoreGState()
    }
}
