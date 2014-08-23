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

#import "GustyLib.h"
#import "IFAHtmlDocument.h"

@interface IFAHtmlDocument ()
@property(nonatomic, strong) NSString *IFA_htmlTemplateStringResourceName;
@property(nonatomic, strong) NSString *IFA_htmlStyleStringResourceName;
@end

@implementation IFAHtmlDocument


#pragma mark - Overrides

-(id)init{
    return [self initWithHtmlStyleResourceName:nil];
}

#pragma mark - Public

-(NSString *)htmlTemplateStringResourceName {
    return self.IFA_htmlTemplateStringResourceName;
}

-(void)setHtmlTemplateStringResourceName:(NSString *)a_htmlTemplateStringResourceName{
    self.IFA_htmlTemplateStringResourceName = a_htmlTemplateStringResourceName;
    self.htmlTemplateString = [IFAUtils stringFromResource:self.IFA_htmlTemplateStringResourceName type:nil];
}

-(NSString *)htmlStyleStringResourceName {
    return self.IFA_htmlStyleStringResourceName;
}

-(void)setHtmlStyleStringResourceName:(NSString *)a_htmlStyleStringResourceName{
    self.IFA_htmlStyleStringResourceName = a_htmlStyleStringResourceName;
    self.htmlStyleString = self.IFA_htmlStyleStringResourceName ? [IFAUtils stringFromResource:self.IFA_htmlStyleStringResourceName
                                                                                   type:nil] : @"";
}

-(id)initWithHtmlStyleResourceName:(NSString*)a_htmlStyleResourceName{
    return [self initWithHtmlTemplateResourceName:@"IFAHtmlTemplate.txt" htmlStyleResourceName:a_htmlStyleResourceName];
}

-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName{
    return [self initWithHtmlTemplateResourceName:a_htmlTemplateResourceName htmlStyleResourceName:a_htmlStyleResourceName htmlBody:@""];
}

-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName htmlBody:(NSString*)a_htmlBody{
    if (self=[super init]) {
        self.htmlTemplateStringResourceName = a_htmlTemplateResourceName;
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
