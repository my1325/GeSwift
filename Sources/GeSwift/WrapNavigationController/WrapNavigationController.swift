//
//  WrapNavigationController.swift
//  XGXWKit
//
//  Created by my on 2020/12/15.
//

import UIKit

fileprivate final class WrapNavigationController: UINavigationController {
    
    fileprivate weak var parentWrapViewController: WrapViewController?
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let vc = WrapViewController(viewController)
        vc.hidesBottomBarWhenPushed = true 
        parentWrapViewController?.navigationController?.pushViewController(vc, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return parentWrapViewController?.navigationController?.popViewController(animated: animated)
    }
    
    override var viewControllers: [UIViewController] {
        get { return parentWrapViewController?.navigationController?.viewControllers ?? [] }
        set { self.setViewControllers(newValue, animated: false) }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if animated {
            parentWrapViewController?.navigationController?.setViewControllers(viewControllers, animated: animated)
        } else {
            super.setViewControllers(viewControllers, animated: false)
        }
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]?{
        return parentWrapViewController?.navigationController?.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return parentWrapViewController?.navigationController?.popToViewController(viewController, animated: animated)
    }
    override var delegate: UINavigationControllerDelegate?{
        get { return parentWrapViewController?.navigationController?.delegate }
        set { parentWrapViewController?.navigationController?.delegate = newValue }
    }
    
    override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        get { return parentWrapViewController?.navigationController?.interactivePopGestureRecognizer }
    }
}

public final class WrapViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public var style : UIStatusBarStyle = .default

    public override var preferredStatusBarStyle: UIStatusBarStyle{
        return contentViewController?.preferredStatusBarStyle ?? style
    }
    
    public init(_ viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.contentViewController = viewController
        
        let navigationController = WrapNavigationController()
        navigationController.viewControllers = [viewController]
        navigationController.parentWrapViewController = self
        
        self.addChild(navigationController)
        self.view.addSubview(navigationController.view)
    }
    
    public var contentViewController: UIViewController?
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
//        extendedLayoutIncludesOpaqueBars = true
//        edgesForExtendedLayout = .all
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
