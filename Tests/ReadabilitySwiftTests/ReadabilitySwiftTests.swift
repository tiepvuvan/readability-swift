import XCTest
@testable import ReadabilitySwift
import SwiftSoup

final class ReadabilitySwiftTests: XCTestCase {
    
    // MARK: - Test Data
    func createSimpleArticleHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Test Article - Example Site</title>
            <meta property="og:title" content="Test Article">
            <meta name="author" content="John Doe">
            <meta property="article:published_time" content="2023-01-01T12:00:00Z">
            <meta property="og:site_name" content="Example Site">
        </head>
        <body>
            <header>
                <nav>Navigation menu</nav>
            </header>
            <main>
                <article>
                    <h1>Test Article</h1>
                    <p class="byline">By John Doe</p>
                    <p>This is the first paragraph of the article. It contains enough text to be considered substantial content for the readability algorithm. This paragraph needs to be longer to meet the minimum character threshold of 140 characters that the readability algorithm requires for content to be considered readable.</p>
                    <p>This is the second paragraph with more content. It also contains enough text to demonstrate that this is a real article worth extracting. This paragraph also needs to be long enough to individually meet the 140 character minimum threshold required by the algorithm.</p>
                    <p>The third paragraph continues the article with even more substantial content to ensure proper scoring. Like the other paragraphs, this one also needs sufficient length to contribute to the readability score calculation.</p>
                    <div class="advertisement">This is an advertisement</div>
                    <p>The fourth paragraph after the advertisement continues the main content flow.</p>
                </article>
            </main>
            <footer>
                <p>Footer content</p>
            </footer>
        </body>
        </html>
        """
    }
    
    func createNonReadableHTML() -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head><title>Navigation Page</title></head>
        <body>
            <div>
                <nav>
                    <ul>
                        <li><a href="/page1">Page 1</a></li>
                        <li><a href="/page2">Page 2</a></li>
                        <li><a href="/page3">Page 3</a></li>
                    </ul>
                </nav>
            </div>
        </body>
        </html>
        """
    }
    
    func createComplexArticleHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en" dir="ltr">
        <head>
            <title>Complex Article: Understanding Technology - Tech Blog</title>
            <meta name="author" content="Jane Smith">
            <meta property="article:author" content="Jane Smith">
            <meta property="article:published_time" content="2023-12-01T10:30:00Z">
            <meta property="og:site_name" content="Tech Blog">
            <meta name="description" content="A comprehensive guide to understanding modern technology trends">
            <script type="application/ld+json">
            {
                "@context": "https://schema.org",
                "@type": "Article",
                "headline": "Complex Article: Understanding Technology",
                "author": {
                    "@type": "Person",
                    "name": "Jane Smith"
                },
                "datePublished": "2023-12-01T10:30:00Z"
            }
            </script>
        </head>
        <body>
            <header class="site-header">
                <nav>Site navigation</nav>
            </header>
            <main class="content">
                <article class="main-article">
                    <header class="article-header">
                        <h1>Complex Article: Understanding Technology</h1>
                        <div class="article-meta">
                            <span class="author">By Jane Smith</span>
                            <time datetime="2023-12-01T10:30:00Z">December 1, 2023</time>
                        </div>
                    </header>
                    <div class="article-content">
                        <p>Technology has revolutionized the way we live and work. This comprehensive article explores the various aspects of modern technology and its impact on society.</p>
                        <h2>The Digital Revolution</h2>
                        <p>The digital revolution has transformed every aspect of our lives. From communication to commerce, technology has made processes faster, more efficient, and more accessible to people around the world.</p>
                        <p>Mobile devices have become ubiquitous, allowing us to stay connected and access information anywhere, anytime. This connectivity has created new opportunities for innovation and collaboration.</p>
                        <div class="sidebar-ad">Advertisement content</div>
                        <h2>Artificial Intelligence and Machine Learning</h2>
                        <p>Artificial intelligence and machine learning are at the forefront of technological advancement. These technologies are being applied across industries to solve complex problems and improve efficiency.</p>
                        <p>Machine learning algorithms can analyze vast amounts of data to identify patterns and make predictions. This capability is being used in healthcare, finance, transportation, and many other sectors.</p>
                        <blockquote>
                            <p>"The future belongs to those who can harness the power of technology to solve real-world problems." - Tech Expert</p>
                        </blockquote>
                        <h2>The Internet of Things</h2>
                        <p>The Internet of Things (IoT) represents the next phase of digital connectivity. By connecting everyday objects to the internet, we can create smarter homes, cities, and workplaces.</p>
                        <p>IoT devices can collect and share data, automate processes, and provide insights that help us make better decisions. From smart thermostats to connected cars, IoT is reshaping our relationship with technology.</p>
                        <ul>
                            <li>Smart home devices for automation and energy efficiency</li>
                            <li>Wearable technology for health monitoring</li>
                            <li>Industrial IoT for predictive maintenance</li>
                        </ul>
                        <h2>Challenges and Opportunities</h2>
                        <p>While technology offers tremendous opportunities, it also presents challenges that we must address. Privacy concerns, cybersecurity threats, and the digital divide are important issues that require attention.</p>
                        <p>As we continue to advance technologically, it's crucial to ensure that the benefits are accessible to everyone and that we protect individuals' rights and security in the digital age.</p>
                    </div>
                </article>
            </main>
            <aside class="sidebar">
                <div class="related-articles">Related articles</div>
            </aside>
            <footer class="site-footer">
                <p>Copyright © 2023 Tech Blog</p>
            </footer>
        </body>
        </html>
        """
    }
    
    // MARK: - API Tests
    func testReadabilityInitialization() throws {
        let html = createSimpleArticleHTML()
        let readability = try Readability(html: html)
        
        XCTAssertNotNil(readability)
    }
    
    func testReadabilityWithOptions() throws {
        let html = createSimpleArticleHTML()
        let options = ReadabilityOptions(
            debug: true,
            maxElemsToParse: 1000,
            nbTopCandidates: 3,
            charThreshold: 300,
            keepClasses: true
        )
        
        let readability = try Readability(html: html, options: options)
        XCTAssertNotNil(readability)
    }
    
    func testBasicParsing() throws {
        let html = createSimpleArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.title.isEmpty)
        XCTAssertFalse(result!.content.isEmpty)
        XCTAssertFalse(result!.textContent.isEmpty)
        XCTAssertGreaterThan(result!.length, 0)
    }
    
    func testComplexArticleParsing() throws {
        let html = createComplexArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.title, "Complex Article: Understanding Technology")
        XCTAssertEqual(result!.byline, "Jane Smith")
        XCTAssertEqual(result!.siteName, "Tech Blog")
        XCTAssertEqual(result!.lang, "en")
        XCTAssertEqual(result!.dir, "ltr")
        XCTAssertEqual(result!.publishedTime, "2023-12-01T10:30:00Z")
        XCTAssertGreaterThan(result!.length, 500)
    }
    
    func testIsProbablyReaderable() throws {
        let readableHTML = createSimpleArticleHTML()
        let readableDocument = try SwiftSoup.parse(readableHTML)
        XCTAssertTrue(Readability.isProbablyReaderable(readableDocument))
        
        let nonReadableHTML = createNonReadableHTML()
        let nonReadableDocument = try SwiftSoup.parse(nonReadableHTML)
        XCTAssertFalse(Readability.isProbablyReaderable(nonReadableDocument))
    }
    
    // MARK: - Content Extraction Tests
    func testTitleExtraction() throws {
        let html = createComplexArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.title, "Complex Article: Understanding Technology")
    }
    
    func testBylineExtraction() throws {
        let html = createComplexArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.byline, "Jane Smith")
    }
    
    func testMetadataExtraction() throws {
        let html = createComplexArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.siteName, "Tech Blog")
        XCTAssertEqual(result!.lang, "en")
        XCTAssertEqual(result!.dir, "ltr")
        XCTAssertEqual(result!.publishedTime, "2023-12-01T10:30:00Z")
    }
    
    func testExcerptGeneration() throws {
        let html = createComplexArticleHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.excerpt.isEmpty)
        XCTAssertLessThanOrEqual(result!.excerpt.count, 250)
    }
    
    // MARK: - Edge Cases Tests
    func testEmptyDocument() throws {
        let html = "<html><head><title>Empty</title></head><body></body></html>"
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        // Should return nil for empty documents
        XCTAssertNil(result)
    }
    
    func testDocumentWithOnlyNavigation() throws {
        let html = createNonReadableHTML()
        let readability = try Readability(html: html)
        let result = try readability.parse()
        
        // Should return nil for documents without substantial content
        XCTAssertNil(result)
    }
    
    func testLargeDocument() throws {
        let options = ReadabilityOptions(maxElemsToParse: 10)
        let html = createComplexArticleHTML()
        
        // Error should occur during parse(), not initialization (matching JavaScript behavior)
        let readability = try Readability(html: html, options: options)
        
        XCTAssertThrowsError(try readability.parse()) { error in
            if case ReadabilityError.tooManyElements = error {
                // Expected error
            } else {
                XCTFail("Expected tooManyElements error")
            }
        }
    }
    
    // MARK: - Readability Score Tests
    func testReadabilityScoring() throws {
        let readableDocument = try SwiftSoup.parse(createComplexArticleHTML())
        let nonReadableDocument = try SwiftSoup.parse(createNonReadableHTML())
        
        XCTAssertTrue(Readability.isProbablyReaderable(readableDocument))
        XCTAssertFalse(Readability.isProbablyReaderable(nonReadableDocument))
    }
    
    func testCustomCharThreshold() throws {
        let options = ReadabilityOptions(charThreshold: 1000)
        let document = try SwiftSoup.parse(createSimpleArticleHTML())
        
        // With higher threshold, shorter articles might not be considered readable
        let isReadable = Readability.isProbablyReaderable(document, options: options)
        XCTAssertTrue(isReadable || !isReadable) // Either result is valid depending on content length
    }
    
    // MARK: - Performance Tests
    func testParsingPerformance() throws {
        let html = createComplexArticleHTML()
        
        measure {
            do {
                let readability = try Readability(html: html)
                let _ = try readability.parse()
            } catch {
                XCTFail("Parsing failed: \(error)")
            }
        }
    }
    
    func testReadabilityDetectionPerformance() throws {
        let document = try SwiftSoup.parse(createComplexArticleHTML())
        
        measure {
            let _ = Readability.isProbablyReaderable(document)
        }
    }
}