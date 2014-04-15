Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "GustyLib"
  s.version      = "0.1.0"
  s.summary      = "A Cocoa Touch static library to help you develop high quality iOS apps faster."
  s.description  = <<-DESC
                   TBD
                   DESC
  s.homepage     = "https://bitbucket.org/marcelo_schroeder/gustylib"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "Apache-2.0"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Marcelo Schroeder" => "marcelo.schroeder@infoaccent.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://bitbucket.org/marcelo_schroeder/gustylib.git", :tag => "0.1.0" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "GustyLib/classes/**/*.{h,m}"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resource  = "GustyLib/resources/**/*.*"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.frameworks = "CoreData", "CoreText", "CoreLocation", "QuartzCore", "MapKit", "MessageUI", "GLKit", "AdSupport", "StoreKit", "GLKit", "Accelerate"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

    s.dependency 'DTFoundation', '1.6.2'
    s.dependency 'Google-AdMob-Ads-SDK'
    s.dependency 'FlurrySDK'
    s.dependency 'MTStatusBarOverlay', '0.9.1'
    s.dependency 'ODRefreshControl', '1.1.0'
    s.dependency 'MWFeedParser', '1.0.1'

end
