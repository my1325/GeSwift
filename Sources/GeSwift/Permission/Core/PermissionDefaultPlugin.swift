//
//  PermissionDefaultPlugin.swift
//  GeSwift
//
//  Created by my on 2023/1/13.
//  Copyright © 2023 my. All rights reserved.
//

import AppTrackingTransparency
import AVFoundation
import Contacts
import CoreLocation
import Photos
import UIKit
import EventKit

public final class PermissionDefaultPlugin: NSObject, PermissionPluginCompatible {
    let locationManager = CLLocationManager()
    let eventStore = EKEventStore()
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func permissionStatus(_ permissionType: PermissionType) -> PermissionStatus {
        switch permissionType {
        case .locationWhenInUse, .locationAlways: return locationPermission()
        case .photoLibrary: return photoPermission()
        case .contact: return contactsPersmission()
        case .camera: return cameraPermission()
        case .microphone: return microphonePermission()
        /// will block current thread, not use in main thread
        case .notification: return notificationPermission()
        case .appTrack: return appTrackingPermission()
        case .calendarsForEvent: return calendarForEventPermission()
        case .calendarsForReminder: return calendarForReminderPermission()
        default: return .unknown
        }
    }
    
    public func requestPermissionStatus(_ permissionType: PermissionType, redirectToSettingsIfDeined redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch permissionType {
        case .locationWhenInUse, .locationAlways: requestLocation(permissionType, redirectToSettings, completion: completion)
        case .photoLibrary: requestPhoto(redirectToSettings, completion: completion)
        case .contact: requestContacts(redirectToSettings, completion: completion)
        case .camera: requestCamera(redirectToSettings, completion: completion)
        case .microphone: requestMicrophone(redirectToSettings, completion: completion)
        case .notification: requestNotification(redirectToSettings, completion: completion)
        case .appTrack: requestAppTracking(redirectToSettings, completion: completion)
        case .calendarsForReminder: requestCalendarForReminder(redirectToSettings, completion: completion)
        case .calendarsForEvent: requestCalendarForEvent(redirectToSettings, completion: completion)
        default: completion(.unknown)
        }
    }
    
    private var locationPermissionCallback: ((PermissionStatus) -> Void)?
    
    private func _redirectToSettings(_ description: String?) {
        let alertController = UIAlertController(title: nil, message: description, preferredStyle: .alert)
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .destructive))
        alertController.addAction(.init(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { _ in
            if let settingURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingURL)
            {
                UIApplication.shared.open(settingURL)
            }
        }))
        let window = UIApplication.shared.delegate?.window
        window??.rootViewController?.present(alertController, animated: true)
    }
}

extension PermissionDefaultPlugin: CLLocationManagerDelegate {
    public func locationPermission() -> PermissionStatus {
        let status: PermissionStatus
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .restricted, .denied: status = .denied
            case .authorized, .authorizedAlways, .authorizedWhenInUse: status = .authorized
            case .notDetermined: status = .notDetermined
            @unknown default: status = .unknown
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied: status = .denied
            case .authorized, .authorizedAlways, .authorizedWhenInUse: status = .authorized
            case .notDetermined: status = .notDetermined
            @unknown default: status = .unknown
            }
        }
        return status
    }
    
    public func requestLocation(_ permissionType: PermissionType, _ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch locationPermission() {
        case .authorized: completion(.authorized)
        case .unknown: completion(.unknown)
        case .notDetermined:
            if permissionType.contains(.locationWhenInUse) {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if permissionType.contains(.locationAlways) {
                locationManager.requestAlwaysAuthorization()
            }
            
            if !permissionType.contains(.locationAlways), !permissionType.contains(.locationWhenInUse) {
                completion(.unknown)
            }
            
            locationPermissionCallback = completion
        case .denied:
            if redirectToSettings {
                let info = Bundle.main.infoDictionary
                var description = info?["NSLocationWhenInUseUsageDescription"] as? String
                if description == nil {
                    description = info?["NSLocationAlwaysAndWhenInUseUsageDescription"] as? String
                }
                _redirectToSettings(description)
            }
            completion(.denied)
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermissionCallback?(locationPermission())
        locationPermissionCallback = nil
    }
}

public extension PermissionDefaultPlugin {
    func photoPermission() -> PermissionStatus {
        let status: PermissionStatus
        if #available(iOS 14.0, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .limited, .authorized: status = .authorized
            case .notDetermined: status = .notDetermined
            case .denied, .restricted: status = .denied
            @unknown default: status = .unknown
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized: status = .authorized
            case .notDetermined: status = .notDetermined
            case .denied, .restricted: status = .denied
            default: status = .unknown
            }
        }
        return status
    }
    
    func requestPhoto(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch photoPermission() {
        case .authorized: completion(.authorized)
        case .unknown: completion(.unknown)
        case .notDetermined:
            if #available(iOS 14.0, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in
                    DispatchQueue.main.async {
                        completion(self.photoPermission())
                    }
                })
            } else {
                PHPhotoLibrary.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        completion(self.photoPermission())
                    }
                }
            }
        case .denied:
            if redirectToSettings {
                let info = Bundle.main.infoDictionary
                var description = info?["NSPhotoLibraryUsageDescription"] as? String
                if description == nil {
                    description = info?["NSPhotoLibraryAddUsageDescription"] as? String
                }
                _redirectToSettings(description)
            }
            completion(.denied)
        }
    }
}

public extension PermissionDefaultPlugin {
    func contactsPersmission() -> PermissionStatus {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .denied, .restricted: return .denied
        @unknown default: return .unknown
        }
    }
    
    func requestContacts(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch contactsPersmission() {
        case .unknown: completion(.unknown)
        case .authorized: completion(.authorized)
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts, completionHandler: { _, _ in
                DispatchQueue.main.async {
                    completion(self.contactsPersmission())
                }
            })
        case .denied:
            if redirectToSettings {
                let info = Bundle.main.infoDictionary
                let description = info?["NSContactsUsageDescription"] as? String
                _redirectToSettings(description)
            }
            completion(.denied)
        }
    }
}

public extension PermissionDefaultPlugin {
    func cameraPermission() -> PermissionStatus {
        AVDeviceCapturePermission(.video)
    }
    
    func microphonePermission() -> PermissionStatus {
        AVDeviceCapturePermission(.audio)
    }
    
    func AVDeviceCapturePermission(_ type: AVMediaType) -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: type) {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        @unknown default: return .unknown
        }
    }
    
    func requestCamera(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        requestAVDevice(.video, redirectToSettings: redirectToSettings, completion: completion)
    }
    
    func requestMicrophone(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        requestAVDevice(.audio, redirectToSettings: redirectToSettings, completion: completion)
    }
    
    func requestAVDevice(_ type: AVMediaType, redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch AVDeviceCapturePermission(type) {
        case .authorized: completion(.authorized)
        case .unknown: completion(.unknown)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: type, completionHandler: { _ in
                DispatchQueue.main.async {
                    completion(self.AVDeviceCapturePermission(type))
                }
            })
        case .denied:
            if redirectToSettings {
                let info = Bundle.main.infoDictionary
                let description: String?
                switch type {
                case .audio: description = info?["NSMicrophoneUsageDescription"] as? String
                case .video: description = info?["NSCameraUsageDescription"] as? String
                default: description = ""
                }
                _redirectToSettings(description)
            }
            completion(.denied)
        }
    }
}

public extension PermissionDefaultPlugin {
    func appTrackingPermission() -> PermissionStatus {
        if #available(iOS 14.0, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .restricted, .denied: return .denied
            case .authorized: return .authorized
            case .notDetermined: return .notDetermined
            @unknown default: return .unknown
            }
        }
        return .unknown
    }
    
    func requestAppTracking(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        if #available(iOS 14, *) {
            switch appTrackingPermission() {
            case .unknown: completion(.unknown)
            case .authorized: completion(.authorized)
            case .notDetermined:
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                    DispatchQueue.main.async {
                        completion(self.appTrackingPermission())
                    }
                })
            case .denied:
                if redirectToSettings {
                    let info = Bundle.main.infoDictionary
                    let description = info?["NSUserTrackingUsageDescription"] as? String
                    _redirectToSettings(description)
                }
                completion(.denied)
            }
        } else {
            completion(.unknown)
        }
    }
}

public extension PermissionDefaultPlugin {
    func calendarForEventPermission() -> PermissionStatus {
        calendarPermission(.event)
    }
    
    func calendarForReminderPermission() -> PermissionStatus {
        calendarPermission(.reminder)
    }
    
    func calendarPermission(_ type: EKEntityType) -> PermissionStatus {
        switch EKEventStore.authorizationStatus(for: type) {
        case .restricted, .denied: return .denied
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        @unknown default: return .unknown
        }
    }
    
    func requestCalendarForEvent(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        requestCalendar(.event, redirectToSettings: redirectToSettings, completion: completion)
    }
    
    func requestCalendarForReminder(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        requestCalendar(.reminder, redirectToSettings: redirectToSettings, completion: completion)
    }
    
    func requestCalendar(_ type: EKEntityType, redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        switch calendarPermission(type) {
        case .unknown: completion(.unknown)
        case .authorized: completion(.authorized)
        case .notDetermined:
            eventStore.requestAccess(to: type, completion: { _, _ in
                DispatchQueue.main.async {
                    completion(self.calendarPermission(type))
                }
            })
        case .denied:
            if redirectToSettings {
                let info = Bundle.main.infoDictionary
                let description = info?["NSCalendarsUsageDescription"] as? String
                _redirectToSettings(description)
            }
            completion(.denied)
        }
    }
}

public extension PermissionDefaultPlugin {
    /// using in async thread
    func notificationPermission() -> PermissionStatus {
        let singal = DispatchSemaphore(value: 0)
        var status: PermissionStatus = .unknown
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .denied: status = .denied
            case .notDetermined: status = .notDetermined
            case .provisional, .authorized: status = .authorized
            default: status = .unknown
            }
            
            if #available(iOS 14.0, *), settings.authorizationStatus == .ephemeral {
                status = .authorized
            }
        })
        singal.wait()
        return status
    }
    
    func requestNotification(_ redirectToSettings: Bool, completion: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var status: PermissionStatus = .unknown
            switch settings.authorizationStatus {
            case .denied: status = .denied
            case .notDetermined: status = .notDetermined
            case .provisional, .authorized: status = .authorized
            default: status = .unknown
            }
            
            if #available(iOS 14.0, *), settings.authorizationStatus == .ephemeral {
                status = .authorized
            }
            
            switch status {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(completionHandler: { authorized, _ in
                    DispatchQueue.main.async {
                        if authorized {
                            completion(.authorized)
                        } else {
                            completion(.denied)
                        }
                    }
                })
            default:
                DispatchQueue.main.async {
                    completion(status)
                }
            }
            
            if status == .denied, redirectToSettings {
                DispatchQueue.main.async {
                    self._redirectToSettings("")
                }
            }
        }
    }
}
