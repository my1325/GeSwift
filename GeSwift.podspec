Pod::Spec.new do |s|

 s.name             = "GeSwift"
 s.version           = "0.2.0"
 s.summary         = "GeSwift for my's ioser"
 s.homepage        = "https://github.com/my1325/GeSwift.git"
 s.license            = "MIT"
 s.platform          = :ios, "12.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/GeSwift.git", :tag => "#{s.version}" }
 s.swift_version = '5.1'
 s.default_subspecs = 'Tools'

 s.subspec 'Tools' do |ss|
  ss.source_files = 'Tools/**/*.swift'
 end 
  
 s.subspec 'DataSource' do |ss|
   ss.source_files = 'DataSource/**/*.swift'
 end

 s.subspec 'Custom' do |ss|
   ss.source_files = 'Custom/**/*.swift'
 end
end
