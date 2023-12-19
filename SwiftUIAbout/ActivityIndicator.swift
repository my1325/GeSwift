//
//  ActivityIndicator.swift
//  JokyNote
//
//  Created by mayong on 2023/11/28.
//

import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    public typealias UIViewType = UIActivityIndicatorView

    @Binding
    public var isAnimating: Bool
    
    public init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style) {
        self._isAnimating = isAnimating
        self.style = style
    }
    
    public let style: UIActivityIndicatorView.Style
    
    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
