
Pod::Spec.new do |s|

  s.name         = "AVCaches"
  s.version      = "0.8.9"
  s.summary      = "A swift cache for AVPlayer of AVCaches."  
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

  s.source_files        = 'Source/AVCaches/*.{h,m}'
  s.public_header_files = 'source/AVCaches/*.h'

end
