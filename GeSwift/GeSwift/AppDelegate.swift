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
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
        
        struct Test: Decodable {
            @DefaultIntValue
            var value: Int?
        }
        
        func testDefaultCodable() throws {
            let jsonData = #"{"value": "123123"}"#.data(using: .utf8)!
            let test = try JSONDecoder().decode(Test.self, from: jsonData)
            print(test)
        }
        try? testDefaultCodable()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

