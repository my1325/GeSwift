//
//  UIWindow+Ge.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2018/11/26.
//  Copyright © 2018 my. All rights reserved.
//

import UIKit

extension Ge where Base: UIWindow {

    public var currentViewController: UIViewController? {
        var currentViewController = topMostViewController

        while let naviController = currentViewController as? UINavigationController,
            let topViewController = naviController.topViewController {
                currentViewController = topViewController
        }

        return currentViewController
    }

    public var topMostViewController: UIViewController? {
        //  getting rootViewController
        var topController = base.rootViewController
        //  Getting topMost ViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        //  Returning topMost ViewController
        return topController
    }

    public var currentController: UIViewController! {
        let root  = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController
        let nav = root?.selectedViewController as? UINavigationController
        let controller = nav?.topViewController
        return controller
    }
}
