//
//  Gusty - IAHtmlParserTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IACommonTests.h"
#import "IAHtmlParser.h"

typedef void (^HtmlParserTestsElementBlock)(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes);

@interface HtmlParserTests : XCTestCase
@end

@implementation HtmlParserTests {
}

- (void)testSimpleHtmlParsing {
    HtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes) {
        switch (a_index) {
            case 0:
                assertThat(a_name, is(equalTo(@"title")));
                assertThat(a_stringRepresentation, is(equalTo(@"<TITLE>Your Title Here</TITLE>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 1:
                assertThat(a_name, is(equalTo(@"head")));
                assertThat(a_stringRepresentation, is(equalTo(@"<HEAD>\n    <TITLE>Your Title Here</TITLE>\n</HEAD>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 2:
                assertThat(a_name, is(equalTo(@"img")));
                assertThat(a_stringRepresentation, is(equalTo(@"<IMG SRC=\"clouds.jpg\" ALIGN=\"BOTTOM\">")));
                assertThat(a_attributes, is(equalTo(@{@"src" : @"clouds.jpg", @"align" : @"BOTTOM"})));
                break;
            case 3:
                assertThat(a_name, is(equalTo(@"center")));
                assertThat(a_stringRepresentation, is(equalTo(@"<CENTER><IMG SRC=\"clouds.jpg\" ALIGN=\"BOTTOM\"> </CENTER>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 4:
                assertThat(a_name, is(equalTo(@"hr")));
                assertThat(a_stringRepresentation, is(equalTo(@"<HR>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 5:
                assertThat(a_name, is(equalTo(@"a")));
                assertThat(a_stringRepresentation, is(equalTo(@"<a href=\"http://somegreatsite.com\">Link Name</a>")));
                assertThat(a_attributes, is(equalTo(@{@"href" : @"http://somegreatsite.com"})));
                break;
            case 6:
                assertThat(a_name, is(equalTo(@"h1")));
                assertThat(a_stringRepresentation, is(equalTo(@"<H1>This is a Header</H1>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 7:
                assertThat(a_name, is(equalTo(@"h2")));
                assertThat(a_stringRepresentation, is(equalTo(@"<H2>This is a Medium Header</H2>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 8:
                assertThat(a_name, is(equalTo(@"a")));
                assertThat(a_stringRepresentation, is(equalTo(@"<a href=\"mailto:support@yourcompany.com\">\n    support@yourcompany.com</a>")));
                assertThat(a_attributes, is(equalTo(@{@"href" : @"mailto:support@yourcompany.com"})));
                break;
            case 9:
                assertThat(a_name, is(equalTo(@"p")));
                assertThat(a_stringRepresentation, is(equalTo(@"<P> This is a new paragraph!")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 10:
                assertThat(a_name, is(equalTo(@"b")));
                assertThat(a_stringRepresentation, is(equalTo(@"<B>This is a new paragraph!</B>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 11:
                assertThat(a_name, is(equalTo(@"br")));
                assertThat(a_stringRepresentation, is(equalTo(@"<BR>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 12:
                assertThat(a_name, is(equalTo(@"i")));
                assertThat(a_stringRepresentation, is(equalTo(@"<I>This is a new sentence without a paragraph break, in bold italics.</I>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 13:
                assertThat(a_name, is(equalTo(@"b")));
                assertThat(a_stringRepresentation, is(equalTo(@"<B><I>This is a new sentence without a paragraph break, in bold italics.</I></B>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 14:
                assertThat(a_name, is(equalTo(@"p")));
                assertThat(a_stringRepresentation, is(equalTo(@"<P> <B>This is a new paragraph!</B>\n    <BR> <B><I>This is a new sentence without a paragraph break, in bold italics.</I></B>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 15:
                assertThat(a_name, is(equalTo(@"hr")));
                assertThat(a_stringRepresentation, is(equalTo(@"<HR>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 16:
                assertThat(a_name, is(equalTo(@"p")));
                assertThat(a_stringRepresentation, is(equalTo(@"<P>hello in div1</P>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 17:
                assertThat(a_name, is(equalTo(@"div")));
                assertThat(a_stringRepresentation, is(equalTo(@"<DIV>\n    <P>hello in div1</P>\n</DIV>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 18:
                assertThat(a_name, is(equalTo(@"p")));
                assertThat(a_stringRepresentation, is(equalTo(@"<P>hello in div2</P>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 19:
                assertThat(a_name, is(equalTo(@"div")));
                assertThat(a_stringRepresentation, is(equalTo(@"<DIV><P>hello in div2</P></DIV>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 20:
                assertThat(a_name, is(equalTo(@"p")));
                assertThat(a_stringRepresentation, is(equalTo(@"<P>hello in div2</P>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 21:
                assertThat(a_name, is(equalTo(@"div")));
                assertThat(a_stringRepresentation, is(equalTo(@"<DIV>  <P>hello in div2</P>   </DIV>")));
                assertThat(a_attributes, is(nilValue()));
                break;
            case 22:
                assertThat(a_name, is(equalTo(@"body")));
                assertThat(a_attributes, is(equalTo(@{@"bgcolor" : @"FFFFFF"})));
                break;
            case 23:
                assertThat(a_name, is(equalTo(@"html")));
                assertThat(a_attributes, is(nilValue()));
                break;
            default:
                break;
        }
    };
    [self m_parseHtmlFileNamed:@"HtmlParser_testdata1" withElementBlock:l_elementBlock];
}

- (void)testComplexHtmlParsing{
    __block BOOL l_hasTestStarted = NO;
    __block NSUInteger l_firstIndex = 0;
    HtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes) {
        if ([a_name isEqualToString:@"param"] && !l_hasTestStarted){
            l_hasTestStarted = YES;
            l_firstIndex = a_index;
        }
        if (l_hasTestStarted) {
            if (a_index==l_firstIndex+0) {
                assertThat(a_name, is(equalTo(@"param")));
                assertThat(a_stringRepresentation, is(equalTo(@"<param name=\"allowFullScreen\" value=\"true\" />")));
                assertThat(a_attributes, is(equalTo(@{@"name":@"allowFullScreen", @"value":@"true"})));
            } else
            if (a_index==l_firstIndex+1) {
                assertThat(a_name, is(equalTo(@"param")));
                assertThat(a_stringRepresentation, is(equalTo(@"<param name=\"allowscriptaccess\" value=\"always\" />")));
                assertThat(a_attributes, is(equalTo(@{@"name":@"allowscriptaccess", @"value":@"always"})));
            }
        }
    };
    [self m_parseHtmlFileNamed:@"HtmlParser_testdata2" withElementBlock:l_elementBlock];
}

- (void)testAttributesFromStyleAttributeValue {
    // given
    NSString *l_styleAttributeValue = @"key1:value1;key2 : value2; key3: value3;key4 :value4;";
    // when
    NSDictionary *l_actualAttributes = [IAHtmlParser m_attributesFromStyleAttributeValue:l_styleAttributeValue];
    // then
    NSDictionary *l_expectedAttributes = @{
            @"key1" : @"value1",
            @"key2" : @"value2",
            @"key3" : @"value3",
            @"key4" : @"value4",
    };
    assertThat(l_actualAttributes, is(equalTo(l_expectedAttributes)));
}

- (void)testStyleAttributeValueFromAttributes{
    // given
    NSDictionary *l_attributes = @{
            @"key1" : @"value1",
            @"key2" : @"value2",
            @"key3" : @"value3",
            @"key4" : @"value4",
    };
    // when
    NSString *l_actualStyleAttributeValue = [IAHtmlParser m_styleAttributeValueFromAttributes:l_attributes];
    // then
    NSString *l_expectedStyleAttributeValue = @"key1: value1; key2: value2; key3: value3; key4: value4;";
    assertThat(l_actualStyleAttributeValue, is(equalTo(l_expectedStyleAttributeValue)));
}

- (void)testThatCharactersBetweenOpenAndCloseTagsForStringRepresentationAreCorrectForAValidInput {
    // given
    NSString *l_stringRepresentation = @"<tag>value</tag>";
    // when
    NSString *l_actualValue = [IAHtmlParser m_charactersBetweenOpenAndCloseTagsForStringRepresentation:l_stringRepresentation];
    // then
    assertThat(l_actualValue, is(equalTo(@"value")));
}

- (void)testThatCharactersBetweenOpenAndCloseTagsForStringRepresentationAreCorrectForAnInvalidInput {
    // given
    NSString *l_stringRepresentation = @"abc";
    // when
    NSString *l_actualValue = [IAHtmlParser m_charactersBetweenOpenAndCloseTagsForStringRepresentation:l_stringRepresentation];
    // then
    assertThat(l_actualValue, is(nilValue()));
}

#pragma mark - Private

- (void)m_parseHtmlFileNamed:(NSString *)a_htmlFileName
            withElementBlock:(HtmlParserTestsElementBlock)a_elementBlock {

    NSString *l_htmlOriginalFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:a_htmlFileName
                                                                                        ofType:@"html"];
    NSString *l_htmlOriginal = [[NSString alloc] initWithContentsOfFile:l_htmlOriginalFilePath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];

    NSMutableArray *l_elementNames = [@[] mutableCopy];
    NSMutableArray *l_elementStringRepresentations = [@[] mutableCopy];
    NSMutableArray *l_elementAttributes = [@[] mutableCopy];

    IAHtmlParser *l_htmlParser = [IAHtmlParser new];
    void (^l_endElementBlock)(IAHtmlElementParsingContext *) =
            ^(IAHtmlElementParsingContext *a_parsingContext) {
                IAHtmlElementParsingMetadata *l_elementMetadata = a_parsingContext.p_elementMetadata;
                NSString *l_name = l_elementMetadata.p_name;
                NSDictionary *l_attributes = l_elementMetadata.p_attributes;
                NSString *l_stringRepresentation = l_elementMetadata.p_stringRepresentation;
                NSLog(@"l_name: %@, l_attributes: %@, string: %@", l_name, [l_attributes description], l_stringRepresentation);
                [l_elementNames addObject:l_name];
                [l_elementStringRepresentations addObject:l_stringRepresentation];
                [l_elementAttributes addObject:l_attributes ? l_attributes : [NSNull null]];
            };
    [l_htmlParser m_parseHtmlString:l_htmlOriginal
                    endElementBlock:l_endElementBlock];

    for (NSUInteger i = 0; i < l_elementNames.count; i++) {
        NSString *l_name = l_elementNames[i];
        NSString *l_stringRepresentation = l_elementStringRepresentations[i];
        NSDictionary *l_attributes = l_elementAttributes[i];
        if (l_attributes == (id) [NSNull null]) {
            l_attributes = nil;
        }
        a_elementBlock(i, l_name, l_stringRepresentation, l_attributes);
    }

}

@end
