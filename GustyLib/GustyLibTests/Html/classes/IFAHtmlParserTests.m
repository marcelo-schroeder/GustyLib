//
//  Gusty - IFAHtmlParserTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
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

#import "IFACommonTests.h"
#import "GustyLib.h"
#import "GustyLibHtml.h"

typedef void (^IFAHtmlParserTestsElementBlock)(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes);

@interface IFAHtmlParserTests : XCTestCase
@property(nonatomic, strong) IFAHtmlParser *p_htmlParser;
@end

@implementation IFAHtmlParserTests {
}

- (void)setUp {
    [super setUp];
    self.p_htmlParser = [IFAHtmlParser new];
}

- (void)testSimpleHtmlParsing {
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
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
    [self parseHtmlFileNamed:@"HtmlParser_testdata1" withElementBlock:l_elementBlock];
}

- (void)testComplexHtmlParsing{
    __block BOOL l_hasTestStarted = NO;
    __block NSUInteger l_firstIndex = 0;
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
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
    [self parseHtmlFileNamed:@"HtmlParser_testdata2" withElementBlock:l_elementBlock];
}

- (void)testAttributesFromStyleAttributeValue {
    // given
    NSString *l_styleAttributeValue = @"key1:value1;key2 : value2; key3: value3;key4 :value4;";
    // when
    NSDictionary *l_actualAttributes = [IFAHtmlParser attributesFromStyleAttributeValue:l_styleAttributeValue];
    // then
    NSDictionary *l_expectedAttributes = @{
            @"key1" : @"value1",
            @"key2" : @"value2",
            @"key3" : @"value3",
            @"key4" : @"value4",
    };
    assertThat(l_actualAttributes, is(equalTo(l_expectedAttributes)));
}

- (void)testAttributesFromNilStyleAttributeValue {
    // when
    NSDictionary *l_actualAttributes = [IFAHtmlParser attributesFromStyleAttributeValue:nil];
    // then
    NSDictionary *l_expectedAttributes = @{};
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
    NSString *l_actualStyleAttributeValue = [IFAHtmlParser styleAttributeValueFromAttributes:l_attributes];
    // then
    NSString *l_expectedStyleAttributeValue = @"key1: value1; key2: value2; key3: value3; key4: value4;";
    assertThat(l_actualStyleAttributeValue, is(equalTo(l_expectedStyleAttributeValue)));
}

- (void)testStyleAttributeValueFromEmptyAttributes{
    // given
    NSDictionary *l_attributes = @{};
    // when
    NSString *l_actualStyleAttributeValue = [IFAHtmlParser styleAttributeValueFromAttributes:l_attributes];
    // then
    NSString *l_expectedStyleAttributeValue = @"";
    assertThat(l_actualStyleAttributeValue, is(equalTo(l_expectedStyleAttributeValue)));
}

- (void)testThatCharactersBetweenOpenAndCloseTagsForStringRepresentationAreCorrectForAValidInput {
    // given
    NSString *l_stringRepresentation = @"<tag>value</tag>";
    // when
    NSString *l_actualValue = [IFAHtmlParser charactersBetweenOpenAndCloseTagsForStringRepresentation:l_stringRepresentation];
    // then
    assertThat(l_actualValue, is(equalTo(@"value")));
}

- (void)testThatCharactersBetweenOpenAndCloseTagsForStringRepresentationAreCorrectForAnInvalidInput {
    // given
    NSString *l_stringRepresentation = @"abc";
    // when
    NSString *l_actualValue = [IFAHtmlParser charactersBetweenOpenAndCloseTagsForStringRepresentation:l_stringRepresentation];
    // then
    assertThat(l_actualValue, is(nilValue()));
}

- (void)testFirstOpeningTagForStringRepresentationWithOpenTag{
    // given
    NSString *l_htmlString = @"<div style=\"float:left; padding: 10px;\"> <a href=\"http://www.rmit.edu.au/\" target=\"_blank\"><img src=\"http://www.brazilaustralia.com/wp-content/uploads/2014/03/491839224534091454.gif\" /></a></div>";
    // when
    NSString *l_result = [IFAHtmlParser firstOpeningTagForStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<div style=\"float:left; padding: 10px;\">")));
}

- (void)testFirstOpeningTagForStringRepresentationWithComment{
    // given
    NSString *l_htmlString = @"<!-- adman_adcode (middle, 1) --><div style=\"float:left; padding: 10px;\"> <a href=\"http://www.rmit.edu.au/\" target=\"_blank\"><img src=\"http://www.brazilaustralia.com/wp-content/uploads/2014/03/491839224534091454.gif\" /></a></div>";
    // when
    NSString *l_result = [IFAHtmlParser firstOpeningTagForStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<div style=\"float:left; padding: 10px;\">")));
}

- (void)testFirstOpeningTagForStringRepresentationWithSelfClosingTag{
    // given
    NSString *l_htmlString = @"<img src=\"http://www.brazilaustralia.com/wp-content/uploads/2014/03/491839224534091454.gif\"/><p><b>hello</b></p>";
    // when
    NSString *l_result = [IFAHtmlParser firstOpeningTagForStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<img src=\"http://www.brazilaustralia.com/wp-content/uploads/2014/03/491839224534091454.gif\"/>")));
}

- (void)testRemoveCommentsFromStringRepresentationWithOneComment{
    // given
    NSString *l_htmlString = @"<!-- comment 1 --><p><b>hello</b></p>";
    // when
    NSString *l_result = [IFAHtmlParser removeCommentsFromStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<p><b>hello</b></p>")));
}

- (void)testRemoveCommentsFromStringRepresentationWithTwoComments{
    // given
    NSString *l_htmlString = @"<!-- comment 1 --><p><b>hello</b></p><!-- comment 2 -->";
    // when
    NSString *l_result = [IFAHtmlParser removeCommentsFromStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<p><b>hello</b></p>")));
}

- (void)testRemoveCommentsFromStringRepresentationWithNoComments{
    // given
    NSString *l_htmlString = @"<p><b>hello</b></p>";
    // when
    NSString *l_result = [IFAHtmlParser removeCommentsFromStringRepresentation:l_htmlString];
    // then
    assertThat(l_result, is(equalTo(@"<p><b>hello</b></p>")));
}

- (void)testIsElementClosedForStringRepresentationWithOpeningAndClosingTags{
    // given
    NSString *l_htmlString = @"<b>hello</b>";
    // when
    BOOL l_result = [IFAHtmlParser isElementClosedForStringRepresentation:l_htmlString];
    // then
    assertThatBool(l_result, isTrue());
}

- (void)testIsElementClosedForStringRepresentationWithOpeningClosingTagsAndSpaces{
    // given
    NSString *l_htmlString = @"< b > hello < / b >";
    // when
    BOOL l_result = [IFAHtmlParser isElementClosedForStringRepresentation:l_htmlString];
    // then
    assertThatBool(l_result, isTrue());
}

- (void)testIsElementClosedForStringRepresentationWithOpeningTagThatIsSelfClosed{
    // given
    NSString *l_htmlString = @"<b/>";
    // when
    BOOL l_result = [IFAHtmlParser isElementClosedForStringRepresentation:l_htmlString];
    // then
    assertThatBool(l_result, isTrue());
}

- (void)testIsElementClosedForStringRepresentationWithOpeningTagOnly{
    // given
    NSString *l_htmlString = @"<div style=\"float:left; padding: 10px;\">";
    // when
    BOOL l_result = [IFAHtmlParser isElementClosedForStringRepresentation:l_htmlString];
    // then
    assertThatBool(l_result, isFalse());
}

- (void)testActiveInlineStyleAttributes {
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
//        NSLog(@"a_stringRepresentation: %@, a_activeInlineStyleAttributes: %@", a_stringRepresentation, a_activeInlineStyleAttributes);
        if ([a_stringRepresentation isEqualToString:@"<span STYLE=\"font-size: x-large; color: #ffffff\">M</span>"]) {
            assertThat(a_activeInlineStyleAttributes, hasCountOf(5));
            assertThat(a_activeInlineStyleAttributes, hasEntries(@"background", @"#000000", @"font-weight", @"bold", @"margin-left", @"30px", @"font-size", @"x-large", @"color", @"#ffffff", nil));
        }
    };
    [self parseHtmlFileNamed:@"HtmlParser_testdata3" withElementBlock:l_elementBlock];
}

- (void)testThatLastAncestorHtmlElementNamedReturnsTheCorrectResultWhenAMatchIsFound{

    // given
    id l_htmlElementParsingMetadataMock1 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock1 expect] andReturn:@"name1"]) name];
    id l_htmlElementParsingMetadataMock2 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock2 expect] andReturn:@"name2"]) name];
    id l_htmlElementParsingMetadataMock3 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock3 expect] andReturn:@"name3"]) name];
    NSMutableArray *l_htmlElementParsingMetadataMocks = [@[
            l_htmlElementParsingMetadataMock1,
            l_htmlElementParsingMetadataMock2,
            l_htmlElementParsingMetadataMock3,
    ] mutableCopy];
    id l_htmlParserPartialMock = [OCMockObject partialMockForObject:self.p_htmlParser];
    [[[l_htmlParserPartialMock expect] andReturn:l_htmlElementParsingMetadataMocks] elementMetadataStack];
    
    // when
    IFAHtmlElementParsingMetadata *l_result = [l_htmlParserPartialMock lastAncestorHtmlElementNamed:@"name2"];
    
    // then
    assertThat(l_result, is(equalTo(l_htmlElementParsingMetadataMock2)));
    
}

- (void)testThatLastAncestorHtmlElementNamedReturnsNilWhenAMatchIsNotFound{

    // given
    id l_htmlElementParsingMetadataMock1 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock1 expect] andReturn:@"name1"]) name];
    id l_htmlElementParsingMetadataMock2 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock2 expect] andReturn:@"name2"]) name];
    id l_htmlElementParsingMetadataMock3 = [OCMockObject mockForClass:[IFAHtmlElementParsingMetadata class]];
    [((IFAHtmlElementParsingMetadata *)[[l_htmlElementParsingMetadataMock3 expect] andReturn:@"name3"]) name];
    NSMutableArray *l_htmlElementParsingMetadataMocks = [@[
            l_htmlElementParsingMetadataMock1,
            l_htmlElementParsingMetadataMock2,
            l_htmlElementParsingMetadataMock3,
    ] mutableCopy];
    id l_htmlParserPartialMock = [OCMockObject partialMockForObject:self.p_htmlParser];
    [[[l_htmlParserPartialMock expect] andReturn:l_htmlElementParsingMetadataMocks] elementMetadataStack];

    // when
    IFAHtmlElementParsingMetadata *l_result = [l_htmlParserPartialMock lastAncestorHtmlElementNamed:@"name4"];

    // then
    assertThat(l_result, is(equalTo(nil)));

}

- (void)testReplaceMarkupStringWithMarkupString{

    // given
    __weak __typeof(self) l_weakSelf = self;
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
        if ([a_name isEqualToString:@"img"]) {
            [l_weakSelf.p_htmlParser replaceMarkupString:a_stringRepresentation
                                        withMarkupString:@"<mytag/>"];
        }
    };

    // when
    [self parseHtmlFileNamed:@"HtmlParser_testdata4" withElementBlock:l_elementBlock];

    // then
    assertThat(self.p_htmlParser.mutableHtmlString, is(equalTo(@"<!DOCTYPE html>\n"
 "<html>\n"
 "<head lang=\"en\">\n"
 "    <meta charset=\"UTF-8\">\n"
 "    <title></title>\n"
 "</head>\n"
 "<body>\n"
 "<p><a href=\"http://www.test.com/test.jpg\"><mytag/></a></p>\n"
 "</body>\n"
 "</html>")));

}

- (void)testReplaceMarkupStringWithTagAndAttributes{

    // given
    __weak __typeof(self) l_weakSelf = self;
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
        if ([a_name isEqualToString:@"img"]) {
            NSString *l_tagName = @"mytag";
            NSDictionary *l_attributes = @{
                @"attr1" : @"value1",
                @"attr2" : @"value2",
            };
            [l_weakSelf.p_htmlParser replaceMarkupString:a_stringRepresentation withTag:l_tagName andAttributes:l_attributes];
        }
    };

    // when
    [self parseHtmlFileNamed:@"HtmlParser_testdata4" withElementBlock:l_elementBlock];

    // then
    assertThat(self.p_htmlParser.mutableHtmlString, is(equalTo(@"<!DOCTYPE html>\n"
 "<html>\n"
 "<head lang=\"en\">\n"
 "    <meta charset=\"UTF-8\">\n"
 "    <title></title>\n"
 "</head>\n"
 "<body>\n"
 "<p><a href=\"http://www.test.com/test.jpg\"><mytag attr1=\"value1\" attr2=\"value2\"></mytag></a></p>\n"
 "</body>\n"
 "</html>")));

}

- (void)testReplaceFirstOpeningTagInStringRepresentationWithMarkupStringWhenFirstOpeningTagIsNotClosed{

    // given
    __weak __typeof(self) l_weakSelf = self;
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
        if ([a_name isEqualToString:@"a"]) {
            NSString *l_tagName = @"mytag";
            NSDictionary *l_attributes = @{
                @"attr1" : @"value1",
                @"attr2" : @"value2",
            };
            [l_weakSelf.p_htmlParser replaceFirstOpeningTagInStringRepresentation:a_stringRepresentation withTag:l_tagName andAttributes:l_attributes];
        }
    };

    // when
    [self parseHtmlFileNamed:@"HtmlParser_testdata4" withElementBlock:l_elementBlock];

    // then
    assertThat(self.p_htmlParser.mutableHtmlString, is(equalTo(@"<!DOCTYPE html>\n"
 "<html>\n"
 "<head lang=\"en\">\n"
 "    <meta charset=\"UTF-8\">\n"
 "    <title></title>\n"
 "</head>\n"
 "<body>\n"
 "<p><mytag attr1=\"value1\" attr2=\"value2\"><img src=\"http://www.test.com/test.jpg\"/></a></p>\n"
 "</body>\n"
 "</html>")));

}

- (void)testReplaceFirstOpeningTagInStringRepresentationWithMarkupStringWhenFirstOpeningTagIsClosed{

    // given
    __weak __typeof(self) l_weakSelf = self;
    IFAHtmlParserTestsElementBlock l_elementBlock = ^(NSUInteger a_index, NSString *a_name, NSString *a_stringRepresentation, NSDictionary *a_attributes, NSDictionary *a_activeInlineStyleAttributes) {
        if ([a_name isEqualToString:@"img"]) {
            NSString *l_tagName = @"mytag";
            NSDictionary *l_attributes = @{
                @"attr1" : @"value1",
                @"attr2" : @"value2",
            };
            [l_weakSelf.p_htmlParser replaceFirstOpeningTagInStringRepresentation:a_stringRepresentation withTag:l_tagName andAttributes:l_attributes];
        }
    };

    // when
    [self parseHtmlFileNamed:@"HtmlParser_testdata4" withElementBlock:l_elementBlock];

    // then
    assertThat(self.p_htmlParser.mutableHtmlString, is(equalTo(@"<!DOCTYPE html>\n"
 "<html>\n"
 "<head lang=\"en\">\n"
 "    <meta charset=\"UTF-8\">\n"
 "    <title></title>\n"
 "</head>\n"
 "<body>\n"
 "<p><a href=\"http://www.test.com/test.jpg\"><mytag attr1=\"value1\" attr2=\"value2\"></mytag></a></p>\n"
 "</body>\n"
 "</html>")));

}

#pragma mark - Private

- (void)parseHtmlFileNamed:(NSString *)a_htmlFileName
            withElementBlock:(IFAHtmlParserTestsElementBlock)a_elementBlock {

    NSString *l_htmlOriginalFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:a_htmlFileName
                                                                                        ofType:@"html"];
    NSString *l_htmlOriginal = [[NSString alloc] initWithContentsOfFile:l_htmlOriginalFilePath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];

    assertThat(l_htmlOriginal, is(notNilValue()));

    NSMutableArray *l_elementNames = [@[] mutableCopy];
    NSMutableArray *l_elementStringRepresentations = [@[] mutableCopy];
    NSMutableArray *l_elementAttributes = [@[] mutableCopy];
    NSMutableArray *l_activeInlineStyleAttributes = [@[] mutableCopy];

    void (^l_endElementBlock)(IFAHtmlElementParsingContext *) =
            ^(IFAHtmlElementParsingContext *a_parsingContext) {
                IFAHtmlElementParsingMetadata *l_elementMetadata = a_parsingContext.elementMetadata;
                NSString *l_name = l_elementMetadata.name;
                NSDictionary *l_attributes = l_elementMetadata.attributes;
                NSString *l_stringRepresentation = l_elementMetadata.stringRepresentation;
//                NSLog(@"l_name: %@, l_attributes: %@, string: %@", l_name, [l_attributes description], l_stringRepresentation);
                [l_elementNames addObject:l_name];
                [l_elementStringRepresentations addObject:l_stringRepresentation];
                [l_elementAttributes addObject:l_attributes ? l_attributes : [NSNull null]];
                [l_activeInlineStyleAttributes addObject:[self.p_htmlParser activeInlineStyleAttributes]];
            };
    [self.p_htmlParser parseHtmlString:l_htmlOriginal
                    endElementBlock:l_endElementBlock];

    for (NSUInteger i = 0; i < l_elementNames.count; i++) {
        NSString *l_name = l_elementNames[i];
        NSString *l_stringRepresentation = l_elementStringRepresentations[i];
        NSDictionary *l_attributes = l_elementAttributes[i];
        if (l_attributes == (id) [NSNull null]) {
            l_attributes = nil;
        }
        a_elementBlock(i, l_name, l_stringRepresentation, l_attributes, l_activeInlineStyleAttributes[i]);
    }

}

@end
