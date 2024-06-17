//
//  File.swift
//  
//
//  Created by mayong on 2024/6/17.
//

import UIKit

public extension GeTool where Base: UILabel {
    var textColor: GeToolColorCompatible? {
        get { base.textColor }
        set { base.textColor = newValue?.uiColor }
    }
}
