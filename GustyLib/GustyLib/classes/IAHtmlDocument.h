//
//  IAHtmlDocument.h
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

#import <Foundation/Foundation.h>

@interface IAHtmlDocument : NSObject

@property (nonatomic, strong) NSString *p_htmlTemplateStringResourceName;
@property (nonatomic, strong) NSString *p_htmlStyleStringResourceName;

@property (nonatomic, strong) NSString *p_htmlTemplateString;
@property (nonatomic, strong) NSString *p_htmlMetaString;
@property (nonatomic, strong) NSString *p_htmlStyleString;
@property (nonatomic, strong) NSString *p_htmlBodyString;
@property (nonatomic) CGFloat p_viewportWidth;

@property (nonatomic, strong) NSArray *p_htmlStyleStringFormatArguments;

-(id)initWithHtmlStyleResourceName:(NSString*)a_htmlStyleResourceName;
-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName;
-(id)initWithHtmlTemplateResourceName:(NSString*)a_htmlTemplateResourceName htmlStyleResourceName:(NSString*)a_htmlStyleResourceName htmlBody:(NSString*)a_htmlBody;

+ (NSArray *)classNamesFromClassAttributeValue:(NSString *)a_classAttributeValue;

-(NSString*)htmlString;
-(NSString*)htmlStringWithBody:(NSString*)a_body;

@end
