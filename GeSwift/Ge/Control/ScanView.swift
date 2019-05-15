//
//  ScanView.swift
//  GeSwift
//
//  Created by weipinzhiyuan on 2019/5/15.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import AVFoundation

/// 扫一扫界面
public final class ScanView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public typealias ScanResult = (String?) -> Void
    public var scanResult: ScanResult?
    public lazy var rectOfInterest: CGRect = self.bounds
    
    private(set) var device: AVCaptureDevice = AVCaptureDevice.default(for: .video)!
    private(set) var input: AVCaptureDeviceInput?
    private(set) var output: AVCaptureMetadataOutput?
    private(set) var session: AVCaptureSession?
    private(set) var preview: AVCaptureVideoPreviewLayer?

    private var isConfiged: Bool = false
    
    //设置遮罩层
    private func setCropRect() {
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(self.rectOfInterest)
        path.addRect(self.bounds)
        
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
        
        output?.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,
                                       AVMetadataObject.ObjectType.ean13,
                                       AVMetadataObject.ObjectType.ean8,
                                       AVMetadataObject.ObjectType.code128]
        
        //CGRectMake(y/deviceHeight, x/deviceWidth, height/deviceHeight, width/deviceWidth);
//        fileprivate let SCANRECT: CGRect = CGRect(x: LEFT, y: TOP, width: 220, height: 220)
//        CGRect(x: TOP / kScreenH, y: LEFT / kScreenW, width: 220 / kScreenH, height: 220 / kScreenW)

        let top = self.rectOfInterest.origin.y
        let left = self.rectOfInterest.origin.x
        let width = self.rectOfInterest.size.width
        let height = self.rectOfInterest.size.height
        
        let iphone_width = UIScreen.main.bounds.size.width
        let iphone_height = UIScreen.main.bounds.size.height
        
        output?.rectOfInterest = CGRect(x: top / iphone_height, y: left / iphone_width, width: height / iphone_height, height: width / iphone_width)
        
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview?.frame = self.layer.bounds
        self.layer.insertSublayer(preview!, at: 0)
        
        self.isConfiged = true
    }
}

extension ScanView {
    
    public func startScan() {
        if !self.isConfiged {
            self.setCropRect()
            self.configDevice()
        }
        self.session?.startRunning()
    }
    
    public func stopScan() {
        self.session?.stopRunning()
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
