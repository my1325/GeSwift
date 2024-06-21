//
//  File.swift
//  
//
//  Created by mayong on 2024/6/17.
//

import Foundation
import UIKit

public extension GeTool where Base: UITextView {
    var textColor: GeToolColorCompatible? {
        get { base.textColor }
        set { base.textColor = newValue?.uiColor }
    }
}
