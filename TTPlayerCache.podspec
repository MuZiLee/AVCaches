
Pod::Spec.new do |s|

  s.name         = "AVCaches"
  s.version      = "0.2.0"
  s.summary      = "A cache for AVPlayer of AVCaches."  
  s.homepage     = "https://github.com/MuZiLee/AVCaches"
  s.license      = "MIT"
  s.author       = { "sun" => "1919345806@qq.com" }

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => 'https://github.com/MuZiLee/AVCaches.git', 
                     :tag => s.version.to_s ,
                     :submodules => true}
  s.requires_arc = true
  s.frameworks   = "UIKit","AVFoundation","SystemConfiguration","MobileCoreServices"

  s.source_files        = 'Source/TTPlayerCache/TTPlayerCache.h'
  s.public_header_files = 'source/TTPlayerCache/TTPlayerCache.h'


  s.subspec 'Reachability' do |ss|
    ss.source_files        = 'Source/TTPlayerCache/Reachability/*.{h,m}'
    ss.public_header_files = 'Source/TTPlayerCache/Reachability/*.h'
  end

  s.subspec 'Category' do |ss| 
    ss.source_files        = 'Source/TTPlayerCache/Category/*.{h,m}'
    ss.public_header_files = 'Source/TTPlayerCache/Category/*.h'
  end

  s.subspec 'PlayerCache' do |ss|
    ss.dependency 'TTPlayerCache/Category'
    ss.dependency 'TTPlayerCache/Reachability'

    ss.source_files        = 'Source/TTPlayerCache/TTPlayerCacheMacro.h', 'Source/TTPlayerCache/TTResourceLoader{Delegate,Data,Cache}.{h,m}'
    ss.public_header_files = 'Source/TTPlayerCache/TTPlayerCacheMacro.h', 'Source/TTPlayerCache/TTResourceLoader{Delegate,Data,Cache}.h'
  end

end
