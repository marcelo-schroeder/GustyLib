#wip: need to create my own Cocoapods repo for GoogleMobileAds
#wip: do the same with Flurry support
#wip: create private podspec repo for things like GoogleMobileAds and Flurry
#wip: when v0.1.2 is ready, make the IFACrashlyticsSupport project point to the 0.1.2 tag in its podfile (it is pointing to a development branch at the moment)
Pod::Spec.new do |s|
    s.name                  = 'GustyLib'
    s.version           = '0.1.2'
    s.summary           = 'A Cocoa Touch static library to help you develop high quality iOS apps faster.'
    s.homepage          = 'https://bitbucket.org/marcelo_schroeder/gustylib'
    s.license           = 'Apache-2.0'
    s.author            = { 'Marcelo Schroeder' => 'marcelo.schroeder@infoaccent.com' }
    s.platform          = :ios, '7.0'
    s.requires_arc      = true
    s.source            = { :git => 'https://bitbucket.org/marcelo_schroeder/gustylib.git', :tag => '0.1.2' }
    s.default_subspec   = 'Core'
    s.subspec 'Core' do |ss|
        ss.source_files  = 'GustyLib/GustyLib/Core/classes/**/*.{h,m}'
        ss.resource      = 'GustyLib/GustyLib/Core/resources/**/*.*'
        ss.dependency 'DTFoundation', '1.6.2'
        ss.dependency 'FlurrySDK'
        ss.dependency 'MTStatusBarOverlay', '0.9.1'
        ss.dependency 'ODRefreshControl', '1.1.0'
        ss.dependency 'MWFeedParser', '1.0.1'
    end
    s.subspec 'GoogleMobileAdsSupport' do |ss|
        ss.source_files  = 'GustyLib/GustyLib/GoogleMobileAdsSupport/classes/**/*.{h,m}'
        ss.resource      = 'GustyLib/GustyLib/GoogleMobileAdsSupport/resources/**/*.*'
        ss.frameworks    = 'AdSupport', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreTelephony', 'MessageUI', 'StoreKit', 'SystemConfiguration'
        ss.xcconfig      = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'IFA_AVAILABLE_GoogleMobileAdsSupport=1' }
        ss.dependency 'Google-AdMob-Ads-SDK'
    end
end
