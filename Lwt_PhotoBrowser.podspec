

Pod::Spec.new do |s|
  s.name         = "Lwt_PhotoBrowser"
  s.version      = "1.0.0"
  s.summary      = "photo browser for ios, which can browse Photo library and web image"
  s.homepage     = "https://github.com/lwt211/Lwt_PhotoBrowser"
  s.license      = "MIT"
  s.author             = { "Li Wentao" => "https://github.com/lwt211/Lwt_PhotoBrowser" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/lwt211/Lwt_PhotoBrowser.git", :tag => "1.0.0" }
  s.source_files  = "Lwt_PhotoBrowser/**/*.{h,m}"
  # s.resources = "Lwt_PhotoBrowser/**/*.png", "Lwt_PhotoBrowser/**/*.xib"
  s.requires_arc = true
  s.frameworks = "UIKit","ImageIO"
  s.dependency 'SDWebImage', '~> 3.8.2'


  # s.public_header_files = "Classes/**/*.h"
  


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
