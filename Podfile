platform :ios, '8.0'
workspace 'GustyLib'
xcodeproj 'GustyLib/GustyLib.xcodeproj'
link_with 'GustyLibTests'

# Core dependencies
pod 'ODRefreshControl', '1.1.0'

# GoogleMobileAdsSupport dependencies
pod 'Google-Mobile-Ads-SDK'

# FlurrySupport dependencies
pod 'FlurrySDK'

# Html dependencies
pod 'DTFoundation', '1.7.2'
pod 'MWFeedParser', '1.0.1'

# Help dependencies
pod 'WYPopoverController', '0.3.0'

# Tests dependencies
#pod 'IFATestingSupport', :git => 'https://bitbucket.org/marcelo_schroeder/ifatestingsupport.git', :tag => '0.1.1'
pod 'IFATestingSupport', :path => '/Users/mschroeder/myfiles/projects/Xcode6/IFATestingSupport/IFATestingSupport_development'
pod 'OCHamcrest'
pod 'OCMock'

# 10/09/2014 - Xcode 6 Hack - Inspired by http://stackoverflow.com/questions/24275470/xctest-xctest-h-not-found-on-old-projects-built-in-xcode-6
# The XCTest framework seems to be no longer available by default for non-test targets, which cause the pod for IFATestingSupport to fail to build.
# Apparently a new version of Cocoapods coming out soon will fix this issue (current=0.33.1), but until then the code block below will do the trick.
post_install do |installer|
    target = installer.project.targets.find { |t| t.to_s == "Pods-IFATestingSupport" }
    if (target)
        target.build_configurations.each do |config|
            s = config.build_settings['FRAMEWORK_SEARCH_PATHS']
            s = [ '$(inherited)' ] if s == nil;
            s.push('$(PLATFORM_DIR)/Developer/Library/Frameworks')
            config.build_settings['FRAMEWORK_SEARCH_PATHS'] = s
        end
        else
        puts "WARNING: Pods-IFATestingSupport"
    end
end