//
//  File.swift
//  
//
//  Created by mayong on 2024/8/1.
//

import UIKit

public final class CycleScrollRTLLayout: UICollectionViewFlowLayout {
    let isEnableRTL: Bool
    init(_ isEnableRTL: Bool) {
        self.isEnableRTL = isEnableRTL
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        isEnableRTL
    }
}
