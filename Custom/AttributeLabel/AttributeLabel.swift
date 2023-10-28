//
//  AttributeLabel.swift
//  Custom
//
//  Created by my on 2023/8/14.
//

import CoreText
import UIKit

public final class CustomViewAttachment {
    public enum CustomAttachmentAlignment {
        case top
        case center
        case bottom
    }
    
    public let font: UIFont
    public let alignment: CustomAttachmentAlignment
    public let view: UIView
    public let bounds: CGRect
    public let willDisplayView: (UIView) -> Void
    public init(view: UIView,
                bounds: CGRect,
                alignToFont: UIFont,
                alignment: CustomAttachmentAlignment = .bottom,
                willDisplayView: @escaping (UIView) -> Void = { _ in })
    {
        self.view = view
        self.bounds = bounds
        self.willDisplayView = willDisplayView
        self.width = bounds.width + bounds.origin.x
        self.alignment = alignment
        self.font = alignToFont
        let height = bounds.height + bounds.origin.y
        switch alignment {
        case .top:
            ascent = alignToFont.ascender
            descent = height - ascent
            if descent < 0 {
                ascent = height
                descent = 0
            }
        case .center:
            let fontHeight = alignToFont.ascender - alignToFont.descender
            let yOffset = alignToFont.ascender - fontHeight * 0.5
            ascent = height * 0.5 + yOffset
            descent = height - ascent
            if descent < 0 {
                ascent = height
                descent = 0
            }
        case .bottom:
            ascent = height + alignToFont.descender
            descent = -alignToFont.descender
            if ascent < 0 {
                descent = height
                ascent = 0
            }
        }

    }
    
    var ascent: CGFloat
    
    var descent: CGFloat
    
    var width: CGFloat
    
    func pointYWithOrigin(_ origin: CGPoint, lineHeight: CGFloat) -> CGPoint {
        let height = bounds.height + bounds.origin.y
        let fontHeight = font.ascender - font.descender
        let x = origin.x + bounds.origin.x
        var y = origin.y
        switch alignment {
        case .top:  y = y - fontHeight - font.descender
        case .center: y = y - height * 0.5 + font.descender
        case .bottom: y = y - lineHeight - font.descender
        }
        return CGPoint(x: x, y: y + bounds.origin.y)
    }
}

public extension NSAttributedString.Key {
    static let customViewAttribute: NSAttributedString.Key = .init("com.bf.attribute.string.customView.key")
}

fileprivate func deallocCallback(_ pointer: UnsafeMutableRawPointer) {
    // takeRetainedValue 会释放掉pointer
    let delegate = Unmanaged<CustomAttachmentDelegate>.fromOpaque(pointer).takeRetainedValue()
//    var delegate: CustomAttachmentDelegate? = Unmanaged<CustomAttachmentDelegate>.fromOpaque(pointer).takeRetainedValue()
//    delegate = nil
}

fileprivate func ascentCallback(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    // takeUnretainedValue 不会释放掉pointer
    let delegate = Unmanaged<CustomAttachmentDelegate>.fromOpaque(pointer).takeUnretainedValue()
    return delegate.ascent
}

fileprivate func decentCallback(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    let delegate = Unmanaged<CustomAttachmentDelegate>.fromOpaque(pointer).takeUnretainedValue()
    return delegate.descent
}

fileprivate func widthCallback(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    let delegate = Unmanaged<CustomAttachmentDelegate>.fromOpaque(pointer).takeUnretainedValue()
    return delegate.width
}

fileprivate final class CustomAttachmentDelegate {
    let ascent: CGFloat
    let descent: CGFloat
    let width: CGFloat
    
    init(ascent: CGFloat, descent: CGFloat, width: CGFloat) {
        self.ascent = ascent
        self.descent = descent
        self.width = width
    }
    
    var runDelegate: CTRunDelegate? {
        let pointer = Unmanaged.passRetained(self).toOpaque()
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion,
                                               dealloc: deallocCallback,
                                               getAscent: ascentCallback,
                                               getDescent: decentCallback,
                                               getWidth: widthCallback)
        return CTRunDelegateCreate(&callbacks, pointer)
    }
    
    deinit {
        print("\(self) deinit")
    }
}

public extension NSAttributedString {

    static func customViewAttachmentString(_ customView: UIView,
                                           bounds: CGRect,
                                           alignToFont: UIFont,
                                           alignment: CustomViewAttachment.CustomAttachmentAlignment = .bottom,
                                           willDisplayView: @escaping (UIView) -> Void = { _ in }) -> NSAttributedString
    {
        let attributeString = NSMutableAttributedString(string: "\u{FFFC}")
        let customViewAttachment = CustomViewAttachment(view: customView,
                                                        bounds: bounds,
                                                        alignToFont: alignToFont,
                                                        alignment: alignment,
                                                        willDisplayView: willDisplayView)
        
        attributeString.addAttribute(.customViewAttribute,
                                     value: customViewAttachment,
                                     range: NSRange(location: 0, length: attributeString.length))
        
        let delegate = CustomAttachmentDelegate(ascent: customViewAttachment.ascent,
                                                descent: customViewAttachment.descent,
                                                width: customViewAttachment.width)
        
        if let runDelegate = delegate.runDelegate {
            let runDelegateKey = NSAttributedString.Key(kCTRunDelegateAttributeName as String)
            attributeString.addAttribute(runDelegateKey,
                                         value: runDelegate,
                                         range: NSRange(location: 0, length: attributeString.length))
        }
        return attributeString
    }
}

public final class AttributeAsyncTextLayer: CALayer {

    public let queue: DispatchQueue = DispatchQueue(label: "com.ge.attribute.text.layer.queue")
    
    public var attributeText: NSAttributedString?
    
    public var isRTL: Bool = false

    override public func display() {
        if let attributeText {
            drawAttributeText(attributeText)
        }
    }
    
    public func perferredSizeFits(_ size: CGSize) -> CGSize {
        guard let attributeText, size != .zero else { return .zero }
        let frameSetter = CTFramesetterCreateWithAttributedString(attributeText)
        var fitRange = CFRangeMake(0, 0)
        let retSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, size, &fitRange)
        return retSize
    }

    private func drawAttributeText(_ attributeText: NSAttributedString) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        // flip context
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity
        // draw
        drawAttributeText(attributeText as CFAttributedString, in: context, bounds: bounds)
        let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
//        DispatchQueue.main.async {
        // 刷新的时候可能会闪烁
        self.contents = cgImage
//        }
    }

    private func drawAttributeText(_ attributeText: CFAttributedString, in context: CGContext, bounds: CGRect) {
        let path = CGMutablePath()
        path.addRect(bounds)
        // frame
        let frameSetter = CTFramesetterCreateWithAttributedString(attributeText)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        // line
        let lines = CTFrameGetLines(frame)
        let lineCount = CFArrayGetCount(lines)
        var lineOrigins: [CGPoint] = Array(repeating: .zero, count: lineCount)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, lineCount), &lineOrigins)
        for index in 0 ..< lineCount {
            if let linePointer = CFArrayGetValueAtIndex(lines, index) {
                let line = Unmanaged<CTLine>.fromOpaque(linePointer).takeUnretainedValue()
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
                handleCustomAttachment(line,
                                       lineOrigin: CGPoint(x: lineOrigins[index].x, y: bounds.height - lineOrigins[index].y),
                                       lineHeight: ascent + descent)
            }
        }
        // draw text
        CTFrameDraw(frame, context)
    }

    private func handleCustomAttachment(_ line: CTLine, lineOrigin: CGPoint, lineHeight: CGFloat) {
        let runs = CTLineGetGlyphRuns(line)
        let runCount = CFArrayGetCount(runs)
        if runCount == 0 { return }
        for runIndex in 0 ..< runCount {
            guard let runPointer = CFArrayGetValueAtIndex(runs, runIndex) else { continue }
            let run = Unmanaged<CTRun>.fromOpaque(runPointer).takeUnretainedValue()
            if let attributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any],
               let customAttachment = attributes[.customViewAttribute] as? CustomViewAttachment
            {
                var x = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                if isRTL {
                    x -= customAttachment.width
                }
                let poisition = customAttachment.pointYWithOrigin(CGPoint(x: x, y: lineOrigin.y), lineHeight: lineHeight)
                handleCustomViewAttachment(customAttachment, position: poisition)
            }
        }
    }

    private func handleCustomViewAttachment(_ attachment: CustomViewAttachment, position: CGPoint) {
        let frame = CGRect(origin: position, size: attachment.bounds.size)
        if let attributeLabel = delegate as? AttributeLabel {
            DispatchQueue.main.async {
                attachment.willDisplayView(attachment.view)
                attributeLabel.addCustomViewWithFrame(attachment.view, frame: frame)
            }
        }
    }
}

public final class AttributeLabel: UIView {
    public override class var layerClass: AnyClass {
        AttributeAsyncTextLayer.self
    }
    
    private var textLayer: AttributeAsyncTextLayer {
        layer as! AttributeAsyncTextLayer
    }
    
    public var attributeText: NSAttributedString? {
        didSet {
            textLayer.attributeText = attributeText
            textLayer.setNeedsDisplay()
            textLayer.isRTL = semanticContentAttribute == .forceRightToLeft
            subviews.forEach({ $0.removeFromSuperview() })
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var frame: CGRect {
        didSet {
            textLayer.setNeedsDisplay()
        }
    }
    
    public var preferredMaxLayoutWidth: CGFloat = 0
    
    func addCustomViewWithFrame(_ view: UIView, frame: CGRect) {
        view.frame = frame
        addSubview(view)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        textLayer.perferredSizeFits(size)
    }
    
    public override var intrinsicContentSize: CGSize {
        textLayer.perferredSizeFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat(MAXFLOAT)))
    }
}
