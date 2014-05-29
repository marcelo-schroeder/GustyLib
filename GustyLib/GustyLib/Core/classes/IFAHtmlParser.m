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

#import "NSString+IFACategory.h"
#import "NSString+HTML.h"
#import "IFAHtmlParser.h"

typedef enum{
    IFAHtmlParserEventElementStarted,
    IFAHtmlParserEventElementEnded,
} IFAHtmlParserEvent;

static NSString *const k_lineBreak = @"\n";

//static NSString *const k_tagNameBody = @"body";

static NSString *const k_styleAttributeKeyValuePairSeparator = @";";
static NSString *const k_styleAttributeKeyValueSeparator = @":";

static NSString *const k_tagAttributeStyle = @"style";

@interface IFAHtmlParser ()

// HTML element parsing stack
@property(nonatomic, strong) NSMutableArray *elementMetadataStack;
@property (nonatomic, strong) NSMutableArray *IFA_elementStyleAttributesStack;

@property(nonatomic, strong) NSArray *IFA_unparsedHtmlStringLines;
@property(nonatomic, strong) NSMutableArray *IFA_unparsedHtmlStringLinesMetadata;
@property(nonatomic, strong) NSMutableString *mutableHtmlString;
//@property(nonatomic) BOOL IFA_isInBody;
//@property(nonatomic, strong) HtmlDocumentPosition *IFA_topLevelTagStartPosition;
@property(nonatomic, strong) IFAHtmlDocumentPosition *IFA_currentPosition;
@property(nonatomic, strong) IFAHtmlParserEndElementBlock IFA_endElementBlock;
@property(nonatomic) IFAHtmlParserEvent IFA_lastParsingEvent;
@property(nonatomic, strong) NSString *IFA_unparsedHtmlString;
//@property(nonatomic) NSUInteger IFA_bodyElementLevel;

@end

@implementation IFAHtmlParser {

}

#pragma mark - Private

- (NSMutableArray *)IFA_elementStyleAttributesStack {
    if (!_IFA_elementStyleAttributesStack) {
        _IFA_elementStyleAttributesStack = [@[] mutableCopy];
    }
    return _IFA_elementStyleAttributesStack;
}

- (IFAHtmlDocumentPosition *)IFA_currentPosition {
    if (!_IFA_currentPosition) {
        _IFA_currentPosition = [IFAHtmlDocumentPosition new];
    }
    return _IFA_currentPosition;
}

- (NSMutableArray *)IFA_unparsedHtmlStringLinesMetadata {
    if (!_IFA_unparsedHtmlStringLinesMetadata) {
        _IFA_unparsedHtmlStringLinesMetadata = [@[] mutableCopy];
    }
    return _IFA_unparsedHtmlStringLinesMetadata;
}

- (void)IFA_pushElementMetadataStackWith:(NSString *)a_elementName attributes:(NSDictionary *)a_attributes {

    // Prepare element attributes for saving
    NSMutableDictionary *l_attributes = nil;
    if (a_attributes) {
        l_attributes = [a_attributes mutableCopy];
        for (id l_key in l_attributes.allKeys) {
            NSString *l_value = l_attributes[l_key];
            // Re-encode attribute value for HTML
            l_attributes[l_key] = [l_value stringByEncodingHTMLEntities];
        }
    }

    // Prepare element start position for saving
    if (self.IFA_lastParsingEvent == IFAHtmlParserEventElementStarted) {
        self.IFA_currentPosition.column++;
    }

    // Save element parsing metadata
    IFAHtmlElementParsingMetadata *l_elementMetadata = [[IFAHtmlElementParsingMetadata alloc] initWithName:a_elementName
                                                                                          attributes:l_attributes
                                                                                       startPosition:self.IFA_currentPosition];
    [self.elementMetadataStack addObject:l_elementMetadata];
    [self.IFA_elementStyleAttributesStack addObject:[self.class attributesFromStyleAttributeValue:l_attributes[k_tagAttributeStyle]]];

}

#pragma mark - DTHTMLParserDelegate

- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict {

//    if (self.IFA_isInBody) {
//        self.IFA_bodyElementLevel++;
//    }
//    if ([elementName isEqualToString:k_tagNameBody]) {
//        self.IFA_isInBody = YES;
//    }
//    NSLog(@"didStartElement: %@, attributeDict: %@", elementName, [attributeDict description]);
//    NSLog(@"    line: %u, column: %u", parser.lineNumber, parser.columnNumber);

    [self IFA_pushElementMetadataStackWith:elementName attributes:attributeDict];

//    if (self.IFA_bodyElementLevel == 1) {
//        self.IFA_topLevelTagStartPosition = self.IFA_currentPosition;
//        self.IFA_topLevelTagStartPosition.column++;
//    }

    // Save element current position
    self.IFA_currentPosition = [IFAHtmlDocumentPosition positionWithLine:(NSUInteger) parser.lineNumber
                                                               column:(NSUInteger) parser.columnNumber];

    // Save last parsing event
    self.IFA_lastParsingEvent = IFAHtmlParserEventElementStarted;

}

- (void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)elementName {

//    NSLog(@"didEndElement: %@", elementName);
//    NSLog(@"  line: %u, column: %u", parser.lineNumber, parser.columnNumber);

    self.IFA_currentPosition = [IFAHtmlDocumentPosition positionWithLine:(NSUInteger) parser.lineNumber
                                                               column:(NSUInteger) parser.columnNumber];

    IFAHtmlElementParsingMetadata *l_elementMetadata = [self.elementMetadataStack lastObject];
    NSAssert([elementName isEqualToString:l_elementMetadata.name], @"Element names do not match: %@ | %@", elementName, l_elementMetadata.name);
    [self.elementMetadataStack removeLastObject];

    // Set the missing properties in the element metadata
    l_elementMetadata.endPosition = self.IFA_currentPosition;
    l_elementMetadata.stringRepresentation = [self stringForStartPosition:l_elementMetadata.startPosition
                                                              endPosition:l_elementMetadata.endPosition];

//    NSLog(@"  l_stringRepresentation: %@", l_stringRepresentation);
//    NSLog(@"  l_attributeDict: %@", [l_attributeDict description]);

    if (self.IFA_endElementBlock) {
        IFAHtmlElementParsingContext *l_parsingContext = [[IFAHtmlElementParsingContext alloc] initWithElementMetadata:l_elementMetadata
                                                                                                          parser:self];
        self.IFA_endElementBlock(l_parsingContext);
    }

    [self.IFA_elementStyleAttributesStack removeLastObject];

//    if (self.IFA_isInBody) {
//        self.IFA_bodyElementLevel--;
//    }

    self.IFA_lastParsingEvent = IFAHtmlParserEventElementEnded;

}

//- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)string {
//    NSLog(@"    foundCharacters: %@", string);
//    NSLog(@"    line: %u, column: %u", parser.lineNumber, parser.columnNumber);
//}

#pragma mark - Public

- (NSString *)parseHtmlString:(NSString *)a_htmlString endElementBlock:(IFAHtmlParserEndElementBlock)a_endElementBlock {

    self.IFA_unparsedHtmlStringLines = [a_htmlString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSUInteger l_accumulatedLength = 0;
    for (int i = 0; i < self.IFA_unparsedHtmlStringLines.count; i++) {
        NSString *l_line = self.IFA_unparsedHtmlStringLines[(NSUInteger) i];
        IFAHtmlLineParsingMetadata *l_lineMetadata = [IFAHtmlLineParsingMetadata new];
        l_lineMetadata.lengthBeforeThisLine = l_accumulatedLength;
        [self.IFA_unparsedHtmlStringLinesMetadata addObject:l_lineMetadata];
        l_accumulatedLength += l_line.length + 1;   // Adds line break character
    }

    self.IFA_unparsedHtmlString = [self.IFA_unparsedHtmlStringLines componentsJoinedByString:k_lineBreak];
    self.mutableHtmlString = [self.IFA_unparsedHtmlString mutableCopy];
    self.IFA_endElementBlock = a_endElementBlock;

    DTHTMLParser *l_htmlParser = [[DTHTMLParser alloc] initWithData:[self.IFA_unparsedHtmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                           encoding:NSUTF8StringEncoding];
    l_htmlParser.delegate = self;
    [l_htmlParser parse];

    return self.mutableHtmlString;

}

- (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString {
    [self.class replaceMarkupString:a_markupStringToBeReplaced
                   withMarkupString:a_newMarkupString inHtmlString:self.mutableHtmlString];
}

- (NSDictionary *)activeInlineStyleAttributes {
    NSMutableDictionary *l_combinedAttributes = [@{} mutableCopy];
    [self.IFA_elementStyleAttributesStack enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [l_combinedAttributes addEntriesFromDictionary:obj];
    }];
    return l_combinedAttributes;
}

- (NSString *)stringForStartPosition:(IFAHtmlDocumentPosition *)a_startPosition endPosition:(IFAHtmlDocumentPosition *)a_endPosition {
//    NSLog(@"m_stringForStartPosition: %@, endPosition: %@", [a_startPosition description], [a_endPosition description]);

    NSUInteger l_startLine = a_startPosition.line;
    NSUInteger l_startColumn = a_startPosition.column;
    NSUInteger l_endLine = a_endPosition.line;
    NSUInteger l_endColumn = a_endPosition.column;
    NSUInteger l_startLineIndex;
    if (l_startLine==0 && l_startColumn==1) {   // Is top level element?
        l_startLineIndex = 0;   // Keep index at zero because line is already zero
    }else{
        l_startLineIndex = l_startLine - 1;
    }
    NSUInteger l_endLineIndex = l_endLine - 1;
    IFAHtmlLineParsingMetadata *l_startLineMetadata = self.IFA_unparsedHtmlStringLinesMetadata[l_startLineIndex];
    IFAHtmlLineParsingMetadata *l_endLineMetadata = self.IFA_unparsedHtmlStringLinesMetadata[l_endLineIndex];
    NSUInteger l_location = l_startLineMetadata.lengthBeforeThisLine + (l_startColumn - 1);
    NSUInteger l_length = ( l_endLineMetadata.lengthBeforeThisLine + (l_endColumn - 1) ) - l_location;

    // Fix line break position mismatch that occurs with tags that are not properly closed (e.g. <p>)
    if ((((NSInteger)l_location) - 2) >= 0) {
        NSRange l_range2 = NSMakeRange(l_location - 2, 1);
        NSString *l_string2 = [self.IFA_unparsedHtmlString substringWithRange:l_range2];
        if ([l_string2 isEqualToString:@"\n"]) {
            l_location--;
            l_length++;
        }
    }

    // Remove line breaks at the edges
    NSRange l_range = NSMakeRange(l_location, l_length);
    NSString *l_string = [self.IFA_unparsedHtmlString substringWithRange:l_range];
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

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes {
    return [self markupStringForTag:a_tagName attributes:a_attributes shouldClose:YES];
}

+ (NSString *)markupStringForTag:(NSString *)a_tagName attributes:(NSDictionary *)a_attributes shouldClose:(BOOL)a_shouldClose {
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

+ (void)replaceMarkupString:(NSString *)a_markupStringToBeReplaced withMarkupString:(NSString *)a_newMarkupString
               inHtmlString:(NSMutableString *)a_htmlString {
//    NSLog(@"m_replaceMarkupString");
//    NSLog(@"  a_markupStringToBeReplaced: %@", a_markupStringToBeReplaced);
//    NSLog(@"  a_newMarkupString: %@", a_newMarkupString);
    NSRange l_rangeToBeReplaced = [a_htmlString rangeOfString:a_markupStringToBeReplaced];
    if (l_rangeToBeReplaced.location!=NSNotFound) {
        [a_htmlString replaceCharactersInRange:l_rangeToBeReplaced withString:a_newMarkupString];
    }
}

+ (NSDictionary *)attributesFromStyleAttributeValue:(NSString *)a_styleAttributeValue {
    NSMutableDictionary *l_attributes = [@{} mutableCopy];
    NSArray *l_keyValuePairStrings = [a_styleAttributeValue componentsSeparatedByString:k_styleAttributeKeyValuePairSeparator];
    for (NSString *l_keyValuePairString in l_keyValuePairStrings) {
        NSArray *l_keyAndValue = [l_keyValuePairString componentsSeparatedByString:k_styleAttributeKeyValueSeparator];
        if (l_keyAndValue.count==2) {
            NSString *l_key = [l_keyAndValue[0] ifa_stringByTrimming];
            NSString *l_value = [l_keyAndValue[1] ifa_stringByTrimming];
            l_attributes[l_key] = l_value;
        }
    }
    return l_attributes;
}

+ (NSString *)styleAttributeValueFromAttributes:(NSDictionary *)a_attributes {
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

- (NSMutableArray *)elementMetadataStack {
    if (!_elementMetadataStack) {
        _elementMetadataStack = [@[] mutableCopy];
    }
    return _elementMetadataStack;
}

+ (NSString *)charactersBetweenOpenAndCloseTagsForStringRepresentation:(NSString *)a_stringRepresentation{
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

+ (NSString *)firstOpeningTagForStringRepresentation:(NSString *)a_stringRepresentation {
    NSString *l_stringRepresentation = [self.class removeCommentsFromStringRepresentation:a_stringRepresentation];
    NSRange l_openingTagEndRange = [l_stringRepresentation rangeOfString:@">"];
    NSUInteger l_openingTagEndIndex = l_openingTagEndRange.location + l_openingTagEndRange.length;
    NSString *l_markupStringToBeReplaced = [l_stringRepresentation substringToIndex:l_openingTagEndIndex];
    return l_markupStringToBeReplaced;
}

+ (NSString *)removeCommentsFromStringRepresentation:(NSString *)a_stringRepresentation {
    NSMutableString *l_stringRepresentation = [a_stringRepresentation mutableCopy];
    while (YES) {
        @autoreleasepool {
            NSRange l_commentStartRange = [l_stringRepresentation rangeOfString:@"<!--"];
            NSRange l_commentEndRange = [l_stringRepresentation rangeOfString:@"-->"];
            if (l_commentStartRange.location!=NSNotFound && l_commentEndRange.location!=NSNotFound) {
                NSRange l_commentRange = NSUnionRange(l_commentStartRange, l_commentEndRange);
                [l_stringRepresentation replaceCharactersInRange:l_commentRange withString:@""];
            }else{
                break;
            }
        }
    }
    return l_stringRepresentation;
}

+ (BOOL)isElementClosedForStringRepresentation:(NSString *)a_stringRepresentation {
    NSString *l_stringRepresentation = [a_stringRepresentation stringByReplacingOccurrencesOfString:@" "
                                                                                         withString:@""];   // Remove spaces
    return [l_stringRepresentation rangeOfString:@"</"].location!=NSNotFound || [l_stringRepresentation rangeOfString:@"/>"].location!=NSNotFound;
}

@end

@implementation IFAHtmlDocumentPosition

#pragma mark - Public

- (id)initWithLine:(NSUInteger)a_line column:(NSUInteger)a_column {
    self = [super init];
    if (self) {
        self.line = a_line;
        self.column = a_column;
    }
    return self;
}

+ (IFAHtmlDocumentPosition *)positionWithLine:(NSUInteger)a_line column:(NSUInteger)a_column {
    return [[self alloc] initWithLine:a_line column:a_column];
}

#pragma mark - Overrides

- (NSString *)description {
    return [NSString stringWithFormat:@"line: %u, column: %u", self.line, self.column];
}

@end

@implementation IFAHtmlElementParsingMetadata

#pragma mark - Public

- (id)initWithName:(NSString *)a_name attributes:(NSDictionary *)a_attributes startPosition:(IFAHtmlDocumentPosition *)a_startPosition {
    self = [super init];
    if (self) {
        self.name = a_name;
        self.attributes = a_attributes;
        self.startPosition = a_startPosition;
    }
    return self;
}

- (id)initWithMetadata:(IFAHtmlElementParsingMetadata *)a_metadata{
    IFAHtmlElementParsingMetadata *l_obj = [IFAHtmlElementParsingMetadata new];
    l_obj.name = a_metadata.name;
    l_obj.stringRepresentation = a_metadata.stringRepresentation;
    l_obj.attributes = a_metadata.attributes;
    l_obj.startPosition = a_metadata.startPosition;
    l_obj.endPosition = a_metadata.endPosition;
    return l_obj;
}

@end

@implementation IFAHtmlElementParsingContext

#pragma mark - Public

- (id)initWithElementMetadata:(IFAHtmlElementParsingMetadata *)a_elementMetadata parser:(IFAHtmlParser *)a_parser {
    self = [super init];
    if (self) {
        self.elementMetadata = a_elementMetadata;
        self.parser = a_parser;
    }
    return self;
}

@end

@implementation IFAHtmlLineParsingMetadata
@end