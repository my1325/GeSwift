//
//  Singal.swift
//  GeSwift
//
//  Created by my on 2020/6/13.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

public protocol SingalCompatibleType {
    associatedtype Element
    
    func asSingal() -> Singal<Element>
}

open class Singal<Element>: SingalCompatibleType {
    
    public func asSingal() -> Singal<Element> {
        return self
    }
    
    public typealias SingalCreater = (Driver<Element>) -> Disposeable
    
    public let singleCreater: SingalCreater
    public init(creater: @escaping SingalCreater) {
        singleCreater = creater
    }
    
//    public func subscribe(onSuccess: @escaping (Element) -> Void = { _ in },
//                   onError: @escaping (Error) -> Void = { _ in },
//                   onCompleted: @escaping () -> Void = {}) -> Disposeable {
//
//        let disposeBag = DisposeBag()
//
//        let dispose = DisposeToken()
//        let driver = Driver<Element> { event in
//            switch event {
//            case let .next(value):
//                onSuccess(value)
//            case let .error(error):
//                onError(error)
//                dispose.dispose()
//            case .completed:
//                dispose.dispose()
//                onCompleted()
//            }
//        }
//        let createrDispose = singleCreater(driver)
//
//        disposeBag.insert(disposes: dispose, createrDispose)
//        return disposeBag.insert(disposes: DisposeToken({
//
//        }))
//    }
    
    public func subscribe(on: @escaping (Event<Element>) -> Void) -> Disposeable {
        return singleCreater(Driver(on))
    }
}
