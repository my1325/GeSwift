import Foundation
import CoreLocation

public enum LocationError: Error {
    case success
    case timeout
    case canceled
    case error(withError: NSError)
    
    var errorDescription: String {
        switch self {
        case .success:
            return "成功"
        case .timeout:
            return "定位超时"
        case .canceled:
            return "定位已取消"
        case .error(let error):
            return error.localizedDescription
        }
    }
}

public final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    public static let shared: LocationManager = LocationManager()

    /// 定位对象请求的队列
    public var locationRequestQueue: DispatchQueue = DispatchQueue(label: "com.ge.location.queue")
    
    /// 定位超时时间
    public var timeoutInterval: TimeInterval = 10
    
    public typealias LocationAuthorization = CLAuthorizationStatus
    /// 定位授权状态
    public var locationAuthorization: LocationAuthorization {
        return CLLocationManager.authorizationStatus()
    }
    
    private lazy var requastAuthorizationLocationManager: CLLocationManager = CLLocationManager()
    /// 请求定位权限
    public func requestLocationAuthorizationWhenInUseIfNeeded() {
        switch self.locationAuthorization {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .notDetermined:
            self.requastAuthorizationLocationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    private var tasks: [Task] = []
    private var timeoutLock: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    fileprivate final class Task: NSObject {

        var completionHandler: LocationTask.LoacationManagerDidUpdateLocations?
        init(delegate: CLLocationManagerDelegate) {
            super.init()
            self.locationManager.delegate = delegate
        }
       
        /// 定位对象
        internal let locationManager = CLLocationManager()
        
        internal var isCanceled: Bool = false
        
        fileprivate func resume() {
            self.locationManager.startUpdatingLocation()
        }
        
        fileprivate func stop() {
            self.isCanceled = true
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    /// 请求定位
    public func requestCurrentLocation(_ completion: LocationTask.LoacationManagerDidUpdateLocations?) -> LocationTask {
            
        let locationTask: LocationTask = LocationTask(loacationManagerDidUpdateLocationsCompletion: completion)
        let task: Task = Task(delegate: self)
        task.completionHandler = { [weak task, weak locationTask] (locations, error) in
            if let index = self.tasks.firstIndex(where: { $0 === task }) {
                self.tasks.remove(at: index)
            }
            locationTask?.executeCompletion(locations, error: LocationError.success)
        }
        self.tasks.append(task)

        let asyncCode = { [unowned self, weak locationTask, weak task] in
            
            task?.resume()
            /// 超时处理
            let result = self.timeoutLock.wait(timeout: DispatchTime.now() + .seconds(Int(self.timeoutInterval)))
            switch result {
            case .timedOut:
                task?.stop()
                if let index = self.tasks.firstIndex(where: { $0 === task }) {
                    self.tasks.remove(at: index)
                }
                locationTask?.executeCompletion([], error: LocationError.timeout)
            case .success: break
            }
        }
        self.locationRequestQueue.async(execute: asyncCode)
        return locationTask
    }
  
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.timeoutLock.signal()
        manager.stopUpdatingLocation()
        if let task = self.tasks.first(where: { $0.locationManager === manager }) {
            task.completionHandler?(locations, LocationError.success)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.timeoutLock.signal()
        manager.stopUpdatingLocation()
        if let task = self.tasks.first(where: { $0.locationManager === manager }) {
            task.completionHandler?([], LocationError.error(withError: error as NSError))
        }
    }
}

public final class LocationTask {
    
    public typealias LoacationManagerDidUpdateLocations = ([CLLocation], LocationError) -> Void
    public var locations: [CLLocation] = []
    fileprivate let loacationManagerDidUpdateLocationsCompletion: LoacationManagerDidUpdateLocations?
    fileprivate init(loacationManagerDidUpdateLocationsCompletion: LoacationManagerDidUpdateLocations?) {
        self.loacationManagerDidUpdateLocationsCompletion = loacationManagerDidUpdateLocationsCompletion
    }
    
    private var regeocodeFirstClousre: (([CLPlacemark], LocationError) -> Void)?
    public fileprivate(set) var isCanceld: Bool = false
    public fileprivate(set) lazy var geocoder: CLGeocoder = CLGeocoder()
    
    fileprivate func executeCompletion(_ locations: [CLLocation], error: LocationError) {
        DispatchQueue.main.async {
            self.locations = locations
            self.loacationManagerDidUpdateLocationsCompletion?(locations, error)
            if locations.count > 0 && self.regeocodeFirstClousre != nil {
                self.regeocodeLocation(locations[0], self.regeocodeFirstClousre)
            }
        }
    }
    
    public func regeocodeLocation(_ location: CLLocation, _ completion: (([CLPlacemark], LocationError) -> Void)?) {
        self.geocoder.cancelGeocode()
        if self.locations.count > 0 {
            self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error as NSError? {
                    completion?(placemarks ?? [], LocationError.error(withError: error))
                } else {
                    completion?(placemarks ?? [], LocationError.success)
                }
            }
        }
    }
    
    public enum GeocodeError: LocalizedError {
        case locationNil
        
        var errorDescription: String {
            switch self {
            case .locationNil:
                return "未知的地位位置"
            }
        }
    }
    
    /// 反地理编码
    public func regeocodeFirstLocation(_ completion: (([CLPlacemark], LocationError) -> Void)?) -> LocationTask {
        self.regeocodeFirstClousre = completion
        return self
    }
}
