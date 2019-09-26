//
//  AnimationViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/26.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class AnimationViewController: BaseViewController {

    lazy var textLayer: CATextLayer = {
        $0.string = "测试字体颜色变化"
        $0.foregroundColor = UIColor.green.cgColor
        $0.fontSize = 18
        $0.frame = CGRect(x: 30, y: 30, width: 300, height: 50)
        self.view.layer.addSublayer($0)
        return $0
    }(CATextLayer())
    
    lazy var label: Label = {
        $0.text = "测试字体颜色变化测试字体颜色变化测试字体颜色变化测试字体颜色变化测试字体颜色变化测试字体颜色变化"
        $0.textColor = UIColor.red
        $0.fontSize = 18
        self.view.addSubview($0)
        return $0
    }(Label(frame: CGRect(x: 30, y: 100, width: 300, height: 100)))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "AnimationViewController"
        Animation(target: self.textLayer, duration: 2, repeatCount: MAXFLOAT, isRemovedOnCompletion: false, autoreverses: true)
                    .addBasicAnimation(for: "fontSize", to: NSNumber(value: 20))
                    .addBasicAnimation(for: "foregroundColor", to: UIColor.red.cgColor)
                    .resume()
        
        self.label.reset()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.label.animateToFontSize(20, duration: 2)
            self.label.animateToForegroundColor(UIColor.green, duration: 2)
        }
    }
}
