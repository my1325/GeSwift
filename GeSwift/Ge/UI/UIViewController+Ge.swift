//
//  UIViewController+Ge.swift
//  GXWSwift
//
//  Created by m y on 2017/10/20.
//  Copyright © 2017年 MY. All rights reserved.
//

import UIKit.UINavigationController
import Photos

fileprivate class GeWrapNavigationController: UINavigationController {
    fileprivate weak var parentWrapViewController: GeWrapVC?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let vc = GeWrapVC.wraped(viewController)
        vc.hidesBottomBarWhenPushed = true
        parentWrapViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return parentWrapViewController?.navigationController?.popViewController(animated: animated)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if animated {
            parentWrapViewController?.navigationController?.setViewControllers(viewControllers, animated: animated)
        }
        else {
            super.setViewControllers(viewControllers, animated: false)
        }
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return parentWrapViewController?.navigationController?.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return parentWrapViewController?.navigationController?.popToViewController(viewController, animated: animated)
    }
    
    override var delegate: UINavigationControllerDelegate? {
        get { return parentWrapViewController?.navigationController?.delegate }
        set { parentWrapViewController?.navigationController?.delegate = delegate }
    }
    
    override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        get { return parentWrapViewController?.navigationController?.interactivePopGestureRecognizer }
    }
}

class GeWrapVC: UIViewController {
    static func wraped(_ vc: UIViewController) -> GeWrapVC {
        let wrapVC = GeWrapVC()
        wrapVC.contentVC = vc
        
        let vcs: [UIViewController] = [vc]
        
        let navi = GeWrapNavigationController()
        navi.setViewControllers(vcs, animated: false)
        navi.parentWrapViewController = wrapVC
        navi.hidesBottomBarWhenPushed = true
        wrapVC.addChildViewController(navi)
        wrapVC.view.addSubview(navi.view)
        return wrapVC
    }

    var contentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .init(rawValue: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension UIViewController: UIGestureRecognizerDelegate {}

extension Ge where Base: UIViewController {
    public func hideShadow() {
        base.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    public func showShadow() {
        base.navigationController?.navigationBar.shadowImage = nil
    }
    
    public func showShadow(color: UIColor) {
        base.navigationController?.navigationBar.shadowImage = UIImage.ge.with(color: color, size: CGSize(width: UIScreen.main.bounds.size.width, height: 1 / UIScreen.main.scale))
    }
    
    public func enablePopInteractive() {
        base.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        base.navigationController?.interactivePopGestureRecognizer?.delegate = base;
    }
    
    public func disablePopInteractive() {
        base.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        base.navigationController?.interactivePopGestureRecognizer?.delegate = base;
    }
    
    static public func wraped(_ vc: UIViewController) -> UIViewController {
        return GeWrapVC.wraped(vc)
    }
}
