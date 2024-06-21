//
//  WrapNavigationController.swift
//
//  Created by my on 2020/12/15.
//

import UIKit

private final class WrapNavigationController: UINavigationController {
    fileprivate weak var parentWrapViewController: WrapViewController?
    override func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        let vc = WrapViewController(viewController)
        vc.hidesBottomBarWhenPushed = true
        parentWrapViewController?.navigationController?
            .pushViewController(vc, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return parentWrapViewController?.navigationController?
            .popViewController(animated: animated)
    }
    
    override var viewControllers: [UIViewController] {
        get {
            return parentWrapViewController?
                .navigationController?
                .viewControllers ?? []
        }
        set {
            self.setViewControllers(newValue, animated: false)
        }
    }
    
    override func setViewControllers(
        _ viewControllers: [UIViewController],
        animated: Bool
    ) {
        if animated {
            parentWrapViewController?.navigationController?
                .setViewControllers(viewControllers, animated: animated)
        } else {
            super.setViewControllers(viewControllers, animated: false)
        }
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return parentWrapViewController?.navigationController?
            .popToRootViewController(animated: animated)
    }
    
    override func popToViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        return parentWrapViewController?.navigationController?
            .popToViewController(viewController, animated: animated)
    }

    override var delegate: UINavigationControllerDelegate? {
        get {
            parentWrapViewController?
                .navigationController?
                .delegate
        }
        set {
            parentWrapViewController?
                .navigationController?
                .delegate = newValue
        }
    }
    
    override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        parentWrapViewController?.navigationController?
            .interactivePopGestureRecognizer
    }
}

public final class WrapViewController: UIViewController {
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public var style: UIStatusBarStyle = .default

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        contentViewController?.preferredStatusBarStyle ?? style
    }
    
    public init(_ viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.contentViewController = viewController
        
        let navigationController = WrapNavigationController()
        navigationController.viewControllers = [viewController]
        navigationController.parentWrapViewController = self
        
        addChild(navigationController)
        view.addSubview(navigationController.view)
    }
    
    public var contentViewController: UIViewController?
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
