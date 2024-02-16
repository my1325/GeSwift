//
//  Protocols.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/25.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public protocol HorizontalDelegate: NSObjectProtocol {
    func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int)
    func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat
}

public extension HorizontalDelegate {
    func horizontalView(_ horizontalView: HorizontalView, didSeletedItemAtIndex index: Int) {}

    func horizontalView(_ horizontalView: HorizontalView, widthForItemAtIndex index: Int) -> CGFloat {
        return 0
    }
}

public protocol HorizontalDataSource: NSObjectProtocol {
    func numberOfItemsInHorizontalView(_ horizontalView: HorizontalView) -> Int
    func horizontalView(_ horizontalView: HorizontalView, titleAtIndex index: Int) -> String
    func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int
}

public extension HorizontalDataSource {
    func horizontalView(_ horizontalView: HorizontalView, badgeAtIndex index: Int) -> Int {
        return 0
    }
}
