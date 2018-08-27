

Pod::Spec.new do |s|


  s.name         = "JYBD_IDCardRecognition"
  s.version      = "1.0.0"
  s.summary      = "身份证扫描识别"

  s.description  = <<-DESC
                省份证扫描识别，支持正反面，及截取图片
                   DESC

  s.homepage     = "http://git.jybd.cn/ios_private/JYBD_IDCardRecognition.git"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "tianxiuping" => "tianxiupingios@126.com" }



   s.platform     = :ios, "8.0"



  s.source       = { :git => "http://git.jybd.cn/ios_private/JYBD_IDCardRecognition.git", :tag => "#{s.version}" }



    s.source_files  = "Classes/**/*.{h,m}"


#  s.public_header_files = "Classes/JYBDIDCardRecognition.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
   s.resources = "Resources/*.png","dicts/zocr0.lib"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
    s.vendored_libraries = "Frameworks/libexidcardios.a"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #


end
