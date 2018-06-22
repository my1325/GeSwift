//
//  UIAlertViewController+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/23.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UIAlertController

extension Ge where Base: UIAlertController {
    
    /// 取消
    ///
    /// - Parameters:
    ///   - title: title
    ///   - touch: 回调事件
    public func cancel(title: String?, touch: (() -> Void)?) -> Ge<Base> {
        let action = UIAlertAction(title: title, style: .cancel) {(action) in
            if let touch = touch {
                touch()
            }
        }
        base.addAction(action)
        return self
    }
    
    /// destructive
    ///
    /// - Parameters:
    ///   - title: title
    ///   - touch: 回调
    public func destructive(title: String, touch: (()->Void)?) -> Ge<Base> {
        let action = UIAlertAction(title: title, style: .destructive) {(action) in
            if let touch = touch {
                touch()
            }
        }
        base.addAction(action)
        return self
    }
    
    /// 其他按钮
    ///
    /// - Parameters:
    ///   - others: 按钮的title数组
    ///   - touch: 回调时间
    public func other(others: [String]?, touch: ((Int) -> Void)?) -> Ge<Base> {
        guard  let others = others else { return self }
        for index in 0 ..< others.count {
            let action = UIAlertAction(title: others[index],
                                       style: .default,
                                       handler:
                { (action) in
                    if let touch = touch {
                        touch(index)
                    }
            })
            base.addAction(action)
        }
        return self
    }
    
    /// 弹出窗口
    ///
    /// - Parameter viewController: vc
    public func show(InViewController viewController: UIViewController?) {
        vc?.present(base, animated: true, completion: nil)
    }
}

