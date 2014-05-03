//
//  IAHtmlDocument.m
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

#import "IACommon.h"

@implementation IAHtmlDocument{
    
    @private
    NSString *v_htmlTemplateStringResourceName;
    NSString *v_htmlStyleStringResourceName;
    
}


#pragma mark - Overrides

-(id)init{
    return [self initWithHtmlStyleResourceName:nil];
}

#pragma mark - Public

-(NSString *)p_htmlTemplateStringResourceName{
    return v_htmlTemplateStringResourceName;
}

-(void)setP_htmlTemplateStringResourceName:(NSString *)a_htmlTemplateStringResourceName{
    v_htmlTemplateStringResourceName = a_htmlTemplateStringResourceName;
    self.p_htmlTemplateString = [IAUtils m_stringFromResource:v_htmlTemplateStringResourceName type:nil];
}

-(NSString *)p_htmlStyleStringResourceName{
    return v_htmlStyleStringResourceName;
}

-(void)setP_htmlStyleStringResourceName:(NSString *)a_htmlStyleStringResourceName{
    v_htmlStyleStringResourceName = a_htmlStyleStringResourceName;
    self.p_htmlStyleString = v_htmlStyleStringResourceName ? [IAUtils m_stringFromResource:v_htmlStyleStringResourceName type:nil] : @"";
}

-(id)initWithHtmlStyleResourceName:(NSString*)a_htmlStyleResourceName{
    return [self initWithHtmlTemplateResourceName:@"IAHtmlTemplate.txt" htmlStyleResourceName:a_htmlStyleResourceName];
}

-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName{
    return [self initWithHtmlTemplateResourceName:a_htmlTemplateResourceName htmlStyleResourceName:a_htmlStyleResourceName htmlBody:@""];
}

-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName htmlBody:(NSString*)a_htmlBody{
    if (self=[super init]) {
        self.p_htmlTemplateStringResourceName = a_htmlTemplateResourceName;
        self.p_htmlStyleStringResourceName = a_htmlStyleResourceName;
        self.p_htmlBodyString = a_htmlBody;
    }
    return self;
}

-(NSString*)htmlString {
    NSString *l_htmlMetaString = self.p_htmlMetaString;
    if (!l_htmlMetaString) {
        l_htmlMetaString = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%@, initial-scale=1.0, maximum-scale=1.0\">", self.p_viewportWidth>0 ? [@(self.p_viewportWidth) description] : @"device-width"];
    }
//    NSLog(@"l_htmlMetaString: %@", l_htmlMetaString);
    NSString *l_htmlStyleString = self.p_htmlStyleString;
    if (self.p_htmlStyleStringFormatArguments) {
        l_htmlStyleString = [NSString m_stringWithFormat:l_htmlStyleString array:self.p_htmlStyleStringFormatArguments];
    }
    NSArray *l_arguments = @[l_htmlMetaString, l_htmlStyleString, self.p_htmlBodyString];
    NSString *l_htmlString = [NSString m_stringWithFormat:self.p_htmlTemplateString array:l_arguments];
//    NSLog(@"l_htmlString: %@", l_htmlString);
    return l_htmlString;
}

-(NSString*)htmlStringWithBody:(NSString*)a_body{
    self.p_htmlBodyString = a_body;
    return [self htmlString];
}

+ (NSArray *)classNamesFromClassAttributeValue:(NSString *)a_classAttributeValue {
    return [a_classAttributeValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
