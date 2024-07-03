//
//  WebView.swift
//  SwiftUIAbout
//
//  Created by mayong on 2023/12/11.
//

import SwiftUI
import UIKit
import WebKit

public typealias StringBlock = (String) -> Void
public typealias BoolBlock = (Bool) -> Void
public typealias WebLoadingStatusBlock = (LoadingStaus) -> Void
public typealias DoubleBlock = (Double) -> Void
public typealias DecidePolicyForAction = (WKNavigationAction) -> WKNavigationActionPolicy

/// webview 加载状态
public enum LoadingStaus {
    case Wait
    case Finish
    case Faile
}

public class WebViewManager {
    public let webView: WKWebView
    
    public convenience init() {
        let pres = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            pres.allowsContentJavaScript = true
        }
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = pres
        self.init(configuration: config)
    }
    
    public convenience init(configuration: WKWebViewConfiguration) {
        self.init(webView: WKWebView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1), configuration: configuration))
    }
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    public func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    public func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}

public struct WebView: UIViewRepresentable {
    public let manager: WebViewManager
    
    private var listenTitle: StringBlock?
    private var listenCanGoBack: BoolBlock?
    private var listenLoadingStatus: WebLoadingStatusBlock?
    private var listenEstimatedProgress: DoubleBlock?
    private var decidePolicyForAction: DecidePolicyForAction?
    
    public init(
        _ manager: WebViewManager,
        listenTitle: StringBlock? = nil,
        listenCanGoBack: BoolBlock? = nil,
        listenLoadingStatus: WebLoadingStatusBlock? = nil,
        listenEstimatedProgress: DoubleBlock? = nil,
        decidePolicyForAction: DecidePolicyForAction? = nil
    ) {
        self.manager = manager
        
        self.listenTitle = listenTitle
        self.listenCanGoBack = listenCanGoBack
        self.listenLoadingStatus = listenLoadingStatus
        self.listenEstimatedProgress = listenEstimatedProgress
        self.decidePolicyForAction = decidePolicyForAction
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        manager.webView.navigationDelegate = context.coordinator
        return manager.webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            
            if self.parent.listenTitle != nil {
                self.parent.manager.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            }
            if self.parent.listenCanGoBack != nil {
                self.parent.manager.webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
            }
            if self.parent.listenEstimatedProgress != nil {
                self.parent.manager.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            }
        }
        
        deinit {
            if self.parent.listenTitle != nil {
                self.parent.manager.webView.removeObserver(self, forKeyPath: "title")
            }
            if self.parent.listenCanGoBack != nil {
                self.parent.manager.webView.removeObserver(self, forKeyPath: "canGoBack")
            }
            if self.parent.listenEstimatedProgress != nil {
                self.parent.manager.webView.removeObserver(self, forKeyPath: "estimatedProgress")
            }
        }
        
        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.listenLoadingStatus?(.Wait)
        }
    
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.listenLoadingStatus?(.Finish)
        }
    
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.listenLoadingStatus?(.Faile)
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let policy = parent.decidePolicyForAction?(navigationAction) {
                decisionHandler(policy)
            } else {
                decisionHandler(.allow)
            }
        }
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "title" {
                if let callback = parent.listenTitle {
                    callback(parent.manager.webView.title ?? "")
                }
            }
            if keyPath == "canGoBack" {
                if let callback = parent.listenCanGoBack {
                    callback(parent.manager.webView.canGoBack)
                }
            }
            if keyPath == "estimatedProgress" {
                if let callback = parent.listenEstimatedProgress {
                    callback(parent.manager.webView.estimatedProgress)
                }
            }
        }
    }
}

// #endIf
