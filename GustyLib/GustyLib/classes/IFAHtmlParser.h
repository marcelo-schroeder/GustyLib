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

@class IFAHtmlDocumentPosition;
@class IFAHtmlElementParsingContext;


typedef void (^IFAHtmlParserEndElementBlock)(IFAHtmlElementParsingContext *a_parsingContext);

@interface IFAHtmlParser : NSObject <DTHTMLParserDelegate>

@property(nonatomic, strong, readonly) NSMutableString *mutableHtmlString;
@property(nonatomic, strong, readonly) NSMutableArray *elementMetadataStack;

- (NSString *)stringForStartPosition:(IFAHtmlDocumentPosition *)a_startPosition
                         endPosition:(IFAHtmlDocumentPosition *)a_endPosition;

- (NSString *)parseHtmlString:(NSString *)a_htmlString endElementBlock:(IFAHtmlParserEndElementBlock)a_endElementBlock;

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

@interface IFAHtmlDocumentPosition : NSObject
@property (nonatomic) NSUInteger line;
@property (nonatomic) NSUInteger column;
- (id)initWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
+ (IFAHtmlDocumentPosition *)positionWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
@end

@interface IFAHtmlElementParsingMetadata : NSObject

/**
* Element's start position.
*/
@property (nonatomic, strong) IFAHtmlDocumentPosition *startPosition;

/**
* Element's end position.
* Only available when IFAHtmlParserEndElementBlock is called.
*/
@property (nonatomic, strong) IFAHtmlDocumentPosition *endPosition;

/**
* Element's name.
*/
@property (nonatomic, strong) NSString *name;

/**
* Element's string representation.
* Only available when IFAHtmlParserEndElementBlock is called.
*/
@property (nonatomic, strong) NSString *stringRepresentation;

/**
* Element's key/value pairs.
*/
@property (nonatomic, strong) NSDictionary *attributes;

- (id)initWithName:(NSString *)a_name attributes:(NSDictionary *)a_attributes startPosition:(IFAHtmlDocumentPosition *)a_startPosition;

- (id)initWithMetadata:(IFAHtmlElementParsingMetadata *)a_metadata;

@end

@interface IFAHtmlElementParsingContext : NSObject
@property (nonatomic, strong) IFAHtmlElementParsingMetadata *elementMetadata;
@property (nonatomic, weak) IFAHtmlParser *parser;

- (id)initWithElementMetadata:(IFAHtmlElementParsingMetadata *)a_elementMetadata
                       parser:(IFAHtmlParser *)a_parser;
@end

@interface IFAHtmlLineParsingMetadata : NSObject
@property (nonatomic) NSUInteger lengthBeforeThisLine;
@end