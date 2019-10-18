//
//  View.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/18.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

public typealias Rect = View.Rect
public typealias Size = View.Rect.Size
public typealias Origin = View.Rect.Origin

open class View {
    
    internal var isNeededLayout: Bool = true
    
    internal var lastLayoutView: UIView?

    internal var contentUIView: UIView = {
        $0.backgroundColor = UIColor.clear
        return $0
    }(UIView())
    
    @discardableResult
    internal func layoutReturnUIView() -> UIView {
        let uiView = UIView(frame: self.frame.cgRect)
        for view in self.subViews {
            view.lastLayoutView?.removeFromSuperview()
            uiView.addSubview(view.layoutReturnUIView())
        }
        return uiView
    }
    
    var subViews: [View] = []
    
    func addView(_ view: View) {
        subViews.append(view)
    }
    
    func layout() {
        precondition(Thread.isMainThread, "this function must be in main thread")
        if isNeededLayout, self.lastLayoutView == nil {
            self.lastLayoutView = self.layoutReturnUIView()
        }
        self.isNeededLayout = false
    }
        
    public struct Rect {
        
        public struct Size {
            
            var width: Float = 0
            var height: Float = 0
            
            static let zero = Size()
        }
        
        public struct Origin {
            
            var left: Float = 0
            var top: Float = 0
            
            static let zero = Origin()
        }
        
        var left: Float = 0
        var top: Float = 0
        var width: Float = 0
        var height: Float = 0
        
        lazy var size: Size = Size(width: self.width, height: self.height)
        
        lazy var origin: Origin = Origin(left: self.left, top: self.top)

        var cgRect: CGRect {
            return CGRect(x: CGFloat(self.left), y: CGFloat(self.top), width: CGFloat(self.width), height: CGFloat(self.height))
        }
        
        static let zero = Rect()
    }
    
    var frame: Rect = Rect.zero
}
