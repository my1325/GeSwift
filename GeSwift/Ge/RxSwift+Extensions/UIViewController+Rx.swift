//
//  UIViewController+RxSwift.swift
//  GeSwift
//
//  Created by my on 2021/2/19.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    var willAppear: Observable<Void> {
        return methodInvoked(#selector(base.viewWillAppear(_:))).map({ _ in () })
    }
    
    var didAppear: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:))).map({ _ in () })
    }
    
    var willDisappear: Observable<Void> {
        return methodInvoked(#selector(base.viewWillDisappear(_:))).map({ _ in () })
    }
    
    var didDisappear: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:))).map({ _ in () })
    }

}
