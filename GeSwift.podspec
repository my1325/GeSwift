Pod::Spec.new do |s|

 s.name             = "GeSwift"
 s.version           = "0.1.0"
 s.summary         = "GeSwift for my's ioser"
 s.homepage        = "https://github.com/my1325/GeSwift.git"
 s.license            = "MIT"
 s.platform          = :ios, "10.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/GeSwift.git", :tag => "#{s.version}" }
 s.swift_version = '5.1'
 s.default_subspecs = 'Core','UI','Foundation'

    s.subspec 'Core' do |ss|
	ss.source_files = 'Sources/GeSwift/Core/*.{swift}'
    end
    
    s.subspec 'UI' do |ss|
	ss.source_files = 'Sources/GeSwift/UI/*.{swift}'
 	ss.dependency 'GeSwift/Core'
    ss.dependency 'GeSwift/Foundation'
    end
   
    s.subspec 'Foundation' do |ss|
	ss.source_files = 'Sources/GeSwift/Foundation/*.{swift}'
	ss.dependency 'GeSwift/Core'
    end


    s.subspec 'DataBase' do |ss|
    ss.source_files = 'GeSwift/Ge/DataBase/*.{swift}'
    ss.dependency 'GeSwift/Core'
	ss.dependency 'WCDB.swift'
    end 
    
    s.subspec 'Control' do |ss|
	ss.source_files = 'GeSwift/Ge/Control/**/*.{swift}'
	ss.dependency 'GeSwift/UI'
	ss.dependency 'GeSwift/Foundation'
	ss.dependency 'Schedule'
	ss.dependency 'SnapKit'
	ss.dependency 'Kingfisher'
    end

    s.subspec 'Codable' do |ss|
    ss.source_files = 'Sources/GeSwift/Codable/*.{swift}'
    ss.dependency 'GeSwift/Foundation'
    end 

    s.subspec 'KeyChain' do |ss|
    ss.source_files = 'Sources/GeSwift/KeyChain/*.{swift}'
    end

    s.subspec 'WrapNavgationController' do |ss|
    ss.source_files = 'Sources/GeSwift/WrapNavigationController/*.{swift}'
    end

    s.subspec 'LocationTask' do |ss|
    ss.source_files = 'Sources/GeSwift/LocationTask/*.{swift}'
    end 
end
