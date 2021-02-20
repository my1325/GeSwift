//
//  UIButton+Rx.swift
//  GeSwift
//
//  Created by my on 2021/2/19.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: UIButton {

    func tap() -> Observable<Base> {
        return base.rx.tap.asObservable().flatMap { _ in Observable.just(base) }
    }
    
    var oppositiveSelectedWhenTap: Observable<Bool> {
        return tap().do(onNext: { $0.isSelected = !$0.isSelected }).map({ $0.isSelected })
    }
}
