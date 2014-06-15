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
@class IFAHtmlElementParsingMetadata;


typedef void (^IFAHtmlParserEndElementBlock)(IFAHtmlElementParsingContext *a_parsingContext);

@interface IFAHtmlParser : NSObject <DTHTMLParserDelegate>

@property(nonatomic, strong, readonly) NSMutableString *mutableHtmlString;
@property(nonatomic, strong, readonly) NSMutableArray *elementMetadataStack;

- (NSString *)stringForStartPosition:(IFAHtmlDocumentPosition *)a_startPosition
                         endPosition:(IFAHtmlDocumentPosition *)a_endPosition;

- (NSString *)parseHtmlString:(NSString *)a_htmlString endElementBlock:(IFAHtmlParserEndElementBlock)a_endElementBlock;

/**
* Replace a given markup string with another.
* @param a_markupStringToBeReplaced HTML string to be replaced.
* @param a_newMarkupString HTML string to replace the HTML provided in a_markupStringToBeReplaced.
*/
- (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString;

/**
* Replace a given markup string with provided tag and attributes.
* @param a_markupStringToBeReplaced HTML string to be replaced.
* @param a_tagName In conjunction with a_attributes, will determine the HTML string to replace a_markupStringToBeReplaced;
* @param a_attributes In conjunction with a_tagName, will determine the HTML string to replace a_markupStringToBeReplaced;
*/
- (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withTag:(NSString *)a_tagName andAttributes:(NSDictionary *)a_attributes;

/**
* Replace the markup string of the first opening tag in a given HTML string representation with provided tag and attributes.
* @param a_stringRepresentation The first opening tag contained in this HTML string representation, will be replaced by the HTML generated from a_tagName and a_attributes.
* @param a_tagName In conjunction with a_attributes, will determine the HTML string to replace a_markupStringToBeReplaced;
* @param a_attributes In conjunction with a_tagName, will determine the HTML string to replace a_markupStringToBeReplaced;
*/
- (void)replaceFirstOpeningTagInStringRepresentation:(NSString *)a_stringRepresentation withTag:(NSString *)a_tagName andAttributes:(NSDictionary *)a_attributes;

/**
* Used to find the last ancestor HTML element that matches a given name.
* @param a_elementName Name of the HTML element to find.
* @returns Parsing metadata corresponding to the last ancestor HTML element that matched the name provided. Nil will be returned if no match has been found.
*/
- (IFAHtmlElementParsingMetadata *)lastAncestorHtmlElementNamed:(NSString *)a_elementName;

/**
* Returns the inline style attributes that are currently active at the time the IFAHtmlParserEndElementBlock block is called during parsing.
* @returns Dictionary containing the active inline style attributes.
*/
- (NSDictionary *)activeInlineStyleAttributes;

/**
* Returns string containing the top level element's opening tag from a given HTML element string representation.
* HTML comments are ignored.
* @param a_stringRepresentation HTML element string representation. The string representation can contain a HTML element hierarchy that is many levels deep.
* @returns String representing the top level element's opening tag.
*/
+ (NSString *)firstOpeningTagForStringRepresentation:(NSString *)a_stringRepresentation;

/**
* Removes HTML comments from the string representation.
* @param a_stringRepresentation HTML element string representation. The string representation can contain one or more elements.
* @returns HTML element string representation without any HTML comments.
*/
+ (NSString *)removeCommentsFromStringRepresentation:(NSString *)a_stringRepresentation;

/**
* Indicates whether the element's string representation has a closing tag or an opening tag that is self closing.
* @param a_stringRepresentation HTML element string representation. The string representation must contain a single element.
* @returns YES if element has a closing tag or an opening tag that is self closing.
*/
+ (BOOL)isElementClosedForStringRepresentation:(NSString *)a_stringRepresentation;

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes;

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes
                     shouldClose:(BOOL)a_shouldClose;

+ (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString
               inHtmlString:(NSMutableString *)a_htmlString;

/**
* Creates a dictionary from inline CSS style key/value pairs.
* This method does the opposite of the styleAttributeValueFromAttributes: method.
* For instance, in the HTML code below:
*
*   <p style="color:sienna;margin-left:20px;">This is a paragraph.</p>
*
* ...the inline style attribute value is: "color:sienna;margin-left:20px;"
*
* If the inline style attribute value above is passed as an argument to this method, the following dictionary will be returned:
*
*     @{
*            @"color" : @"sienna",
*            @"margin-left" : @"20px"
*    };
*
* @param a_styleAttributeValue HTML element's style attribute value;
* @returns Dictionary created based on the key/value pairs from the input parameter.
*/
+ (NSDictionary *)attributesFromStyleAttributeValue:(NSString *)a_styleAttributeValue;


/**
* Creates the inline CSS style attribute from a given dictionary.
* This method does the opposite of the attributesFromStyleAttributeValue: method.
* For instance, if the following dictionary is provided as the input parameter:
*
*     @{
*            @"color" : @"sienna",
*            @"margin-left" : @"20px"
*    };

* ...this inline CSS style attribute value will be returned: "color:sienna;margin-left:20px;"
*
* @param a_attributes Dictionary of key/value CSS attributes.
* @returns Inline CSS style attribute string value created based on the provided dictionary.
*/
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