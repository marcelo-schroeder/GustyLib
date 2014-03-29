//
// Created by Marcelo Schroeder on 27/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTHTMLParser.h"

@class IAHtmlDocumentPosition;
@class IAHtmlElementParsingContext;


typedef void (^HtmlParserEndElementBlock)(IAHtmlElementParsingContext *a_parsingContext);

@interface IAHtmlParser : NSObject <DTHTMLParserDelegate>

@property(nonatomic, strong, readonly) NSMutableString *p_mutableHtmlString;

- (NSString *)m_stringForStartPosition:(IAHtmlDocumentPosition *)a_startPosition
                           endPosition:(IAHtmlDocumentPosition *)a_endPosition;

- (NSString *)m_parseHtmlString:(NSString *)a_htmlString endElementBlock:(HtmlParserEndElementBlock)a_endElementBlock;

- (void)m_replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString;

+ (NSString *)m_markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes;

+ (NSString *)m_markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes
                       shouldClose:(BOOL)a_shouldClose;

+ (void)m_replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString
                 inHtmlString:(NSMutableString *)a_htmlString;

+ (NSDictionary *)m_attributesFromStyleAttributeValue:(NSString *)a_styleAttributeValue;
+ (NSString *)m_styleAttributeValueFromAttributes:(NSDictionary *)a_attributes;

+ (NSString *)m_charactersBetweenOpenAndCloseTagsForStringRepresentation:(NSString *)a_stringRepresentation;
@end

@interface IAHtmlDocumentPosition : NSObject
@property (nonatomic) NSUInteger p_line;
@property (nonatomic) NSUInteger p_column;
- (id)initWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
+ (IAHtmlDocumentPosition *)m_positionWithLine:(NSUInteger)a_line column:(NSUInteger)a_column;
@end

@interface IAHtmlElementParsingMetadata : NSObject
//@property (nonatomic, strong) HtmlDocumentPosition *p_startPosition;
//@property (nonatomic, strong) HtmlDocumentPosition *p_endPosition;
@property (nonatomic, strong) NSString *p_name;
@property (nonatomic, strong) NSString *p_stringRepresentation;
@property (nonatomic, strong) NSDictionary *p_attributes;

- (id)initWithName:(NSString *)a_name stringRepresentation:(NSString *)a_stringRepresentation
        attributes:(NSDictionary *)a_attributes;

- (id)initWithMetadata:(IAHtmlElementParsingMetadata *)a_metadata;

@end

@interface IAHtmlElementParsingContext : NSObject
@property (nonatomic, strong) IAHtmlElementParsingMetadata *p_elementMetadata;
@property (nonatomic, weak) IAHtmlParser *p_parser;

- (id)initWithElementMetadata:(IAHtmlElementParsingMetadata *)a_elementMetadata
                       parser:(IAHtmlParser *)a_parser;
@end

@interface IAHtmlLineParsingMetadata : NSObject
@property (nonatomic) NSUInteger p_lengthBeforeThisLine;
@end