//
//  UITextView+Rx.swift
//  GeSwift
//
//  Created by my on 2021/2/19.
//  Copyright © 2021 my. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: UITextView {
    
    func setLimitCount(_ count: Int) -> Disposable {
        return text.subscribe(onNext: { [weak textView = base] _ in
            if let text = textView?.text,  text.count > count {
                textView?.text = String(text.prefix(count))
            }
        })
    }

    func whenCountEqual(_ count: Int) -> Observable<Void> {
        return text.filter({ ($0?.count ?? 0) == count }).flatMap({ _ in Observable.just(()) })
    }
    
    func setLimitCount(_ count: Int)
    -> (_ block: @escaping () -> Void)
    -> Disposable
    {
        return { handler in
            return text.subscribe { [weak textView = base] _ in
                guard let text = textView?.text else { return }
                if text.count == count {
                    handler()
                } else if text.count > count {
                    textView?.text = String(text.prefix(count))
                }
            }
        }
    }
}
