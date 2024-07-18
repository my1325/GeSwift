//
//  File.swift
//  
//
//  Created by mayong on 2024/6/17.
//

import Foundation
import UIKit
import Combine

public extension GeTool where Base: UITextView {
    var textColor: GeToolColorCompatible? {
        get { base.textColor }
        set { base.textColor = newValue?.uiColor }
    }
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: base
        )
        .map { [weak base] _ in base?.text ?? "" }
        .eraseToAnyPublisher()
    }
}
