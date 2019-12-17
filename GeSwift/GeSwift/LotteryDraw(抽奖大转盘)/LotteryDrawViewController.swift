//
//  LotteryDrawViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/9.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

class LotteryDrawViewController: BaseViewController {

    @IBOutlet weak var lotteryDrawView: UIView!
    @IBOutlet weak var lotteryBackgroundImageView: UIImageView! {
        didSet {
            self.lotteryBackgroundImageView.layer.zPosition = -100
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var lotteryIitem: [LotteryItem] = []
        let lotteryWidth = iphone_width - 32
        for index in 0 ..< 8 {
            let item = LotteryItem.nib?.instantiate(withOwner: nil, options: nil).first as! LotteryItem
            item.frame = CGRect(x: 0, y: 0, width: CGFloat(Double.pi) * lotteryWidth / 8 - 40, height: iphone_width * 0.5 - 36)
            item.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            item.center = CGPoint(x: (iphone_width - 32) / 2, y: (iphone_width - 32) / 2)
            item.nameLabel.text = "优惠券"
            item.awardLabel.attributedText = {
                $0.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSMakeRange(0, 1))
                return $0
            }(NSMutableAttributedString(string: "￥\((index + 1) * 10)", attributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.white]))
            let angle = CGFloat(Double.pi * 2 / 8 * Double(index))
            item.transform = CGAffineTransform(rotationAngle: angle)
            item.layer.zPosition = CGFloat(-index - 1)
            self.lotteryDrawView.addSubview(item)
        }
        
    }
    
    var displayLink: CADisplayLink!
    
    @IBAction func touchStartButton(_ sender: UIButton) {
        self.targetStopAngle = CGFloat(MAXFLOAT)
        self.stopAngle = CGFloat(MAXFLOAT)
        self.currentAngle = 0
        self.lotteryDrawView.transform = CGAffineTransform(rotationAngle: 0)
        self.run()
        sender.isSelected = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.stopAtIndex(5)
        }
    }
    
    typealias DisplayLinkTarget = LotteryDraw.DisplayLinkTarget
    /// 开始
    func run() {
        self.displayLink =  CADisplayLink(target: DisplayLinkTarget(target: self, selector: self.handleDisplayLinkCallback),
                                                               selector: #selector(DisplayLinkTarget.handleDisplayLink))
        self.displayLink.preferredFramesPerSecond = 60
        self.displayLink.add(to: RunLoop.current, forMode: .common)
    }
    

    func handleDisplayLinkCallback() {
        if self.stopAngle == CGFloat(MAXFLOAT) {
            /// 如果没有拿到停止的角度时，则每一帧转四分之一个蛋糕
            self.currentAngle = (self.currentAngle + CGFloat(Double.pi * 2 / 8) * 0.25).truncatingRemainder(dividingBy: CGFloat(Double.pi * 2))
        } else {
            /// 如果拿到了停止角度时
            let offsetAngle = self.stopAngle - self.targetStopAngle
            if offsetAngle <= 0.0000001 {
                self.displayLink.invalidate()
                self.displayLink.remove(from: .current, forMode: .common)
            } else {
                self.targetStopAngle += offsetAngle / 60
                self.currentAngle = (self.currentAngle +  offsetAngle / 60).truncatingRemainder(dividingBy: CGFloat(Double.pi * 2))
            }
        }
        self.lotteryDrawView.transform = CGAffineTransform(rotationAngle: self.currentAngle)
    }
    
    var stopAngle = CGFloat(MAXFLOAT)
    var targetStopAngle = CGFloat(MAXFLOAT)
    var currentAngle: CGFloat = 0
    
    /// 停止的索引
    func stopAtIndex(_ stopIndex: Int) {
        self.stopAngle = CGFloat(Double.pi * 2 / 8) * CGFloat(stopIndex + 1) + CGFloat(Double.pi * 2) * 2
        self.targetStopAngle = self.currentAngle
    }
}
