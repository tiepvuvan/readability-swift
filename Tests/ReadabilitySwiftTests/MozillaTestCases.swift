import XCTest
@testable import ReadabilitySwift
import SwiftSoup

final class MozillaTestCases: XCTestCase {
    
    // Test case 001 from Mozilla's test suite
    func createTestCase001() -> (html: String, expectedMetadata: ExpectedMetadata) {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Get your Frontend JavaScript Code Covered | Code | Nicolas Perriault</title>
            <meta name="description" content="Nicolas Perriault's homepage.">
            <meta name="author" content="Nicolas Perriault">
        </head>
        <body>
            <div id="header">
                <h1><a href="/">Nicolas Perriault</a></h1>
                <ul id="nav">
                    <li><a href="/code/">Code</a></li>
                    <li><a href="/talks/">Talks</a></li>
                    <li><a href="/resume/">Resume</a></li>
                </ul>
            </div>
            <div id="content">
                <article>
                    <h2>Get your Frontend JavaScript Code Covered</h2>
                    <p class="date">July 2012</p>
                    <p>So finally you're <a href="/talks/">testing your frontend JavaScript code</a>? Great! The more you <a href="/code/2012/01/01/functional-javascript-test-suite/">write tests</a>, the more confident you get with your code… but how much of your code is actually covered by your tests? That's where <strong>code coverage</strong> might help.</p>
                    <p>JavaScript code coverage has always been a bit tricky, but over the past few months I've been working on <a href="https://github.com/seb-m/coverage.py">coverage</a> tools for JavaScript in both the browser and server environments, and I think I've found a decent solution for achieving code coverage which I want to share with you.</p>
                    <p>Let me introduce you to <a href="https://github.com/n1k0/blanket">Blanket.js</a>, a simple JavaScript library for browser-based code coverage.</p>
                    <h3>How to Use Blanket.js</h3>
                    <p>Blanket.js is designed to be easy to install and use. In most cases, it's a question of dropping a single script tag into your test harness.</p>
                    <p>The code coverage data is collected using <a href="https://developer.mozilla.org/en/JavaScript/Reference/Statements/try...catch">try/catch</a> blocks, so it works in all browsers.</p>
                </article>
            </div>
            <div id="footer">
                <p>&copy; 2012 Nicolas Perriault</p>
            </div>
        </body>
        </html>
        """
        
        let expectedMetadata = ExpectedMetadata(
            title: "Get your Frontend JavaScript Code Covered",
            byline: "Nicolas Perriault",
            dir: nil,
            lang: "en",
            excerpt: "Nicolas Perriault's homepage.",
            siteName: nil,
            publishedTime: nil,
            readerable: true
        )
        
        return (html, expectedMetadata)
    }
    
    struct ExpectedMetadata {
        let title: String
        let byline: String?
        let dir: String?
        let lang: String?
        let excerpt: String?
        let siteName: String?
        let publishedTime: String?
        let readerable: Bool
    }
    
    func testMozillaTestCase001() throws {
        let testCase = createTestCase001()
        
        // Test readability detection
        let document = try SwiftSoup.parse(testCase.html)
        let isReadable = Readability.isProbablyReaderable(document)
        XCTAssertEqual(isReadable, testCase.expectedMetadata.readerable, "Readability detection should match expected")
        
        // Test parsing
        let readability = try Readability(html: testCase.html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result, "Should successfully parse the document")
        
        guard let result = result else { return }
        
        // Validate title extraction
        XCTAssertEqual(result.title, testCase.expectedMetadata.title, "Title should match expected")
        
        // Validate byline extraction
        XCTAssertEqual(result.byline, testCase.expectedMetadata.byline, "Byline should match expected")
        
        // Validate language
        XCTAssertEqual(result.lang, testCase.expectedMetadata.lang, "Language should match expected")
        
        // Validate direction
        XCTAssertEqual(result.dir, testCase.expectedMetadata.dir, "Direction should match expected")
        
        // Validate site name
        XCTAssertEqual(result.siteName, testCase.expectedMetadata.siteName, "Site name should match expected")
        
        // Validate published time
        XCTAssertEqual(result.publishedTime, testCase.expectedMetadata.publishedTime, "Published time should match expected")
        
        // Content should not be empty
        XCTAssertFalse(result.content.isEmpty, "Content should not be empty")
        XCTAssertGreaterThan(result.length, 100, "Content should have substantial length")
    }
    
    // Test case for metadata extraction with og:title
    func testOpenGraphTitleExtraction() throws {
        let html = """
        <!DOCTYPE html>
        <html lang="fr" dir="rtl">
        <head>
            <title>Original Title | Site Name</title>
            <meta property="og:title" content="OG Title">
            <meta name="author" content="Test Author">
            <meta property="og:site_name" content="Test Site">
        </head>
        <body>
            <article>
                <h1>Article Title</h1>
                <p>Article content with substantial text to ensure proper parsing and content extraction by the readability algorithm.</p>
                <p>More content to meet minimum requirements for article detection and processing.</p>
            </article>
        </body>
        </html>
        """
        
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        
        if let result = result {
            // Should use og:title instead of document title
            XCTAssertEqual(result.title, "OG Title", "Should prefer og:title over document title")
            XCTAssertEqual(result.byline, "Test Author", "Should extract author")
            XCTAssertEqual(result.siteName, "Test Site", "Should extract site name from og:site_name")
            XCTAssertEqual(result.lang, "fr", "Should extract language from html lang attribute")
            XCTAssertEqual(result.dir, "rtl", "Should extract direction from html dir attribute")
        }
    }
    
    // Test case for content that should NOT be readable
    func testNonReadableContent() throws {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><title>Navigation Page</title></head>
        <body>
            <nav>
                <ul>
                    <li><a href="/page1">Page 1</a></li>
                    <li><a href="/page2">Page 2</a></li>
                    <li><a href="/page3">Page 3</a></li>
                </ul>
            </nav>
            <div>
                <p>Short text.</p>
            </div>
        </body>
        </html>
        """
        
        let document = try SwiftSoup.parse(html)
        let isReadable = Readability.isProbablyReaderable(document)
        
        // This should NOT be considered readable
        XCTAssertFalse(isReadable, "Navigation-only content should not be readable")
        
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        // Should return nil or very minimal content
        if let result = result {
            XCTAssertLessThan(result.length, 100, "Non-readable content should have minimal extracted content")
        }
    }
    
    // Test case for maxElemsToParse validation
    func testMaxElementsValidation() throws {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><title>Test Article</title></head>
        <body>
            <article>
                <p>Paragraph 1</p>
                <p>Paragraph 2</p>
                <p>Paragraph 3</p>
                <p>Paragraph 4</p>
                <p>Paragraph 5</p>
                <div>Div 1</div>
                <div>Div 2</div>
                <div>Div 3</div>
            </article>
        </body>
        </html>
        """
        
        let options = ReadabilityOptions(maxElemsToParse: 3)
        
        XCTAssertThrowsError(try Readability(html: html, options: options).parse()) { error in
            if case ReadabilityError.tooManyElements(let count) = error {
                XCTAssertGreaterThan(count, 3, "Should report exceeding element limit")
            } else {
                XCTFail("Should throw tooManyElements error")
            }
        }
    }
}