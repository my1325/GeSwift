//
//  ScanView.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2019/5/15.
//  Copyright © 2019 my. All rights reserved.
//

import AVFoundation
import UIKit

/// 扫一扫界面
public final class ScanView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// 是否开启手势缩放，默认为true
    public var isScaleEnable: Bool = true
    
    public var supportMinZoomFactor: CGFloat {
        get {
            return minZoomFactor
        } set {
            minZoomFactor = newValue
        }
    }
    
    public var supportMaxZoomFactor: CGFloat {
        get {
            return maxZoomFactor
        } set {
            maxZoomFactor = newValue
        }
    }
    
    /// rate越大，动画越慢, 默认为3
    public var zoomRate: CGFloat = 3
    
    /// 当前的缩放系数
    private var currentZoomFactor: CGFloat = 1.0
    
    /// 设备支持最小的缩放系数
    private lazy var minZoomFactor: CGFloat = {
        var minZoomFactor: CGFloat = 1.0
        if #available(iOS 11.0, *) {
            minZoomFactor = self.device.minAvailableVideoZoomFactor
        }
        return minZoomFactor
    }()
    
    /// 设备最大的缩放系数
    private lazy var maxZoomFactor: CGFloat = {
        var maxZoomFactor = self.device.activeFormat.videoMaxZoomFactor
        if #available(iOS 11.0, *) {
            maxZoomFactor = self.device.maxAvailableVideoZoomFactor
        }
        if maxZoomFactor > 6.0 {
            maxZoomFactor = 6.0
        }
        return maxZoomFactor
    }()
    
    private lazy var scaleGesture: UIPinchGestureRecognizer = {
        $0.addTarget(self, action: #selector(handlePinchGesture(_:)))
        $0.isEnabled = self.isScaleEnable
        self.addGestureRecognizer($0)
        return $0
    }(UIPinchGestureRecognizer())
    
    /// 是否开启双击缩放, 默认为true
    public var isDoubleTapScaleEnable: Bool = true
    
    private lazy var doubleGesture: UITapGestureRecognizer = {
        $0.addTarget(self, action: #selector(handleDoubleTapGesture(_:)))
        $0.numberOfTapsRequired = 2
        $0.isEnabled = self.isDoubleTapScaleEnable
        self.addGestureRecognizer($0)
        return $0
    }(UITapGestureRecognizer())
    
    public typealias ScanResult = (String?) -> Void
    public var scanResult: ScanResult?
    public lazy var rectOfInterest: CGRect = self.bounds
//    #if !targetEnvironment(simulator)
    private(set) var device = AVCaptureDevice.default(for: .video)!
    private(set) var input: AVCaptureDeviceInput?
    private(set) var output: AVCaptureMetadataOutput?
    private(set) var session: AVCaptureSession?
    private(set) var preview: AVCaptureVideoPreviewLayer?

    private var isConfiged: Bool = false
    
    // 设置遮罩层
    private func setCropRect() {
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(rectOfInterest)
        path.addRect(bounds)
        
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.path = path
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0.6
        layer.setNeedsLayout()
        
        self.layer.addSublayer(layer)
    }
    
    private func configDevice() {
        do {
            try! input = AVCaptureDeviceInput(device: device)
        }
        output = AVCaptureMetadataOutput()
        output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSession.Preset.high
        
        if session!.canAddInput(input!) {
            session!.addInput(input!)
        }
        
        if session!.canAddOutput(output!) {
            session!.addOutput(output!)
        }
        
        output?.metadataObjectTypes = [.qr, .upce, .code39, .code39Mod43, .code93, .pdf417, .ean13, .ean8, .code128]
        
        // CGRectMake(y/deviceHeight, x/deviceWidth, height/deviceHeight, width/deviceWidth);
//        fileprivate let SCANRECT: CGRect = CGRect(x: LEFT, y: TOP, width: 220, height: 220)
//        CGRect(x: TOP / kScreenH, y: LEFT / kScreenW, width: 220 / kScreenH, height: 220 / kScreenW)

        let top = rectOfInterest.origin.y
        let left = rectOfInterest.origin.x
        let width = rectOfInterest.size.width
        let height = rectOfInterest.size.height
        
        let iphone_width = UIScreen.main.bounds.size.width
        let iphone_height = UIScreen.main.bounds.size.height
        
        output?.rectOfInterest = CGRect(x: top / iphone_height, y: left / iphone_width, width: height / iphone_height, height: width / iphone_width)
        
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview?.frame = layer.bounds
        layer.insertSublayer(preview!, at: 0)

        doubleGesture.isEnabled = isDoubleTapScaleEnable
        scaleGesture.isEnabled = isScaleEnable
        isConfiged = true
    }
//    #endif
}

//#if !targetEnvironment(simulator)
public extension ScanView {
    func startScan() {
        if !isConfiged {
            setCropRect()
            configDevice()
        }
        session?.startRunning()
    }
    
    func stopScan() {
        session?.stopRunning()
    }
}

extension ScanView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var text: String?
        if metadataObjects.count > 0 {
            session?.stopRunning()
            text = (metadataObjects[0] as? AVMetadataMachineReadableCodeObject)?.stringValue
        }
        scanResult?(text)
    }
}

extension ScanView: UIGestureRecognizerDelegate {
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            currentZoomFactor = device.videoZoomFactor
        case .changed:
            let factor = currentZoomFactor * gesture.scale
            print("factor = \(factor) currentZoomFactor = \(currentZoomFactor) scale = \(gesture.scale)")
            if factor >= minZoomFactor, factor <= maxZoomFactor {
                do {
                    try device.lockForConfiguration()
                    device.ramp(toVideoZoomFactor: factor, withRate: Float(zoomRate))
                    device.unlockForConfiguration()
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                }
            }
        default:
            gesture.scale = 1.0
        }
    }
    
    @objc func handleDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        let zoomFactor = device.videoZoomFactor > minZoomFactor * 1.5 ? minZoomFactor : maxZoomFactor
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: zoomFactor, withRate: Float(zoomRate))
            device.unlockForConfiguration()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}
//#endif
