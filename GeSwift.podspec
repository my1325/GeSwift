Pod::Spec.new do |s|

 s.name             = "GeSwift"
 s.version           = "0.0.1"
 s.summary         = "GeSwift for my's ioser"
 s.homepage        = "https://github.com/my1325/GeSwift.git"
 s.license            = "MIT"
 s.platform          = :ios, "9.0"
 s.authors           = { "mayong" => "ma.yong@vpclub.cn" }
 s.source             = { :git => "https://github.com/my1325/GeSwift.git", :tag => "#{s.version}" }
 s.swift_version = '4.2'
 s.default_subspecs = 'Core','DataBase','UI','Foundation','Control'

    s.subspec 'Core' do |ss|
	ss.source_files = 'GeSwift/Ge/Core/*.{swift}'
    end
    
    s.subspec 'DataBase' do |ss|
        ss.source_files = 'GeSwift/Ge/DataBase/*.{swift}'
        ss.dependency 'GeSwift/Core'
	ss.dependency 'WCDB.swift'
    end 
    
    s.subspec 'UI' do |ss|
	ss.source_files = 'GeSwift/Ge/UI/*.{swift}'
 	ss.dependency 'GeSwift/Core'
    end
   
    s.subspec 'Foundation' do |ss|
	ss.source_files = 'GeSwift/Ge/Foundation/*.{swift}'
	ss.dependency 'GeSwift/Core'
    end
    
    s.subspec 'Control' do |ss|
	ss.source_files = 'GeSwift/Ge/Control/*.{swift}'	
	ss.dependency 'GeSwift/UI'
	ss.dependency 'GeSwift/Foundation'
	ss.dependency 'Schedule'
	ss.dependency 'SnapKit'
	ss.dependency 'Kingfisher'
    end
    
end