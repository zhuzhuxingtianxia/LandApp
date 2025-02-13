require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-amap3d"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/qiuxiang/react-native-amap3d.git", :tag => "#{s.version}" }

  s.frameworks   = 'CoreLocation'
  s.source_files = "lib/ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"

  s.dependency 'AMapNavi', "~> 10.0.8"
  s.dependency 'AMapSearch',"~> 9.7.0"
  s.dependency 'AMapTrack', "~> 1.4.2"
  s.dependency 'AMapLocation', "~> 2.9.0"
  s.static_framework = true  
end
