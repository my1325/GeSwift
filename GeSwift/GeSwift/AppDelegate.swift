//
//  AppDelegate.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit
import HandyJSON

let iphone_scale: CGFloat = UIScreen.main.scale
let iphone_width: CGFloat = UIScreen.main.bounds.size.width
let iphone_height: CGFloat = UIScreen.main.bounds.size.height
let statusBar_height: CGFloat = UIApplication.shared.statusBarFrame.size.height
let navigationBar_height: CGFloat = 44 + statusBar_height
let is_iphoneX: Bool = statusBar_height > 20
let tabBar_height: CGFloat = 49 + (is_iphoneX ? 34.0 : 0)

extension DefaultsKeys {
    static let test = DefaultsKey<TestModel>(key: "com.codable.test.model")
    static let test_array = DefaultsKey<[TestModel]>(key: "com.codable.test.model.array")
}

struct TestModel: Codable {
    var id: String = ""
    var name: String = ""
    var age: Int = 21
    var gender: Int = 1
    init(id: String, name: String, age: Int, gender: Int) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
    }
    
    init() {}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    @DefaultPlistProperty(key: "test", defaultValue: nil)
    var test: TestModel?

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
        
//        let test0 = TestModel(id: "saf", name: "sfsadf", age: 12, gender: 1)
//        let test1 = TestModel(id: "adfadsf", name: "112321", age: 15, gender: 2)
//        let test2 = TestModel(id: "afadsf", name: "lkjlfkasdjflk", age: 21, gender: 1)
//
//        Plist.default.set(test0, for: .test)
//        Plist.default.set([test0, test1, test2], for: .test_array)
        /// [Any]的存储，[String: Any]的存储
        Plist.default["com.test.dictionary"] = ["a": 1, "b": 1, "c": 1]
        Plist.default["com.test.array"] = ["asf", "b", "c", "d", "1"]
        Plist.default["com.test.back"] = false
        Plist.default["com.test.date"] = Date()
        print("------------")
        
        let test0_read = Plist.default.value(for: .test)
        let test_list_read = Plist.default.value(for: .test_array)
        test = test0_read
        return true
    }
}

