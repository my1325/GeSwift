//
//  JKN_ImagePickerView.swift
//  JokyNote
//
//  Created by mayong on 2023/11/27.
//

import AVFoundation
import Photos
import SwiftUI
import UIKit

public struct ImagePickerView: UIViewControllerRepresentable {
    public enum SourceType {
        case photoLibrary
        case camera
        
        public var imagePickerSourceType: UIImagePickerController.SourceType {
            switch self {
            case .photoLibrary: return .photoLibrary
            case .camera: return .camera
            }
        }
    }
    
    public typealias DidSelectImageAction = (UIImage) -> Void
    
    public let allowsEditing: Bool

    public let sourceType: SourceType
    
    public let didSelectImageAction: DidSelectImageAction
    
    public init(allowsEditing: Bool = true,
                sourceType: SourceType = .photoLibrary,
                didSelectImageAction: @escaping DidSelectImageAction)
    {
        self.allowsEditing = allowsEditing
        self.sourceType = sourceType
        self.didSelectImageAction = didSelectImageAction
    }
    
    @Environment(\.presentationMode)
    var presentationMode // 获取环境变量
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        picker.sourceType = sourceType.imagePickerSourceType
        return picker
    }
  
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView // 存放ImagePicker的引用
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if picker.allowsEditing, let uiImage = info[.editedImage] as? UIImage {
                parent.didSelectImageAction(uiImage)
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.didSelectImageAction(uiImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

public extension ImagePickerView.SourceType {
    var isAuthorized: Bool {
        switch self {
        case .photoLibrary:
            return authorizationForPhotoLibrary() == .authorized
        case .camera:
            return authorizationForCamera() == .authorized
        }
    }
    
    var isNotDetermined: Bool {
        switch self {
        case .photoLibrary:
            return authorizationForPhotoLibrary() == .notDetermined
        case .camera:
            return authorizationForCamera() == .notDetermined
        }
    }
    
    typealias AuthenticationCheckAction = () -> Void
    func checkAuthorization(_ denied: @escaping AuthenticationCheckAction, authorized: @escaping AuthenticationCheckAction) {
        switch self {
        case .camera:
            requestAuthorizationForCamera(denied, authorized: authorized)
        case .photoLibrary:
            requestAuthorizationForPhotoLibrary(denied, authorized: authorized)
        }
    }
    
    private func authorizationForPhotoLibrary() -> PHAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }
    
    private func authorizationForCamera() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    private func requestAuthorizationForPhotoLibrary(_ denied: @escaping AuthenticationCheckAction, authorized: @escaping AuthenticationCheckAction) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: {
                switch $0 {
                case .authorized:
                    DispatchQueue.main.async {
                        authorized()
                    }
                default:
                    DispatchQueue.main.async {
                        denied()
                    }
                }
            })
        } else {
            PHPhotoLibrary.requestAuthorization {
                switch $0 {
                case .authorized:
                    DispatchQueue.main.async {
                        authorized()
                    }
                default:
                    DispatchQueue.main.async {
                        denied()
                    }
                }
            }
        }
    }
    
    private func requestAuthorizationForCamera(_ denied: @escaping AuthenticationCheckAction, authorized: @escaping AuthenticationCheckAction) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    authorized()
                }
            } else {
                DispatchQueue.main.async {
                    denied()
                }
            }
        }
    }
}
