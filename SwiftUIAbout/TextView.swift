//
//  TextView.swift
//  SwiftUI
//
//  Created by mayong on 2023/12/11.
//
#if canImport(UIKit)

import SwiftUI
import UIKit

public struct TextViewPlaceholder {
    let placeholderLabel: UILabel
    
    init(uiLabel: UILabel) {
        placeholderLabel = uiLabel
    }
    
    func applyToTextView(_ textView: UITextView) {
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
    }
}

public struct TextViewConfig {
    let foregroundColor: UIColor
    let returnKeyType: UIReturnKeyType
    let tintColor: UIColor
    let textAlignment: NSTextAlignment
    let font: UIFont
    let backgroundColor: UIColor
    
    public init(foregroundColor: UIColor = .black,
                returnKeyType: UIReturnKeyType = .default,
                tintColor: UIColor = .black,
                textAlignment: NSTextAlignment = .left,
                font: UIFont = .systemFont(ofSize: 17),
                backgroundColor: UIColor = .clear)
    {
        self.foregroundColor = foregroundColor
        self.returnKeyType = returnKeyType
        self.tintColor = tintColor
        self.textAlignment = textAlignment
        self.font = font
        self.backgroundColor = backgroundColor
    }
    
    func applyToTextView(_ textView: UITextView) {
        textView.textColor = foregroundColor
        textView.returnKeyType = returnKeyType
        textView.tintColor = tintColor
        textView.textAlignment = textAlignment
        textView.font = font
        textView.backgroundColor = backgroundColor
    }
}

public struct TextView: UIViewRepresentable {
    public typealias UIViewType = UITextView
    public typealias TextDidChange = (String) -> Void
    public typealias TextBeginChange = () -> Void
    public typealias PlaceholderGetter = () -> TextViewPlaceholder
    public typealias ConfigGetter = () -> TextViewConfig
    public typealias TextShouldChanged = (String, Range<String.Index>, String) -> Bool

    @Binding
    public var text: String
    public let isEditing: Bool
    public let textShouldChange: TextShouldChanged
    public let textDidChange: TextDidChange
    public let textBeginChange: TextBeginChange
    public let textEndChange: TextBeginChange
    public let textPlaceholder: PlaceholderGetter
    public let textConfig: ConfigGetter
    public init(text: Binding<String>,
                isEditing: Bool,
                textConfig: @escaping ConfigGetter = { TextViewConfig() },
                textPlaceholder: @escaping PlaceholderGetter = { TextViewPlaceholder("") },
                textShouldChange: @escaping TextShouldChanged = { _, _, _ in true },
                textDidChange: @escaping TextDidChange = { _ in },
                textBeginChange: @escaping TextBeginChange = {},
                textEndChange: @escaping TextBeginChange = {})
    {
        _text = text
        self.isEditing = isEditing
        self.textPlaceholder = textPlaceholder
        self.textDidChange = textDidChange
        self.textBeginChange = textBeginChange
        self.textEndChange = textEndChange
        self.textConfig = textConfig
        self.textShouldChange = textShouldChange
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let textView = UIViewType()
        textConfig().applyToTextView(textView)
        textPlaceholder().applyToTextView(textView)
        textView.delegate = context.coordinator
        let linefragmentPadding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -linefragmentPadding, bottom: 0, right: -linefragmentPadding)
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.text = text
        return textView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        uiView.text = text
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
        Coordinator(textView: self)
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        var didBecomeFirstResponder: Bool = false 
        var didResignFirstResponder: Bool = false
        let parent: TextView
        init(textView: TextView) {
            parent = textView
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
            parent.textDidChange(textView.text ?? "")
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            parent.textBeginChange()
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            parent.textEndChange()
        }
        
        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let origin = textView.text ?? ""
            if let from16 = origin.utf16.index(origin.utf16.startIndex, offsetBy: range.location, limitedBy: origin.utf16.endIndex),
               let to16 = origin.utf16.index(from16, offsetBy: range.length, limitedBy: origin.utf16.endIndex),
               let from = String.Index(from16, within: origin),
               let to = String.Index(to16, within: origin)
            {
                return parent.textShouldChange(origin, from ..< to, text)
            } else {
                let startIndex = origin.index(origin.startIndex, offsetBy: range.lowerBound)
                let endIndex = origin.index(origin.startIndex, offsetBy: range.upperBound)
                return parent.textShouldChange(origin, startIndex ..< endIndex, text)
            }
        }
    }
}

public extension TextViewPlaceholder {
    init(_ placeholder: String) {
        placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
    }
    
    init(_ attributeString: NSAttributedString) {
        placeholderLabel = UILabel()
        placeholderLabel.attributedText = attributeString
    }

    func forgroundColor(_ uiColor: UIColor) -> TextViewPlaceholder {
        placeholderLabel.textColor = uiColor
        return TextViewPlaceholder(uiLabel: placeholderLabel)
    }
    
    func forgroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextViewPlaceholder {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return forgroundColor(color)
    }
    
    func font(_ uiFont: UIFont) -> TextViewPlaceholder {
        placeholderLabel.font = uiFont
        return TextViewPlaceholder(uiLabel: placeholderLabel)
    }
    
    func systemFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> TextViewPlaceholder {
        font(.systemFont(ofSize: size, weight: weight))
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> TextViewPlaceholder {
        placeholderLabel.textAlignment = alignment
        return TextViewPlaceholder(uiLabel: placeholderLabel)
    }
    
    func numberOfLines(_ lines: Int) -> TextViewPlaceholder {
        placeholderLabel.numberOfLines = lines
        return TextViewPlaceholder(uiLabel: placeholderLabel)
    }
}

public extension TextViewConfig {
    func forgroundColor(_ uiColor: UIColor) -> TextViewConfig {
        .init(foregroundColor: uiColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: textAlignment,
              font: font,
              backgroundColor: backgroundColor)
    }
    
    func forgroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return forgroundColor(color)
    }
    
    func font(_ uiFont: UIFont) -> TextViewConfig {
        .init(foregroundColor: foregroundColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: textAlignment,
              font: uiFont,
              backgroundColor: backgroundColor)
    }
    
    func systemFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> TextViewConfig {
        font(.systemFont(ofSize: size, weight: weight))
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> TextViewConfig {
        .init(foregroundColor: foregroundColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: alignment,
              font: font,
              backgroundColor: backgroundColor)
    }
    
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> TextViewConfig {
        .init(foregroundColor: foregroundColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: textAlignment,
              font: font,
              backgroundColor: backgroundColor)
    }
    
    func tintColor(_ tintColor: UIColor) -> TextViewConfig {
        .init(foregroundColor: foregroundColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: textAlignment,
              font: font,
              backgroundColor: backgroundColor)
    }
    
    func tintColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return tintColor(color)
    }
    
    func backgroundColor(_ backgroundColor: UIColor) -> TextViewConfig {
        .init(foregroundColor: foregroundColor,
              returnKeyType: returnKeyType,
              tintColor: tintColor,
              textAlignment: textAlignment,
              font: font,
              backgroundColor: backgroundColor)
    }
    
    func backgroundColor(_ hexValue: UInt, alpha: CGFloat = 1) -> TextViewConfig {
        let red = CGFloat((hexValue >> 16) & 0xFF) / 255
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255
        let blue = CGFloat(hexValue & 0xFF) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return backgroundColor(color)
    }
}

public extension TextView {
    func textPlaceholder(_ textPlaceholder: @escaping PlaceholderGetter) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
    
    func textConfig(_ textConfig: @escaping ConfigGetter) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
    
    func textDidChange(_ textDidChange: @escaping TextDidChange) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
    
    func textBeginChange(_ textBeginChange: @escaping TextBeginChange) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
    
    func textEndChange(_ textEndChange: @escaping TextBeginChange) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
    
    func textShouldChange(_ textShouldChange: @escaping TextShouldChanged) -> TextView {
        TextView(text: _text,
                 isEditing: isEditing,
                 textConfig: textConfig,
                 textPlaceholder: textPlaceholder,
                 textShouldChange: textShouldChange,
                 textDidChange: textDidChange,
                 textBeginChange: textBeginChange,
                 textEndChange: textEndChange)
    }
}
#endif
