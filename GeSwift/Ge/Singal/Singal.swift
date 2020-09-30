//
//  Singal.swift
//  GeSwift
//
//  Created by my on 2020/6/13.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

struct DisposeToken {
    typealias DisposeHandler = (DisposeToken) -> Void
    let handler: DisposeHandler
    init(handler: @escaping DisposeHandler) {
        self.handler = handler
    }
    
    init() {
        self.handler = { _ in }
    }
    
    func dispose() {
        handler(self)
    }
}

struct SingleCreater<Element> {
    
    typealias DoHandler = (Result<Element, Error>) -> Void
    let handler: DoHandler
    init(doHandler: @escaping DoHandler) {
        handler = doHandler
    }
    
    func `do`(on: Result<Element, Error>) {
        handler(on)
    }
}

struct Singal<Element> {
    
    typealias Singler = (SingleCreater<Element>) -> DisposeToken
    
    let singleCreater: Singler
    init(creater: @escaping Singler) {
        singleCreater = creater
    }
    
    func subscribe(onSuccess: @escaping (Element) -> Void = { _ in }, onError: @escaping (Error) -> Void = { _ in }) -> DisposeToken {
        return subscribe { result in
            switch result {
            case let .success(element):
                onSuccess(element)
            case let .failure(error):
                onError(error)
            }
        }
    }
    
    func subscribe(handler: @escaping (Result<Element, Error>) -> Void) -> DisposeToken {
        let dispose = self.singleCreater(SingleCreater(doHandler: handler))
        return DisposeToken { _ in
            dispose.dispose()
        }
    }
}
