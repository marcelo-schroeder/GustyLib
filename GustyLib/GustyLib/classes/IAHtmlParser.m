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

#import "IAHtmlParser.h"
#import "NSString+IACategory.h"
#import "NSString+HTML.h"

typedef enum{
    HtmlParserEventElementStarted,
    HtmlParserEventElementEnded,
}HtmlParserEvent;

static NSString *const k_lineBreak = @"\n";

//static NSString *const k_tagNameBody = @"body";

static NSString *const k_styleAttributeKeyValuePairSeparator = @";";

static NSString *const k_styleAttributeKeyValueSeparator = @":";

@interface IAHtmlParser ()

// HTML element parsing stack
@property(nonatomic, strong) NSMutableArray *p_elementNameStack;
@property(nonatomic, strong) NSMutableArray *p_elementAttributeDictionaryStack;
@property(nonatomic, strong) NSMutableArray *p_elementStartPositionStack;

@property(nonatomic, strong) NSArray *p_unparsedHtmlStringLines;
@property(nonatomic, strong) NSMutableArray *p_unparsedHtmlStringLinesMetadata;
@property(nonatomic, strong) NSMutableString *p_mutableHtmlString;
//@property(nonatomic) BOOL p_isInBody;
//@property(nonatomic, strong) HtmlDocumentPosition *p_topLevelTagStartPosition;
@property(nonatomic, strong) IAHtmlDocumentPosition *p_currentPosition;
@property(nonatomic, strong) HtmlParserEndElementBlock p_endElementBlock;
@property(nonatomic) HtmlParserEvent p_lastParsingEvent;
@property(nonatomic, strong) NSString *p_unparsedHtmlString;
//@property(nonatomic) NSUInteger p_bodyElementLevel;

@end

@implementation IAHtmlParser {

}

#pragma mark - Private

- (NSMutableArray *)p_elementNameStack {
    if (!_p_elementNameStack) {
        _p_elementNameStack = [@[] mutableCopy];
    }
    return _p_elementNameStack;
}

- (NSMutableArray *)p_elementAttributeDictionaryStack {
    if (!_p_elementAttributeDictionaryStack) {
        _p_elementAttributeDictionaryStack = [@[] mutableCopy];
    }
    return _p_elementAttributeDictionaryStack;
}

- (NSMutableArray *)p_elementStartPositionStack {
    if (!_p_elementStartPositionStack) {
        _p_elementStartPositionStack = [@[] mutableCopy];
    }
    return _p_elementStartPositionStack;
}

- (IAHtmlDocumentPosition *)p_currentPosition {
    if (!_p_currentPosition) {
        _p_currentPosition = [IAHtmlDocumentPosition new];
    }
    return _p_currentPosition;
}

- (NSMutableArray *)p_unparsedHtmlStringLinesMetadata {
    if (!_p_unparsedHtmlStringLinesMetadata) {
        _p_unparsedHtmlStringLinesMetadata = [@[] mutableCopy];
    }
    return _p_unparsedHtmlStringLinesMetadata;
}

#pragma mark - DTHTMLParserDelegate

- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict {

//    if (self.p_isInBody) {
//        self.p_bodyElementLevel++;
//    }
//    if ([elementName isEqualToString:k_tagNameBody]) {
//        self.p_isInBody = YES;
//    }
//    NSLog(@"didStartElement: %@, attributeDict: %@", elementName, [attributeDict description]);
//    NSLog(@"    line: %u, column: %u", parser.lineNumber, parser.columnNumber);

    // Save element name
    [self.p_elementNameStack addObject:elementName];

    // Save element attributes
    NSMutableDictionary *l_attributes = (id) [NSNull null];
    if (attributeDict) {
        l_attributes = [attributeDict mutableCopy];
        for (id l_key in l_attributes.allKeys) {
            NSString *l_value = l_attributes[l_key];
            // Re-encode attribute value for HTML
            l_attributes[l_key] = [l_value stringByEncodingHTMLEntities];
        }
    }
    [self.p_elementAttributeDictionaryStack addObject:l_attributes];

    // Save element start position
    if (self.p_lastParsingEvent==HtmlParserEventElementStarted) {
        self.p_currentPosition.p_column++;
    }
    [self.p_elementStartPositionStack addObject:self.p_currentPosition];

//    if (self.p_bodyElementLevel == 1) {
//        self.p_topLevelTagStartPosition = self.p_currentPosition;
//        self.p_topLevelTagStartPosition.p_column++;
//    }

    // Save element current position
    self.p_currentPosition = [IAHtmlDocumentPosition m_positionWithLine:(NSUInteger) parser.lineNumber
                                                                 column:(NSUInteger) parser.columnNumber];

    // Save last parsing event
    self.p_lastParsingEvent = HtmlParserEventElementStarted;

}

- (void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)elementName {

//    NSLog(@"didEndElement: %@", elementName);
//    NSLog(@"  line: %u, column: %u", parser.lineNumber, parser.columnNumber);

    self.p_currentPosition = [IAHtmlDocumentPosition m_positionWithLine:(NSUInteger) parser.lineNumber
                                                                 column:(NSUInteger) parser.columnNumber];

    NSString *l_elementName = [self.p_elementNameStack lastObject];
    NSAssert([elementName isEqualToString:l_elementName], @"Element names do not match: %@ | %@", elementName, l_elementName);
    [self.p_elementNameStack removeLastObject];

    NSDictionary *l_attributeDict = [self.p_elementAttributeDictionaryStack lastObject];
    l_attributeDict = l_attributeDict == (id)[NSNull null] ? nil : l_attributeDict;
    [self.p_elementAttributeDictionaryStack removeLastObject];

    IAHtmlDocumentPosition *l_startPosition = [self.p_elementStartPositionStack lastObject];
    [self.p_elementStartPositionStack removeLastObject];

    NSString *l_stringRepresentation = [self m_stringForStartPosition:l_startPosition
                                                          endPosition:self.p_currentPosition];

    IAHtmlElementParsingMetadata *l_elementMetadata = [[IAHtmlElementParsingMetadata alloc] initWithName:elementName
                                                                                stringRepresentation:l_stringRepresentation
                                                                                          attributes:l_attributeDict];

//    NSLog(@"  l_stringRepresentation: %@", l_stringRepresentation);
//    NSLog(@"  l_attributeDict: %@", [l_attributeDict description]);

    if (self.p_endElementBlock) {
        IAHtmlElementParsingContext *l_parsingContext = [[IAHtmlElementParsingContext alloc] initWithElementMetadata:l_elementMetadata
                                                                                                          parser:self];
        self.p_endElementBlock(l_parsingContext);
    }

//    if (self.p_isInBody) {
//        self.p_bodyElementLevel--;
//    }

    self.p_lastParsingEvent = HtmlParserEventElementEnded;

}

//- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)string {
//    NSLog(@"    foundCharacters: %@", string);
//    NSLog(@"    line: %u, column: %u", parser.lineNumber, parser.columnNumber);
//}

#pragma mark - Public

- (NSString *)m_parseHtmlString:(NSString *)a_htmlString endElementBlock:(HtmlParserEndElementBlock)a_endElementBlock {

    self.p_unparsedHtmlStringLines = [a_htmlString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger l_accumulatedLength = 0;
    for (int i = 0; i < self.p_unparsedHtmlStringLines.count; i++) {
        NSString *l_line = self.p_unparsedHtmlStringLines[(NSUInteger) i];
        IAHtmlLineParsingMetadata *l_lineMetadata = [IAHtmlLineParsingMetadata new];
        l_lineMetadata.p_lengthBeforeThisLine = l_accumulatedLength;
        [self.p_unparsedHtmlStringLinesMetadata addObject:l_lineMetadata];
        l_accumulatedLength += l_line.length + 1;   // Adds line break character
    }

    self.p_unparsedHtmlString = [self.p_unparsedHtmlStringLines componentsJoinedByString:k_lineBreak];
    self.p_mutableHtmlString = [self.p_unparsedHtmlString mutableCopy];
    self.p_endElementBlock = a_endElementBlock;

    DTHTMLParser *l_htmlParser = [[DTHTMLParser alloc] initWithData:[self.p_unparsedHtmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                           encoding:NSUTF8StringEncoding];
    l_htmlParser.delegate = self;
    [l_htmlParser parse];

    return self.p_mutableHtmlString;

}
- (void)m_replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString {
    [self.class m_replaceMarkupString:a_markupStringToBeReplaced
                     withMarkupString:a_newMarkupString inHtmlString:self.p_mutableHtmlString];
}

- (NSString *)m_stringForStartPosition:(IAHtmlDocumentPosition *)a_startPosition endPosition:(IAHtmlDocumentPosition *)a_endPosition {
//    NSLog(@"m_stringForStartPosition: %@, endPosition: %@", [a_startPosition description], [a_endPosition description]);

    NSUInteger l_startLine = a_startPosition.p_line;
    NSUInteger l_startColumn = a_startPosition.p_column;
    NSUInteger l_endLine = a_endPosition.p_line;
    NSUInteger l_endColumn = a_endPosition.p_column;
    NSUInteger l_startLineIndex;
    if (l_startLine==0 && l_startColumn==1) {   // Is top level element?
        l_startLineIndex = 0;   // Keep index at zero because line is already zero
    }else{
        l_startLineIndex = l_startLine - 1;
    }
    NSUInteger l_endLineIndex = l_endLine - 1;
    IAHtmlLineParsingMetadata *l_startLineMetadata = self.p_unparsedHtmlStringLinesMetadata[l_startLineIndex];
    IAHtmlLineParsingMetadata *l_endLineMetadata = self.p_unparsedHtmlStringLinesMetadata[l_endLineIndex];
    NSUInteger l_location = l_startLineMetadata.p_lengthBeforeThisLine + (l_startColumn - 1);
    NSUInteger l_length = ( l_endLineMetadata.p_lengthBeforeThisLine + (l_endColumn - 1) ) - l_location;

    // Fix line break position mismatch that occurs with tags that are not properly closed (e.g. <p>)
    if ((((NSInteger)l_location) - 2) >= 0) {
        NSRange l_range2 = NSMakeRange(l_location - 2, 1);
        NSString *l_string2 = [self.p_unparsedHtmlString substringWithRange:l_range2];
        if ([l_string2 isEqualToString:@"\n"]) {
            l_location--;
            l_length++;
        }
    }

    // Remove line breaks at the edges
    NSRange l_range = NSMakeRange(l_location, l_length);
    NSString *l_string = [self.p_unparsedHtmlString substringWithRange:l_range];
    if ([[l_string substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"\n"]) {
        l_string = [l_string substringFromIndex:1];
    }
    if ([[l_string substringWithRange:NSMakeRange(l_string.length - 1, 1)] isEqualToString:@"\n"]) {
        l_string = [l_string substringToIndex:l_string.length - 1];
    }

    // Remove any characters before the opening tag
    NSRange l_openTagRange = [l_string rangeOfString:@"<"];
    if (l_openTagRange.location!=NSNotFound) {
        l_string = [l_string substringFromIndex:l_openTagRange.location];
    }

//    NSLog(@"  l_range: %@", NSStringFromRange(l_range));
//    NSLog(@"  string from range: |%@|", l_string)

    return l_string;
}

+ (NSString *)m_markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes {
    return [self m_markupStringForTag:a_tagName attributes:a_attributes shouldClose:YES];
}

+ (NSString *)m_markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes shouldClose:(BOOL)a_shouldClose {
    NSMutableString *l_markupString = [NSMutableString stringWithString:@"<"];
    [l_markupString appendString:a_tagName];
    for (NSString *l_key in a_attributes.allKeys) {
        @autoreleasepool {
            NSString *l_value = a_attributes[l_key];
            if (l_value) {
                if ([l_value isEqualToString:l_key]) {
                    [l_markupString appendFormat:@" %@", l_value];
                }else{
                    [l_markupString appendFormat:@" %@=\"%@\"", l_key, l_value];
                }
            }
        }
    }
    NSString *l_closingMarkup = a_shouldClose ? [NSString stringWithFormat:@"></%@>", a_tagName] : @">";
    [l_markupString appendString:l_closingMarkup];
    return l_markupString;
}

+ (void)m_replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString inHtmlString:(NSMutableString *)a_htmlString {
//    NSLog(@"m_replaceMarkupString");
//    NSLog(@"  a_markupStringToBeReplaced: %@", a_markupStringToBeReplaced);
//    NSLog(@"  a_newMarkupString: %@", a_newMarkupString);
    NSRange l_rangeToBeReplaced = [a_htmlString rangeOfString:a_markupStringToBeReplaced];
    if (l_rangeToBeReplaced.location!=NSNotFound) {
        [a_htmlString replaceCharactersInRange:l_rangeToBeReplaced withString:a_newMarkupString];
    }
}

+ (NSDictionary *)m_attributesFromStyleAttributeValue:(NSString *)a_styleAttributeValue {
    NSMutableDictionary *l_attributes = [@{} mutableCopy];
    NSArray *l_keyValuePairStrings = [a_styleAttributeValue componentsSeparatedByString:k_styleAttributeKeyValuePairSeparator];
    for (NSString *l_keyValuePairString in l_keyValuePairStrings) {
        NSArray *l_keyAndValue = [l_keyValuePairString componentsSeparatedByString:k_styleAttributeKeyValueSeparator];
        if (l_keyAndValue.count==2) {
            NSString *l_key = [l_keyAndValue[0] m_stringByTrimming];
            NSString *l_value = [l_keyAndValue[1] m_stringByTrimming];
            l_attributes[l_key] = l_value;
        }
    }
    return l_attributes;
}

+ (NSString *)m_styleAttributeValueFromAttributes:(NSDictionary *)a_attributes {
    NSMutableArray *l_keyValuePairStrings = [@[] mutableCopy];
    NSArray *l_keys = [a_attributes.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *l_key in l_keys) {
        NSObject *l_value = a_attributes[l_key];
        NSString *l_keyValuePairString = [NSString stringWithFormat:@"%@: %@", l_key, l_value];
        [l_keyValuePairStrings addObject:l_keyValuePairString];
    }
    NSString *l_stringToJoinBy = [NSString stringWithFormat:@"%@ ", k_styleAttributeKeyValuePairSeparator];
    NSString *l_styleAttributeValue = [l_keyValuePairStrings componentsJoinedByString:l_stringToJoinBy];
    if (l_keyValuePairStrings.count) {
        l_styleAttributeValue = [l_styleAttributeValue stringByAppendingString:k_styleAttributeKeyValuePairSeparator];
    }
    return l_styleAttributeValue;
}

+ (NSString *)m_charactersBetweenOpenAndCloseTagsForStringRepresentation:(NSString *)a_stringRepresentation{
    NSRange l_openTagEndRange = [a_stringRepresentation rangeOfString:@">"];
    NSRange l_closeTagStartRange = [a_stringRepresentation rangeOfString:@"<"
                                                                 options:NSBackwardsSearch];
    if (l_openTagEndRange.location!=NSNotFound && l_closeTagStartRange.location!=NSNotFound) {
        NSUInteger l_rangeLocation = l_openTagEndRange.location + 1;
        NSUInteger l_rangeLength = l_closeTagStartRange.location - l_rangeLocation;
        NSRange l_range = NSMakeRange(l_rangeLocation, l_rangeLength);
        return [a_stringRepresentation substringWithRange:l_range];
    }else{
        return nil;
    }
}

@end

@implementation IAHtmlDocumentPosition

#pragma mark - Public

- (id)initWithLine:(NSUInteger)a_line column:(NSUInteger)a_column {
    self = [super init];
    if (self) {
        self.p_line = a_line;
        self.p_column = a_column;
    }
    return self;
}

+ (IAHtmlDocumentPosition *)m_positionWithLine:(NSUInteger)a_line column:(NSUInteger)a_column {
    return [[self alloc] initWithLine:a_line column:a_column];
}

#pragma mark - Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"line: %u, column: %u", self.p_line, self.p_column];
}

@end

@implementation IAHtmlElementParsingMetadata

#pragma mark - Public

- (id)initWithName:(NSString *)a_name stringRepresentation:(NSString *)a_stringRepresentation
        attributes:(NSDictionary *)a_attributes {
    self = [super init];
    if (self) {
        self.p_name = a_name;
        self.p_stringRepresentation = a_stringRepresentation;
        self.p_attributes = a_attributes;
    }
    return self;
}

- (id)initWithMetadata:(IAHtmlElementParsingMetadata *)a_metadata{
    return [self initWithName:a_metadata.p_name stringRepresentation:a_metadata.p_stringRepresentation
                   attributes:a_metadata.p_attributes];
}

@end

@implementation IAHtmlElementParsingContext

#pragma mark - Public

- (id)initWithElementMetadata:(IAHtmlElementParsingMetadata *)a_elementMetadata parser:(IAHtmlParser *)a_parser {
    self = [super init];
    if (self) {
        self.p_elementMetadata = a_elementMetadata;
        self.p_parser = a_parser;
    }
    return self;
}

@end

@implementation IAHtmlLineParsingMetadata
@end