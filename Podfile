platform :ios, '7.0'
workspace 'GustyLib'
xcodeproj 'GustyLib/GustyLib.xcodeproj'
link_with 'GustyLibTests'

pod 'DTFoundation'
pod 'Google-AdMob-Ads-SDK'
pod 'FlurrySDK'
pod 'MTStatusBarOverlay'
pod 'OCHamcrest'
pod 'OCMock'
pod 'ODRefreshControl'
pod 'MWFeedParser'

pod 'IFATestingSupport', :git => 'https://bitbucket.org/marcelo_schroeder/ifatestingsupport.git', :tag => '0.1.1'
# pod 'IFATestingSupport', :path => '/Users/mschroeder/myfiles/projects/Xcode5/IFATestingSupport/IFATestingSupport_development'

#wip: review this
# This pod is being to allow the GustyLib code to compile (the repo is mantained by a 3rd party).
# I had to do this via a pod otherwise GustyLib wouldn't build when integrated with the client app.
# The Crashlytics framework (kept up to date by the Crashlytics Mac app) must be available in the client app.
pod 'CrashlyticsFramework'
