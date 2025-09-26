require "json"
new_arch_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'
package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-amap3d"
  s.module_name  = 'ReactNativeAmap3d'
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/qiuxiang/react-native-amap3d.git", :tag => "#{s.version}" }

  s.frameworks   = 'CoreLocation'
  # s.source_files = "lib/ios/**/*.{h,m,mm,cpp,swift}"
  s.source_files = "lib/ios/**/*"
  s.private_header_files = "lib/ios/*/*.h","lib/ios/*/*/*.h","lib/ios/*/*/*/*.h"
  s.public_header_files = "lib/ios/*.h"
  # 排除文件
  s.exclude_files = "lib/ios/MapView/MarkerComponentView.mm", "lib/ios/MapView/MarkerComponentView.h"
   if new_arch_enabled then
    # s.exclude_files = "lib/ios/MapView/MapViewManager.m", "lib/ios/MapView/MapViewManager.swift"
  else
    # s.exclude_files = "lib/ios/MapView/MarkerComponentView.mm", "lib/ios/MapView/MarkerComponentView.h"
  end
  
  if defined?(install_modules_dependencies()) != nil
    install_modules_dependencies(s)
  else
    # Don't install the dependencies when we run `pod install` in the old architecture.
    if new_arch_enabled then
      folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17",
          "CLANG_CXX_LIBRARY" => "libc++"
      }

      s.dependency "React-RCTFabric"
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    else
      s.dependency "React-Core"
    end
  end

  s.dependency 'AMapNavi', "~> 10.0.8"
  s.dependency 'AMapSearch',"~> 9.7.0"
  s.dependency 'AMapTrack', "~> 1.4.2"
  s.dependency 'AMapLocation', "~> 2.9.0"
  s.static_framework = true  
end
