//
//  File.swift
//  
//
//  Created by mayong on 2024/6/17.
//

import Foundation
import UIKit

public extension GeTool where Base: UIImageView {
    var image: GeToolImageCompatible? {
        get { base.image }
        set { base.image = newValue?.uiImage }
    }
}
