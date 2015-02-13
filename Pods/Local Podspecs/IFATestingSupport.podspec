Pod::Spec.new do |s|
    s.name          = 'IFATestingSupport'
    s.version       = '1.0.1'
    s.summary       = 'Utilities to make unit testing with OCHamcrest and OCMock easier.'
    s.homepage      = 'https://github.com/marcelo-schroeder/IFATestingSupport'
    s.license       = 'Apache-2.0'
    s.author        = { 'Marcelo Schroeder' => 'marcelo.schroeder@infoaccent.com' }
    s.platform      = :ios, '8.0'
    s.source        = { :git => 'https://github.com/marcelo-schroeder/IFATestingSupport.git', :tag => 'v1.0.1' }
    s.source_files  = 'IFATestingSupport/**/*.{h,m}'
    s.frameworks    = 'XCTest', 'CoreGraphics'
    s.requires_arc  = true
    s.dependency 'OCHamcrest', '~> 4'
    s.dependency 'OCMock', '~> 3'
end
