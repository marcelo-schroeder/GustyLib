Pod::Spec.new do |s|
    s.name          = 'GustyLib'
    s.version       = '0.1.2'
    s.summary       = 'A Cocoa Touch static library to help you develop high quality iOS apps faster.'
    s.homepage      = 'https://bitbucket.org/marcelo_schroeder/gustylib'
    s.license       = 'Apache-2.0'
    s.author        = { 'Marcelo Schroeder' => 'marcelo.schroeder@infoaccent.com' }
    s.platform      = :ios, '7.0'
    s.requires_arc  = true
    s.source        = { :git => 'https://bitbucket.org/marcelo_schroeder/gustylib.git', :tag => '0.1.2' }
    s.subspec 'Core' do |cs|
        s.source_files  = 'GustyLib/GustyLib/Core/classes/**/*.{h,m}'
        s.resource      = 'GustyLib/GustyLib/Core/resources/**/*.*'
        s.dependency 'DTFoundation', '1.6.2'
        s.dependency 'FlurrySDK'
        s.dependency 'MTStatusBarOverlay', '0.9.1'
        s.dependency 'ODRefreshControl', '1.1.0'
        s.dependency 'MWFeedParser', '1.0.1'
    end
    s.subspec 'GoogleMobileAdsSupport' do |cs|
        s.source_files  = 'GustyLib/GustyLib/GoogleMobileAdsSupport/classes/**/*.{h,m}'
        s.resource      = 'GustyLib/GustyLib/GoogleMobileAdsSupport/resources/**/*.*'
        s.frameworks    = 'AdSupport', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreTelephony', 'MessageUI', 'StoreKit', 'SystemConfiguration'
        s.xcconfig      = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'IFA_AVAILABLE_GoogleMobileAdsSupport=1' }
        s.dependency 'Google-AdMob-Ads-SDK'
    end
end
