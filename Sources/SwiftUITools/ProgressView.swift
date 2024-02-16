//
//  File.swift
//
//
//  Created by mayong on 2023/12/13.
//

import SwiftUI

public struct ProgressView<Content: View>: View {
    @Binding
    public var progress: CGFloat
    public let content: () -> Content
    public let changed: (CGFloat) -> Void
    public let interactiveEnabled: Bool

    public init(progress: Binding<CGFloat>,
                interactiveEnabled: Bool = true,
                changed: @escaping (CGFloat) -> Void = { _ in },
                content: @escaping () -> Content = { Rectangle() })
    {
        self._progress = progress
        self.interactiveEnabled = interactiveEnabled
        self.content = content
        self.changed = changed
    }

    public var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                content()
                    .frame(width: proxy.size.width * progress)
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: proxy.size.width * (1 - progress), height: proxy.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if interactiveEnabled {
                            setProgress(value.location.x / proxy.size.width)
                            changed(progress)
                        }
                    }
            )
        }
    }
    
    private func setProgress(_ progress: CGFloat) {
        self.progress = max(0, min(1, progress))
    }
}
