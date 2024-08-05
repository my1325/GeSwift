//
//  File.swift
//
//
//  Created by mayong on 2024/8/5.
//

import Combine
import UIKit

public extension Publisher {
    func bind<S>(_ reload: @escaping ([S]) -> Void) -> AnyCancellable where S: SectionProtocol, Output == [S], Failure == Never {
        receive(on: DispatchQueue.main)
            .sink { sections in
                reload(sections)
            }
    }

    func bind<I>(_ reload: @escaping ([I]) -> Void) -> AnyCancellable where Output == [I], Failure == Never {
        receive(on: DispatchQueue.main)
            .sink { items in
                reload(items)
            }
    }
}
