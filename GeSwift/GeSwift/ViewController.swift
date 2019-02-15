//
//  ViewController.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var testView = UIView()
        testView.backgroundColor = UIColor.red
        testView.ge.size = CGSize(width: 100, height: 100)
        testView.ge.x = 200
        testView.ge.y = 200
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            testView.ge.animation(animation: { (animator) in
//                animator.translation(x: 100, y: 100).scale(x: 0.8).scale(y: 1.2).rotate(CGFloat(Double.pi))
//            })
            testView.ge.springAnimation(springDamping: 0.8, initialSpringVelocity: 1.0, animation: { (animator) in
                    animator.scale(x: 0.8).scale(y: 1.2)
            })
        }
        self.view.addSubview(testView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

