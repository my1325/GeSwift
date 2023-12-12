//
//  TextView.swift
//  SwiftUI
//
//  Created by mayong on 2023/12/11.
//

import Combine
import SwiftUI
import UIKit

public struct TextView: UIViewRepresentable {
    public typealias UIViewType = UITextView
    public typealias TextDidChange = (String) -> Void
    public typealias TextBeginChange = () -> Void
    
    @Binding
    public var text: String
    
    public let textDidChange: TextDidChange
    public let textBeginChange: TextBeginChange
    public let textEndChange: TextBeginChange
    public init(text: Binding<String>,
                textDidChange: @escaping TextDidChange = { _ in },
                textBeginChange: @escaping TextBeginChange = {},
                textEndChange: @escaping TextBeginChange = {})
    {
        self._text = text
        self.textDidChange = textDidChange
        self.textBeginChange = textBeginChange
        self.textEndChange = textEndChange
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let textView = UIViewType()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        let linefragmentPadding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -linefragmentPadding, bottom: 0, right: -linefragmentPadding)
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.text = text
        return textView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        uiView.text = text
        if !text.isEmpty {
            textDidChange(text)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(textView: self)
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        let parent: TextView
        init(textView: TextView) {
            self.parent = textView
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
    }
}

public struct PlaceholderStyle: View {
    public var body: some View {
        Rectangle()
            .fill(Color.clear)
    }
    
    public let forgroundColor: Color
    public let font: Font
    public init(forgroundColor: Color = .clear, font: Font = .system(size: 17)) {
        self.forgroundColor = forgroundColor
        self.font = font
    }
}

public extension TextView {
    func placeholderStyle(_ placeholderStyle: PlaceholderStyle) -> TextView {
        
    }
    
    private init(textView: TextView, placeholderStyle: PlaceholderStyle) {
        
    }
}

#Preview(body: {
    TextView(text: .constant(""))
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1.0)
        )
        .padding()
        .overlay(
            PlaceholderStyle(forgroundColor: <#Color#>, font: <#Font#>)
        )
})
