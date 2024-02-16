//
//  TextFiled.swift
//  SwiftUI
//
//  Created by mayong on 2023/12/11.
//

import SwiftUI
import UIKit

public struct TextFiledViewConfig {
    let textColor: UIColor
    let font: UIFont
    let alignemnt: NSTextAlignment
    let returnKeyType: UIReturnKeyType
    let keyboardType: UIKeyboardType
    let tintColor: UIColor
    let borderStyle: UITextField.BorderStyle
    let placeholder: NSAttributedString
    let clearButtonMode: UITextField.ViewMode
    let backgroundColor: UIColor
    
    public init(textColor: UIColor = .black,
                font: UIFont = .systemFont(ofSize: 17, weight: .regular),
                alignemnt: NSTextAlignment = .left,
                returnKeyType: UIReturnKeyType = .default,
                keyboardType: UIKeyboardType = .default,
                tintColor: UIColor = .black,
                borderStyle: UITextField.BorderStyle = .none,
                placeholder: NSAttributedString = NSAttributedString(string: ""),
                clearButtonMode: UITextField.ViewMode = .never,
                backgroundColor: UIColor = .clear)
    {
        self.textColor = textColor
        self.font = font
        self.alignemnt = alignemnt
        self.returnKeyType = returnKeyType
        self.keyboardType = keyboardType
        self.tintColor = tintColor
        self.borderStyle = borderStyle
        self.placeholder = placeholder
        self.clearButtonMode = clearButtonMode
        self.backgroundColor = backgroundColor
    }
    
    func appleToTextFiled(_ textFiled: UITextField) {
        textFiled.textColor = textColor
        textFiled.font = font
        textFiled.textAlignment = alignemnt
        textFiled.returnKeyType = returnKeyType
        textFiled.keyboardType = keyboardType
        textFiled.tintColor = tintColor
        textFiled.borderStyle = borderStyle
        textFiled.attributedPlaceholder = placeholder
        textFiled.clearButtonMode = clearButtonMode
        textFiled.backgroundColor = backgroundColor
    }
}

public struct TextFiledView: UIViewRepresentable {
    public typealias UIViewType = UITextField
    
    public typealias ConfigGetter = () -> TextFiledViewConfig
    public typealias EditingEventListener = (UIControl.Event, String) -> Void
    public typealias ShouldBeginEditing = () -> Bool
    public typealias ShouldChangeCharacters = (String, Range<String.Index>, String) -> Bool
    
    @Binding
    public var text: String
    
    @Binding
    public var isSecureTextEntry: Bool
        
    let configGetter: ConfigGetter
    let editingEventListener: EditingEventListener
    let shouldBeginEditing: ShouldBeginEditing
    let shouldChangeCharacters: ShouldChangeCharacters
    let isEditing: Bool

    public init(text: Binding<String>,
                isSecureTextEntry: Binding<Bool> = .constant(false),
                isEditing: Bool,
                configGetter: @escaping ConfigGetter = { TextFiledViewConfig() },
                editingEventListener: @escaping EditingEventListener = { _, _ in },
                shouldBeginEditing: @escaping ShouldBeginEditing = { true },
                shouldChangeCharacters: @escaping ShouldChangeCharacters = { _, _, _ in true })
    {
        self._text = text
        self._isSecureTextEntry = isSecureTextEntry
        self.isEditing = isEditing
        self.configGetter = configGetter
        self.editingEventListener = editingEventListener
        self.shouldBeginEditing = shouldBeginEditing
        self.shouldChangeCharacters = shouldChangeCharacters
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let coordinator = context.coordinator
        let textFiled = UITextField()
        configGetter().appleToTextFiled(textFiled)
        textFiled.isSecureTextEntry = isSecureTextEntry
        textFiled.text = text
        textFiled.delegate = coordinator
        textFiled.addTarget(coordinator, action: #selector(Coordinator.textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
        textFiled.addTarget(coordinator, action: #selector(Coordinator.textFiledEditingChanged(_:)), for: .editingChanged)
        textFiled.addTarget(coordinator, action: #selector(Coordinator.textFiledEditingDidEnd(_:)), for: .editingDidEnd)
        textFiled.addTarget(coordinator, action: #selector(Coordinator.textFiledEditingDidBegin(_:)), for: .editingDidBegin)
        return textFiled
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecureTextEntry
        if isEditing, !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
            context.coordinator.didResignFirstResponder = false
        } else if !isEditing, !context.coordinator.didResignFirstResponder {
            uiView.resignFirstResponder()
            context.coordinator.didResignFirstResponder = true
            context.coordinator.didBecomeFirstResponder = false
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        var didBecomeFirstResponder: Bool = false
        var didResignFirstResponder: Bool = false

        let parent: TextFiledView
        init(parent: TextFiledView) {
            self.parent = parent
        }
        
        @objc
        func textFieldEditingDidEndOnExit(_ textFiled: UITextField) {
            parent.editingEventListener(.editingDidBegin, textFiled.text!)
        }
        
        @objc
        func textFiledEditingChanged(_ textFiled: UITextField) {
            parent.text = textFiled.text ?? ""
            parent.editingEventListener(.editingChanged, textFiled.text!)
        }
        
        @objc
        func textFiledEditingDidEnd(_ textFiled: UITextField) {
            parent.editingEventListener(.editingDidEnd, textFiled.text!)
        }
        
        @objc
        func textFiledEditingDidBegin(_ textFiled: UITextField) {
            parent.editingEventListener(.editingDidBegin, textFiled.text!)
        }
        
        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.shouldBeginEditing()
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {}
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let origin = textField.text ?? ""
            if let from16 = origin.utf16.index(origin.utf16.startIndex, offsetBy: range.location, limitedBy: origin.utf16.endIndex),
               let to16 = origin.utf16.index(from16, offsetBy: range.length, limitedBy: origin.utf16.endIndex),
               let from = String.Index(from16, within: origin),
               let to = String.Index(to16, within: origin)
            {
                return parent.shouldChangeCharacters(origin, from ..< to, string)
            } else {
                let startIndex = origin.index(origin.startIndex, offsetBy: range.lowerBound)
                let endIndex = origin.index(origin.startIndex, offsetBy: range.upperBound)
                return parent.shouldChangeCharacters(origin, startIndex ..< endIndex, string)
            }
        }
    }
}

public extension TextFiledView {
    func configuration(_ config: @escaping ConfigGetter) -> TextFiledView {
        .init(text: _text,
              isSecureTextEntry: _isSecureTextEntry,
              isEditing: isEditing,
              configGetter: config,
              editingEventListener: editingEventListener,
              shouldBeginEditing: shouldBeginEditing,
              shouldChangeCharacters: shouldChangeCharacters)
    }
    
    func editingEventListener(_ editingEventListener: @escaping EditingEventListener) -> TextFiledView {
        .init(text: _text,
              isSecureTextEntry: _isSecureTextEntry,
              isEditing: isEditing,
              configGetter: configGetter,
              editingEventListener: editingEventListener,
              shouldBeginEditing: shouldBeginEditing,
              shouldChangeCharacters: shouldChangeCharacters)
    }
    
    func shouldBeginEditing(_ shouldBeginEditing: @escaping ShouldBeginEditing) -> TextFiledView {
        .init(text: _text,
              isSecureTextEntry: _isSecureTextEntry,
              isEditing: isEditing,
              configGetter: configGetter,
              editingEventListener: editingEventListener,
              shouldBeginEditing: shouldBeginEditing,
              shouldChangeCharacters: shouldChangeCharacters)
    }
    
    func shouldChangeCharacters(_ shouldChangeCharacters: @escaping ShouldChangeCharacters) -> TextFiledView {
        .init(text: _text,
              isSecureTextEntry: _isSecureTextEntry,
              isEditing: isEditing,
              configGetter: configGetter,
              editingEventListener: editingEventListener,
              shouldBeginEditing: shouldBeginEditing,
              shouldChangeCharacters: shouldChangeCharacters)
    }
}

public extension TextFiledViewConfig {
    func foregroundColor(_ foregroundColor: UIColor) -> TextFiledViewConfig {
        .init(textColor: foregroundColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func foregroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextFiledViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return foregroundColor(color)
    }
    
    func font(_ font: UIFont) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func alignemnt(_ alignemnt: NSTextAlignment) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func keyboardType(_ keyboardType: UIKeyboardType) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func tintColor(_ tintColor: UIColor) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func tintColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextFiledViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return tintColor(color)
    }
    
    func borderStyle(_ borderStyle: UITextField.BorderStyle) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func placeholder(_ placeholder: NSAttributedString) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func placeholder(_ string: String) -> TextFiledViewConfig {
        placeholder(NSAttributedString(string: string))
    }
    
    func placeholderForgroundColor(_ color: UIColor) -> TextFiledViewConfig {
        let attributeString = NSMutableAttributedString(attributedString: placeholder)
        attributeString.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, placeholder.length))
        return placeholder(attributeString)
    }
    
    func placeholderForgroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextFiledViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return placeholderForgroundColor(color)
    }
    
    func placeholderFont(_ font: UIFont) -> TextFiledViewConfig {
        let attributeString = NSMutableAttributedString(attributedString: placeholder)
        attributeString.addAttribute(.font, value: font, range: NSMakeRange(0, placeholder.length))
        return placeholder(attributeString)
    }
    
    func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func backgroundColor(_ backgroundColor: UIColor) -> TextFiledViewConfig {
        .init(textColor: textColor,
              font: font,
              alignemnt: alignemnt,
              returnKeyType: returnKeyType,
              keyboardType: keyboardType,
              tintColor: tintColor,
              borderStyle: borderStyle,
              placeholder: placeholder,
              clearButtonMode: clearButtonMode,
              backgroundColor: backgroundColor)
    }
    
    func backgroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextFiledViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return backgroundColor(color)
    }
}
