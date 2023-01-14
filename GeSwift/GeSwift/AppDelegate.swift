//
//  AppDelegate.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit

let iphone_scale: CGFloat = UIScreen.main.scale
let iphone_width: CGFloat = UIScreen.main.bounds.size.width
let iphone_height: CGFloat = UIScreen.main.bounds.size.height
let statusBar_height: CGFloat = UIApplication.shared.statusBarFrame.size.height
let navigationBar_height: CGFloat = 44 + statusBar_height
let is_iphoneX: Bool = statusBar_height > 20
let tabBar_height: CGFloat = 49 + (is_iphoneX ? 34.0 : 0)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /// appearance
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.lightGray
        UINavigationBar.appearance().setBackgroundImage(UIImage.ge.image(withColor: UIColor.white, size: CGSize(width: iphone_width, height: navigationBar_height)),
                                                        for: UIBarMetrics.default)
        UITabBar.appearance().tintColor = UIColor.lightGray
        UITabBar.appearance().barTintColor = UIColor.white
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: WrapViewController(ViewController()))
        self.window?.makeKeyAndVisible()
        return true
    }
}

