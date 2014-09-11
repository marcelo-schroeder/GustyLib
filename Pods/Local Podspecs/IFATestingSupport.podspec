Pod::Spec.new do |s|
    s.name          = 'IFATestingSupport'
    s.version       = '0.1.3'
    s.summary       = 'Utilities to make unit testing with OCHamcrest and OCMock easier.'
    s.homepage      = 'https://bitbucket.org/marcelo_schroeder/ifatestingsupport'
    s.license       = 'Apache-2.0'
    s.author        = { 'Marcelo Schroeder' => 'marcelo.schroeder@infoaccent.com' }
    s.platform      = :ios, '8.0'
    s.source        = { :git => 'https://bitbucket.org/marcelo_schroeder/ifatestingsupport.git', :tag => '0.1.3' }
    s.source_files  = 'IFATestingSupport/**/*.{h,m}'
    s.frameworks    = 'XCTest', 'CoreGraphics'
    s.requires_arc  = true
    s.dependency 'OCHamcrest'
    s.dependency 'OCMock', '2.2.4'
end
