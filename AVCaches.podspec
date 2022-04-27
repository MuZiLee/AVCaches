
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

  s.source_files        = 'Source/AVCaches/TTPlayerCache.h'
  s.public_header_files = 'source/AVCaches/TTPlayerCache.h','source/AVCaches/TTPlayerCache-Swift.h'


  s.subspec 'Reachability' do |ss|
    ss.source_files        = 'Source/AVCaches/Reachability/*.{h,m}'
    ss.public_header_files = 'Source/AVCaches/Reachability/*.h'
  end

  s.subspec 'Category' do |ss| 
    ss.source_files        = 'Source/AVCaches/Category/*.{h,m}'
    ss.public_header_files = 'Source/AVCaches/Category/*.h'
  end

  s.subspec 'AVCaches' do |ss|
    ss.dependency 'AVCaches/Category'
    ss.dependency 'AVCaches/Reachability'

    ss.source_files        = 'Source/AVCaches/TTPlayerCacheMacro.h', 'Source/AVCaches/TTResourceLoader{Delegate,Data,Cache}.{h,m}'
    ss.public_header_files = 'Source/AVCaches/TTPlayerCacheMacro.h', 'Source/AVCaches/TTResourceLoader{Delegate,Data,Cache}.h'
  end

end
