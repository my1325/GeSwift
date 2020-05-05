//
//  Function.swift
//  GeSwift
//
//  Created by mayong on 2020/4/30.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

/// 递归方法调用
public func recursive(_ function: @escaping (() -> Void) -> Void) -> () -> Void {
    return {
        function(recursive(function))
    }
}
