//
//  IFAHtmlDocument.m
//  Gusty
//
//  Created by Marcelo Schroeder on 10/07/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLibCoreUI.h"

@interface IFAHtmlDocument ()
@property (nonatomic, strong) NSString *htmlTemplateStringResourceName;
@property (nonatomic, strong) NSBundle *htmlTemplateStringResourceBundle;
@property (nonatomic, strong) NSString *htmlStyleStringResourceName;
@property (nonatomic, strong) NSBundle *htmlStyleStringResourceBundle;
@end

@implementation IFAHtmlDocument


#pragma mark - Overrides

-(id)init{
    return [self initWithHtmlStyleResourceName:nil
                       htmlStyleResourceBundle:nil];
}

#pragma mark - Public

- (void)setHtmlTemplateStringResourceName:(NSString *)a_htmlTemplateStringResourceName {
    _htmlTemplateStringResourceName = a_htmlTemplateStringResourceName;
    self.htmlTemplateString = [IFAUtils stringFromResource:self.htmlTemplateStringResourceName
                                                      type:nil
                                                  inBundle:self.htmlTemplateStringResourceBundle];
}

- (void)setHtmlStyleStringResourceName:(NSString *)a_htmlStyleStringResourceName {
    _htmlStyleStringResourceName = a_htmlStyleStringResourceName;
    self.htmlStyleString = self.htmlStyleStringResourceName ? [IFAUtils stringFromResource:self.htmlStyleStringResourceName
                                                                                      type:nil
                                                                                  inBundle:self.htmlStyleStringResourceBundle] : @"";
}

- (id)initWithHtmlStyleResourceName:(NSString *)a_htmlStyleResourceName
            htmlStyleResourceBundle:(NSBundle *)a_htmlStyleResourceBundle {
    return [self initWithHtmlTemplateResourceName:@"IFAHtmlTemplate.txt"
                       htmlTemplateResourceBundle:[NSBundle bundleForClass:[IFAUIUtils class]]
                            htmlStyleResourceName:a_htmlStyleResourceName
                          htmlStyleResourceBundle:a_htmlStyleResourceBundle];
}

- (id)initWithHtmlTemplateResourceName:(NSString *)a_htmlTemplateResourceName
            htmlTemplateResourceBundle:(NSBundle *)a_htmlTemplateResourceBundle
                 htmlStyleResourceName:(NSString *)a_htmlStyleResourceName
               htmlStyleResourceBundle:(NSBundle *)a_htmlStyleResourceBundle {
    return [self initWithHtmlTemplateResourceName:a_htmlTemplateResourceName
                       htmlTemplateResourceBundle:a_htmlTemplateResourceBundle
                            htmlStyleResourceName:a_htmlStyleResourceName
                          htmlStyleResourceBundle:a_htmlStyleResourceBundle
                                         htmlBody:@""];
}

- (id)initWithHtmlTemplateResourceName:(NSString *)a_htmlTemplateResourceName
            htmlTemplateResourceBundle:(NSBundle *)a_htmlTemplateResourceBundle
                 htmlStyleResourceName:(NSString *)a_htmlStyleResourceName
               htmlStyleResourceBundle:(NSBundle *)a_htmlStyleResourceBundle
                              htmlBody:(NSString *)a_htmlBody {
    if (self=[super init]) {
        self.htmlTemplateStringResourceBundle = a_htmlTemplateResourceBundle;
        self.htmlTemplateStringResourceName = a_htmlTemplateResourceName;
        self.htmlStyleStringResourceBundle = a_htmlStyleResourceBundle;
        self.htmlStyleStringResourceName = a_htmlStyleResourceName;
        self.htmlBodyString = a_htmlBody;
    }
    return self;
}

-(NSString*)htmlString {
    NSString *l_htmlMetaString = self.htmlMetaString;
    if (!l_htmlMetaString) {
        l_htmlMetaString = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%@, initial-scale=1.0, maximum-scale=1.0\">", self.viewportWidth >0 ? [@(self.viewportWidth) description] : @"device-width"];
    }
//    NSLog(@"l_htmlMetaString: %@", l_htmlMetaString);
    NSString *l_htmlStyleString = self.htmlStyleString;
    if (self.htmlStyleStringFormatArguments) {
        l_htmlStyleString = [NSString ifa_stringWithFormat:l_htmlStyleString
                                                     array:self.htmlStyleStringFormatArguments];
    }
    NSArray *l_arguments = @[l_htmlMetaString, l_htmlStyleString, self.htmlBodyString];
    NSString *l_htmlString = [NSString ifa_stringWithFormat:self.htmlTemplateString array:l_arguments];
//    NSLog(@"l_htmlString: %@", l_htmlString);
    return l_htmlString;
}

-(NSString*)htmlStringWithBody:(NSString*)a_body{
    self.htmlBodyString = a_body;
    return [self htmlString];
}

+ (NSArray *)classNamesFromClassAttributeValue:(NSString *)a_classAttributeValue {
    return [a_classAttributeValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
