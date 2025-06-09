# ReadabilitySwift

[![CI](https://github.com/tiepvuvan/readability-swift/workflows/CI/badge.svg)](https://github.com/tiepvuvan/readability-swift/actions)
[![codecov](https://codecov.io/gh/tiepvuvan/readability-swift/branch/main/graph/badge.svg)](https://codecov.io/gh/tiepvuvan/readability-swift)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2013.0%20%7C%20macOS%2010.15%20%7C%20tvOS%2013.0%20%7C%20watchOS%206.0-blue.svg)](https://swift.org)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/tiepvuvan/readability-swift/blob/main/LICENSE)

A faithful Swift port of Mozilla's Readability library, designed to extract clean, readable content from web pages with the same behavior as the original JavaScript implementation.

## Overview

ReadabilitySwift provides the same functionality as Mozilla's Readability library but written in pure Swift with full compatibility across iOS, macOS, tvOS, and watchOS platforms. The implementation closely follows the JavaScript algorithm to ensure consistent content extraction results.

## Features

- ✅ **Exact JavaScript Behavior**: Matches the original Mozilla Readability library's output
- ✅ **Content Extraction**: Intelligently extracts main article content from web pages
- ✅ **Metadata Extraction**: Pulls title, author, publication date, language, and more
- ✅ **Readability Detection**: Determines if a page contains readable content
- ✅ **Swift Package Manager**: Easy integration with SPM
- ✅ **Cross-Platform**: Supports iOS, macOS, tvOS, and watchOS
- ✅ **Comprehensive Testing**: Extensive test suite including Mozilla test cases

## Installation

### Swift Package Manager

Add ReadabilitySwift to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tiepvuvan/readability-swift.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import ReadabilitySwift

do {
    // Parse HTML string
    let readability = try Readability(html: htmlString)
    let result = try readability.parse()
    
    if let result = result {
        print("Title: \(result.title)")
        print("Author: \(result.byline ?? "Unknown")")
        print("Content: \(result.content)")
        print("Text Length: \(result.length)")
        print("Excerpt: \(result.excerpt)")
    }
} catch {
    print("Parsing failed: \(error)")
}
```

### With Options

```swift
let options = ReadabilityOptions(
    debug: true,
    maxElemsToParse: 1000,
    charThreshold: 500,
    classesToPreserve: ["highlight", "code"],
    keepClasses: true
)

let readability = try Readability(html: htmlString, options: options)
let result = try readability.parse()
```

### Readability Detection

```swift
import SwiftSoup

let document = try SwiftSoup.parse(htmlString)
let isReadable = Readability.isProbablyReaderable(document)

if isReadable {
    // Page contains readable content
    let readability = try Readability(html: htmlString)
    let result = try readability.parse()
}
```

## API Reference

### ReadabilityOptions

Configuration options for the Readability parser:

- `debug: Bool` - Enable debug logging
- `maxElemsToParse: Int` - Maximum number of elements to parse (0 = no limit)
- `nbTopCandidates: Int` - Number of top candidate elements to consider
- `charThreshold: Int` - Minimum character count for readable content
- `classesToPreserve: [String]` - CSS classes to preserve in output
- `keepClasses: Bool` - Whether to keep CSS classes in output
- `disableJSONLD: Bool` - Disable JSON-LD metadata extraction

### ReadabilityResult

The result of parsing contains:

- `title: String` - Extracted article title
- `content: String` - Clean HTML content
- `textContent: String` - Plain text content
- `length: Int` - Character count of text content
- `excerpt: String` - Article excerpt/summary
- `byline: String?` - Author information
- `dir: String?` - Text direction (ltr/rtl)
- `siteName: String?` - Site name
- `lang: String?` - Content language
- `publishedTime: String?` - Publication timestamp

### Methods

#### `Readability.init(html:options:)`
Initialize with HTML string and optional configuration.

#### `Readability.init(document:options:)`
Initialize with SwiftSoup Document and optional configuration.

#### `parse() throws -> ReadabilityResult?`
Parse the document and extract readable content.

#### `Readability.isProbablyReaderable(_:options:)`
Static method to check if a document contains readable content.

## Mozilla Test Compatibility

This implementation passes Mozilla's official test cases, including:

- **Test Case 001**: Complex article with proper title extraction
- **Metadata Extraction**: Author, language, direction, site name
- **Readability Detection**: Accurate scoring algorithm
- **Content Cleaning**: Removes navigation, ads, and boilerplate

### Example: Mozilla Test Case 001

```swift
// Input: "Get your Frontend JavaScript Code Covered | Code | Nicolas Perriault"
// Output: "Get your Frontend JavaScript Code Covered" (site name removed)

let html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Get your Frontend JavaScript Code Covered | Code | Nicolas Perriault</title>
    <meta name="author" content="Nicolas Perriault">
</head>
<body>
    <article>
        <h2>Get your Frontend JavaScript Code Covered</h2>
        <p>Article content...</p>
    </article>
</body>
</html>
"""

let result = try Readability(html: html).parse()
// result.title == "Get your Frontend JavaScript Code Covered"
// result.byline == "Nicolas Perriault"
// result.lang == "en"
```

## Testing

The library includes comprehensive tests to ensure compatibility with the JavaScript implementation:

```swift
// Run the built-in test suite
ReadabilityTestRunner.runBasicTests()
```

Test categories include:
- Basic functionality tests
- Metadata extraction validation
- Title cleaning and site name removal
- Readability detection accuracy
- Mozilla test case compatibility
- Edge case handling

## Dependencies

- **SwiftSoup**: HTML parsing and DOM manipulation
- **Foundation**: Core Swift functionality

## Requirements

- Swift 5.9+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## Development & Testing

### Running Tests Locally

```bash
# Clone the repository
git clone https://github.com/tiepvuvan/readability-swift.git
cd readability-swift

# Run all tests
swift test

# Run tests with coverage
swift test --enable-code-coverage

# Run specific test suite
swift test --filter ReadabilitySwiftTests
```

### Continuous Integration

This project uses GitHub Actions for continuous integration:

- **Multi-platform testing**: Tests run on macOS and Linux
- **Swift version compatibility**: Tests against Swift 5.9 and 5.10
- **Platform compatibility**: Validates iOS, macOS, tvOS, and watchOS builds
- **Code coverage**: Tracks test coverage with Codecov
- **Performance testing**: Monitors parsing performance
- **Code quality**: Automated SwiftLint checks

### Quality Assurance

- ✅ **100% Test Coverage Goal**: Comprehensive test suite
- ✅ **Mozilla Compatibility**: Verified against original JavaScript implementation
- ✅ **Performance Benchmarks**: Regular performance regression testing
- ✅ **Static Analysis**: SwiftLint integration for code quality
- ✅ **Cross-platform Testing**: Automated testing across all supported platforms

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`swift test`)
6. Run SwiftLint (`swiftlint`)
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

### Compatibility Commitment

ReadabilitySwift maintains **100% behavioral compatibility** with Mozilla's JavaScript implementation. All contributions must preserve this compatibility.

## Issue Reporting

Found a bug or have a feature request? Please check our [issue templates](.github/ISSUE_TEMPLATE/):

- [🐛 Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
- [✨ Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)

## License

This project maintains compatibility with Mozilla's Readability library. 
Licensed under [Apache 2.0 License](LICENSE) - see the LICENSE file for details.

## Acknowledgments

- **[Mozilla Readability Team](https://github.com/mozilla/readability)**: Original JavaScript implementation
- **[SwiftSoup](https://github.com/scinfu/SwiftSoup)**: HTML parsing library for Swift
- **Mozilla Test Suite**: Comprehensive test cases for validation
- **Contributors**: All the amazing people who help improve this library

## Related Projects

- **[Mozilla Readability](https://github.com/mozilla/readability)**: Original JavaScript implementation
- **[SwiftSoup](https://github.com/scinfu/SwiftSoup)**: Swift HTML parser used by this library
- **[Readability.js](https://github.com/mozilla/readability)**: Official Mozilla implementation

---

**Built with ❤️ for the Swift community**

This Swift port maintains full compatibility with Mozilla's Readability while providing native Swift performance and type safety.