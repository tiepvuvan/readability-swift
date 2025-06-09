import Foundation
import SwiftSoup

// Simple test runner since XCTest isn't available
public class ReadabilityTestRunner {
    
    public static func runBasicTests() {
        print("🧪 Starting ReadabilitySwift Basic Tests...")
        
        testBasicInitialization()
        testSimpleHtmlParsing()
        testIsProbablyReaderable()
        testComplexArticleParsing()
        testMetadataExtraction()
        testTitleExtractionFixes()
        testMozillaTestCase001()
        
        print("✅ All basic tests completed!")
    }
    
    private static func testBasicInitialization() {
        print("🔹 Testing basic initialization...")
        
        let html = "<html><head><title>Test</title></head><body><p>Test content</p></body></html>"
        
        do {
            let readability = try Readability(html: html)
            print("  ✅ Basic initialization successful")
        } catch {
            print("  ❌ Basic initialization failed: \(error)")
        }
    }
    
    private static func testSimpleHtmlParsing() {
        print("🔹 Testing simple HTML parsing...")
        
        let html = """
        <html>
        <head>
            <title>Simple Test Article</title>
            <meta name="author" content="Test Author">
        </head>
        <body>
            <article>
                <h1>Test Article</h1>
                <p>This is a test paragraph with sufficient content to be considered readable by the algorithm.</p>
                <p>This is another paragraph with more content to ensure proper scoring and extraction.</p>
                <p>A third paragraph to make sure the article has enough content to be processed correctly.</p>
            </article>
        </body>
        </html>
        """
        
        do {
            let readability = try Readability(html: html)
            let result = try readability.parse()
            
            if let result = result {
                print("  ✅ Parsing successful")
                print("    📝 Title: \(result.title)")
                print("    📄 Content length: \(result.length)")
                print("    👤 Byline: \(result.byline ?? "None")")
                
                assert(!result.title.isEmpty, "Title should not be empty")
                assert(result.length > 0, "Content length should be greater than 0")
                assert(!result.content.isEmpty, "Content should not be empty")
            } else {
                print("  ❌ Parsing returned nil result")
            }
        } catch {
            print("  ❌ Simple parsing failed: \(error)")
        }
    }
    
    private static func testIsProbablyReaderable() {
        print("🔹 Testing isProbablyReaderable...")
        
        let readableHtml = """
        <html>
        <body>
            <article>
                <h1>Article Title</h1>
                <p>This is a substantial article with enough content to be considered readable. It has multiple paragraphs and sufficient text content.</p>
                <p>The second paragraph continues with more meaningful content that should definitely qualify this as readable content.</p>
                <p>A third paragraph with even more content to ensure this passes the readability threshold.</p>
            </article>
        </body>
        </html>
        """
        
        let nonReadableHtml = """
        <html>
        <body>
            <nav>
                <ul>
                    <li><a href="/page1">Page 1</a></li>
                    <li><a href="/page2">Page 2</a></li>
                </ul>
            </nav>
        </body>
        </html>
        """
        
        do {
            let readableDocument = try SwiftSoup.parse(readableHtml)
            let nonReadableDocument = try SwiftSoup.parse(nonReadableHtml)
            
            let isReadable = Readability.isProbablyReaderable(readableDocument)
            let isNotReadable = !Readability.isProbablyReaderable(nonReadableDocument)
            
            if isReadable && isNotReadable {
                print("  ✅ isProbablyReaderable working correctly")
            } else {
                print("  ❌ isProbablyReaderable not working as expected")
                print("    Readable result: \(isReadable)")
                print("    Non-readable result: \(!isNotReadable)")
            }
        } catch {
            print("  ❌ isProbablyReaderable test failed: \(error)")
        }
    }
    
    private static func testComplexArticleParsing() {
        print("🔹 Testing complex article parsing...")
        
        let html = """
        <html lang="en" dir="ltr">
        <head>
            <title>Complex Article: Technology Trends</title>
            <meta name="author" content="Jane Smith">
            <meta property="article:published_time" content="2023-12-01T10:30:00Z">
            <meta property="og:site_name" content="Tech Blog">
        </head>
        <body>
            <header>Navigation</header>
            <main>
                <article>
                    <h1>Complex Article: Technology Trends</h1>
                    <div class="byline">By Jane Smith</div>
                    <p>Technology has revolutionized the way we live and work. This comprehensive article explores the various aspects of modern technology and its impact on society.</p>
                    <h2>The Digital Revolution</h2>
                    <p>The digital revolution has transformed every aspect of our lives. From communication to commerce, technology has made processes faster, more efficient, and more accessible.</p>
                    <p>Mobile devices have become ubiquitous, allowing us to stay connected and access information anywhere, anytime.</p>
                    <h2>Future Implications</h2>
                    <p>As we look to the future, technology will continue to shape our world in unprecedented ways. It's important to understand these changes and adapt accordingly.</p>
                </article>
            </main>
            <footer>Footer content</footer>
        </body>
        </html>
        """
        
        do {
            let readability = try Readability(html: html)
            let result = try readability.parse()
            
            if let result = result {
                print("  ✅ Complex parsing successful")
                print("    📝 Title: \(result.title)")
                print("    👤 Byline: \(result.byline ?? "None")")
                print("    🌐 Site: \(result.siteName ?? "None")")
                print("    🌍 Language: \(result.lang ?? "None")")
                print("    📅 Published: \(result.publishedTime ?? "None")")
                print("    📄 Length: \(result.length)")
                
                assert(result.title.contains("Technology"), "Title should contain 'Technology'")
                assert(result.length > 200, "Content should be substantial")
                assert(result.lang == "en", "Language should be 'en'")
            } else {
                print("  ❌ Complex parsing returned nil result")
            }
        } catch {
            print("  ❌ Complex parsing failed: \(error)")
        }
    }
    
    private static func testMetadataExtraction() {
        print("🔹 Testing metadata extraction...")
        
        let html = """
        <html lang="fr" dir="rtl">
        <head>
            <title>Test Article - Example Site</title>
            <meta property="og:title" content="Meta Title">
            <meta name="author" content="John Doe">
            <meta property="article:published_time" content="2023-01-01T12:00:00Z">
            <meta property="og:site_name" content="Example Site">
        </head>
        <body>
            <article>
                <h1>Test Article</h1>
                <p>Content here with enough text to be considered substantial and meaningful for the readability algorithm to process.</p>
                <p>More content to ensure this article meets the minimum requirements for parsing and extraction.</p>
            </article>
        </body>
        </html>
        """
        
        do {
            let readability = try Readability(html: html)
            let result = try readability.parse()
            
            if let result = result {
                print("  ✅ Metadata extraction successful")
                print("    📝 Title: \(result.title)")
                print("    👤 Byline: \(result.byline ?? "None")")
                print("    🌐 Site: \(result.siteName ?? "None")")
                print("    🌍 Language: \(result.lang ?? "None")")
                print("    ➡️ Direction: \(result.dir ?? "None")")
                print("    📅 Published: \(result.publishedTime ?? "None")")
                
                assert(result.title == "Meta Title", "Should use og:title")
                assert(result.byline == "John Doe", "Should extract author")
                assert(result.siteName == "Example Site", "Should extract site name")
                assert(result.lang == "fr", "Should extract language")
                assert(result.dir == "rtl", "Should extract direction")
                assert(result.publishedTime == "2023-01-01T12:00:00Z", "Should extract published time")
            } else {
                print("  ❌ Metadata extraction returned nil result")
            }
        } catch {
            print("  ❌ Metadata extraction failed: \(error)")
        }
    }
    
    private static func testTitleExtractionFixes() {
        print("🔹 Testing title extraction fixes...")
        
        let html = """
        <!DOCTYPE html>
        <html lang="en" dir="ltr">
        <head>
            <title>Complex Article: Understanding Technology - Tech Blog</title>
            <meta name="author" content="Jane Smith">
            <meta property="og:site_name" content="Tech Blog">
        </head>
        <body>
            <article>
                <h1>Complex Article: Understanding Technology</h1>
                <p>Technology has revolutionized the way we live and work. This comprehensive article explores the various aspects of modern technology and its impact on society.</p>
                <p>The digital revolution has transformed every aspect of our lives. From communication to commerce, technology has made processes faster, more efficient, and more accessible to people around the world.</p>
            </article>
        </body>
        </html>
        """
        
        do {
            let readability = try Readability(html: html)
            let result = try readability.parse()
            
            if let result = result {
                print("  📝 Extracted title: '\(result.title)'")
                print("  👤 Extracted byline: '\(result.byline ?? "nil")'")
                print("  🌐 Extracted site: '\(result.siteName ?? "nil")'")
                print("  🌍 Extracted language: '\(result.lang ?? "nil")'")
                print("  ➡️ Extracted direction: '\(result.dir ?? "nil")'")
                
                let expectedTitle = "Complex Article: Understanding Technology"
                if result.title == expectedTitle {
                    print("  ✅ Title extraction fixed - site name properly removed!")
                } else {
                    print("  ⚠️ Title extraction needs work - Expected: '\(expectedTitle)', Got: '\(result.title)'")
                }
                
                if result.lang == "en" {
                    print("  ✅ Language extraction working!")
                } else {
                    print("  ⚠️ Language extraction issue - Expected: 'en', Got: '\(result.lang ?? "nil")'")
                }
                
                if result.dir == "ltr" {
                    print("  ✅ Direction extraction working!")
                } else {
                    print("  ⚠️ Direction extraction issue - Expected: 'ltr', Got: '\(result.dir ?? "nil")'")
                }
            } else {
                print("  ❌ Title extraction test returned nil result")
            }
        } catch {
            print("  ❌ Title extraction test failed: \(error)")
        }
    }
    
    private static func testMozillaTestCase001() {
        print("🔹 Testing Mozilla test case 001...")
        
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Get your Frontend JavaScript Code Covered | Code | Nicolas Perriault</title>
            <meta name="description" content="Nicolas Perriault's homepage.">
            <meta name="author" content="Nicolas Perriault">
        </head>
        <body>
            <div id="content">
                <article>
                    <h2>Get your Frontend JavaScript Code Covered</h2>
                    <p>So finally you're testing your frontend JavaScript code? Great! The more you write tests, the more confident you get with your code… but how much of your code is actually covered by your tests? That's where code coverage might help.</p>
                    <p>JavaScript code coverage has always been a bit tricky, but over the past few months I've been working on coverage tools for JavaScript in both the browser and server environments, and I think I've found a decent solution for achieving code coverage which I want to share with you.</p>
                    <p>Let me introduce you to Blanket.js, a simple JavaScript library for browser-based code coverage.</p>
                </article>
            </div>
        </body>
        </html>
        """
        
        do {
            // Test readability detection
            let document = try SwiftSoup.parse(html)
            let isReadable = Readability.isProbablyReaderable(document)
            print("  📊 Mozilla test case readability: \(isReadable)")
            
            // Test parsing
            let readability = try Readability(html: html)
            let result = try readability.parse()
            
            if let result = result {
                print("  📝 Title: '\(result.title)'")
                print("  👤 Byline: '\(result.byline ?? "nil")'")
                print("  🌍 Language: '\(result.lang ?? "nil")'")
                print("  📄 Content length: \(result.length)")
                
                let expectedTitle = "Get your Frontend JavaScript Code Covered"
                if result.title == expectedTitle {
                    print("  ✅ Mozilla test case title extraction perfect!")
                } else {
                    print("  ⚠️ Title: Expected '\(expectedTitle)', Got '\(result.title)'")
                }
                
                if result.byline == "Nicolas Perriault" {
                    print("  ✅ Mozilla test case byline extraction perfect!")
                } else {
                    print("  ⚠️ Byline: Expected 'Nicolas Perriault', Got '\(result.byline ?? "nil")'")
                }
                
                if result.lang == "en" {
                    print("  ✅ Mozilla test case language extraction perfect!")
                } else {
                    print("  ⚠️ Language: Expected 'en', Got '\(result.lang ?? "nil")'")
                }
                
                if isReadable {
                    print("  ✅ Mozilla test case correctly identified as readable!")
                } else {
                    print("  ⚠️ Mozilla test case should be readable but wasn't detected as such")
                }
            } else {
                print("  ❌ No result returned for Mozilla test case")
            }
        } catch {
            print("  ❌ Mozilla test case failed: \(error)")
        }
    }
}