//
//  File.swift
//  
//
//  Created by mayong on 2024/8/16.
//

import UIKit
import Combine

public enum GeToolButtonKeyPath {
    case title(String)
    case titleColor(GeToolColorCompatible)
    case attributeString(NSAttributedString)
    case image(GeToolImageCompatible)
    case backgroundImage(GeToolImageCompatible)

    public func set(
        _ button: UIButton,
        for: UIControl.State
    ) {
        switch self {
        case let .title(title):
            button.setTitle(
                title,
                for: `for`
            )
        case let .titleColor(color):
            button.setTitleColor(
                color.uiColor,
                for: `for`
            )
        case let .attributeString(attributeString):
            button.setAttributedTitle(attributeString, for: `for`)
        case let .image(image):
            button.setImage(
                image.uiImage,
                for: `for`
            )
        case let .backgroundImage(image):
            button.setBackgroundImage(
                image.uiImage,
                for: `for`
            )
        }
    }
}

public extension GeTool where Base: UIButton {
    func setBackgroundImage(
        _ backgroundImage: GeToolImageCompatible,
        for state: UIControl.State
    ) {
        base.setBackgroundImage(
            backgroundImage.uiImage,
            for: state
        )
    }
    
    func setImage(
        _ image: GeToolImageCompatible,
        for state: UIControl.State
    ) {
        base.setImage(image.uiImage, for: state)
    }
    
    func setTitleColor(
        _ color: GeToolColorCompatible,
        for state: UIControl.State
    ) {
        base.setTitleColor(color.uiColor, for: .normal)
    }
    
    func tap(_ block: @escaping (UIButton) -> Void) {
        addEvent(.touchUpInside, block: block)
    }
    
    var tapPublisher: AnyPublisher<Base, Never> {
        publisher(.touchUpInside)
    }
    
    func setValue(_ keyPath: GeToolButtonKeyPath, for: UIControl.State) {
        keyPath.set(
            base,
            for: `for`
        )
    }
    
    func setValues(
        _ for: UIControl.State,
        configs: @autoclosure () -> [GeToolButtonKeyPath]
    ) {
        configs().forEach {
            $0.set(
                base,
                for: `for`
            )
        }
    }
}
