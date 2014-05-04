//
// Created by Marcelo Schroeder on 27/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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
#import "DTHTMLParser.h"

@class IAHtmlDocumentPosition;
@class IAHtmlElementParsingContext;


typedef void (^IAHtmlParserEndElementBlock)(IAHtmlElementParsingContext *a_parsingContext);

@interface IAHtmlParser : NSObject <DTHTMLParserDelegate>

@property(nonatomic, strong, readonly) NSMutableString *mutableHtmlString;

- (NSString *)stringForStartPosition:(IAHtmlDocumentPosition *)a_startPosition
                         endPosition:(IAHtmlDocumentPosition *)a_endPosition;

- (NSString *)parseHtmlString:(NSString *)a_htmlString endElementBlock:(IAHtmlParserEndElementBlock)a_endElementBlock;

- (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString;

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes;

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes
                     shouldClose:(BOOL)a_shouldClose;

+ (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString
               inHtmlString:(NSMutableString *)a_htmlString;

+ (NSDictionary *)attributesFromStyleAttributeValue:(NSString *)a_styleAttributeValue;
+ (NSString *)styleAttributeValueFromAttributes:(NSDictionary *)a_attributes;

+ (NSString *)charactersBetweenOpenAndCloseTagsForStringRepresentation:(NSString *)a_stringRepresentation;
@end

@interface IAHtmlDocumentPosition : NSObject
@property (nonatomic) NSUInteger line;
@property (nonatomic) NSUInteger column;
- (id)initWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
+ (IAHtmlDocumentPosition *)positionWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
@end

@interface IAHtmlElementParsingMetadata : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *stringRepresentation;
@property (nonatomic, strong) NSDictionary *attributes;

- (id)initWithName:(NSString *)a_name stringRepresentation:(NSString *)a_stringRepresentation
        attributes:(NSDictionary *)a_attributes;

- (id)initWithMetadata:(IAHtmlElementParsingMetadata *)a_metadata;

@end

@interface IAHtmlElementParsingContext : NSObject
@property (nonatomic, strong) IAHtmlElementParsingMetadata *elementMetadata;
@property (nonatomic, weak) IAHtmlParser *parser;

- (id)initWithElementMetadata:(IAHtmlElementParsingMetadata *)a_elementMetadata
                       parser:(IAHtmlParser *)a_parser;
@end

@interface IAHtmlLineParsingMetadata : NSObject
@property (nonatomic) NSUInteger lengthBeforeThisLine;
@end