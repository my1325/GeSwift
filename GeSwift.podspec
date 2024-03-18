Pod::Spec.new do |s|

 s.name             = "GeSwift"
 s.version           = "0.2.3"
 s.summary         = "GeSwift for my's ioser"
 s.homepage        = "https://github.com/my1325/GeSwift.git"
 s.license            = "MIT"
 s.platform          = :ios, "13.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/GeSwift.git", :tag => "#{s.version}" }
 s.swift_version = '5.1'
 s.default_subspecs = 'Tools'

 s.subspec 'Tools' do |ss|
  ss.source_files = 'Sources/FoundationTools/*.swift'
 end 
  
  s.subspec 'DataSource' do |ss|
    ss.source_files = 'Sources/DataSources/*.swift'
  end

  s.subspec 'Custom' do |ss|
    ss.source_files = 'Sources/CustomViews/**/*.swift'
    ss.dependency 'GeSwift/Tools'
    ss.dependency 'GeSwift/UIAbout'
  end

  s.subspec 'UIAbout' do |ss|
    ss.source_files = 'Sources/UITools/*.swift'
  end 

  s.subspec 'CollectionViewLayouts' do |ss|
    ss.source_files = 'Sources/CollectionViewLayouts/*.swift'
  end 

  s.subspec 'SwiftUITools' do |ss|
    ss.source_files = 'Sources/SwiftUITools/*.swift'
  end 
end
