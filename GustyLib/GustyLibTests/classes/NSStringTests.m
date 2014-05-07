//
//  Gusty - NSStringTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IFACommonTests.h"
#import "NSString+IFACategory.h"

@interface NSStringTests : XCTestCase
@end

@implementation NSStringTests{
}

- (void)testCharacters {
    assertThat([@"Test me!" ifa_characters], contains(@"T", @"e", @"s", @"t", @" ", @"m", @"e", @"!", nil));
}

- (void)testStringWithNumbersOnly{
    assertThat([@"abcd" ifa_stringWithNumbersOnly], is(equalTo(@"")));
    assertThat([@"1234" ifa_stringWithNumbersOnly], is(equalTo(@"1234")));
    assertThat([@"1.4l5(0 12" ifa_stringWithNumbersOnly], is(equalTo(@"145012")));
}

- (void)testStringByReplacingOccurrencesOfRegexPattern {

    // given
    NSString *l_inputString = @"\
<html>\
<body>\
<a href=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\">\
<img class=\"alignleft size-medium wp-image-1578\" src=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads-300x237.jpg\" alt=\"Instagram-ads\" width=\"300\" height=\"237\" />\
</a>\
<a href=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\">\
<img class=\"fullwidth\" alt=\"Instagram-ads\" src=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\" />\
</a>\
</body>\
</html>\
";

    // when
    __block NSUInteger l_counter = 0;
    NSMutableArray *l_matchedStrings = [@[] mutableCopy];
    NSString *l_outputString = [l_inputString ifa_stringByReplacingOccurrencesOfRegexPattern:@"<img[^>]*>"
                                                                                  usingBlock:^NSString *(NSString *a_matchedString) {
                                                                                      [l_matchedStrings addObject:a_matchedString];
                                                                                      return [NSString stringWithFormat:@"TEST%u",
                                                                                                                        ++l_counter];
                                                                                  }];

    // then
    NSString *l_expectedOutputString = @"\
<html>\
<body>\
<a href=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\">\
TEST1\
</a>\
<a href=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\">\
TEST2\
</a>\
</body>\
</html>\
";
    assertThat(l_outputString, is(equalTo(l_expectedOutputString)));
    NSArray *l_expectedMatchedString = @[
            @"<img class=\"alignleft size-medium wp-image-1578\" src=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads-300x237.jpg\" alt=\"Instagram-ads\" width=\"300\" height=\"237\" />",
            @"<img class=\"fullwidth\" alt=\"Instagram-ads\" src=\"http://meganews.cloudcms4apps.com/files/2013/10/Instagram-ads.jpg\" />"
    ];
    assertThat(l_matchedStrings, is(equalTo(l_expectedMatchedString)));

}

@end
