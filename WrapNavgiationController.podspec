Pod::Spec.new do |s|

 s.name             = "WrapNavgiationController"
 s.version           = "0.1.8"
 s.summary         = "WrapNavgationController for custom navigation"
 s.homepage        = "https://github.com/my1325/GeSwift.git"
 s.license            = "MIT"
 s.platform          = :ios, "10.0"
 s.authors           = { "mayong" => "1173962595@qq.com" }
 s.source             = { :git => "https://github.com/my1325/GeSwift.git", :tag => "#{s.version}" }
 s.swift_version = '5.1'
 s.source_files = 'Sources/GeSwift/WrapNavigationController/*.{swift}'
end
