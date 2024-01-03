//
//  SnapShotView.swift
//  ShineDay
//
//  Created by mayong on 2023/12/21.
//

import SwiftUI

extension UIView {
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }

    func takeScreenshot(afterScreenUpdates: Bool) -> UIImage {
        if !self.responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return self.takeScreenshot()
        }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }
}

extension View {
    func takeScreenshot(frame: CGRect, afterScreenUpdates: Bool) -> UIImage {
        let hosting = UIHostingController(rootView: self)
        hosting.overrideUserInterfaceStyle = UIApplication.shared.currentUIWindow()?.overrideUserInterfaceStyle ?? .unspecified
        hosting.view.frame = frame
        return hosting.view.takeScreenshot(afterScreenUpdates: afterScreenUpdates)
    }
}

extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
    }
}

public enum ScreenshotableViewStyle {
    /// 截图中的样式
    /// style in screenshot image
    case inScreenshot
    /// 正常展现的样式
    /// style in normally displayed View
    case inView
}

public struct ScreenshotableView<Content: View>: View {
    @Binding var shotting: Bool
    var completed: (UIImage) -> Void
    let content: (_ style: ScreenshotableViewStyle) -> Content

    public init(shotting: Binding<Bool>, completed: @escaping (UIImage) -> Void, @ViewBuilder content: @escaping (_ style: ScreenshotableViewStyle) -> Content) {
        self._shotting = shotting
        self.completed = completed
        self.content = content
    }

    public var body: some View {
        func internalView(proxy: GeometryProxy) -> some View {
            if self.shotting {
                let frame = proxy.frame(in: .global)
                DispatchQueue.main.async {
                    self.shotting = false
                    // 截图时用 inSnapshot 的样式
                    // Use content with '.inScreenshot' style while taking a screenshot
                    let screenshot = self.content(.inScreenshot).takeScreenshot(frame: frame, afterScreenUpdates: true)
                    self.completed(screenshot)
                }
            }
            return Color.clear
        }

        // 展示 inView style 的内容
        // Display content with 'inView' style
        return self.content(.inView).background(GeometryReader(content: internalView(proxy:)))
    }
}
