# Contributing to ReadabilitySwift

We love your input! We want to make contributing to ReadabilitySwift as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## Code Style

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and use SwiftLint to enforce consistency.

Key points:
- Use meaningful names for types, functions, and variables
- Prefer clarity over brevity in naming
- Use camelCase for variables and functions
- Use PascalCase for types
- Keep line length under 120 characters when possible
- Use meaningful comments for complex logic

### Code Organization

- **Public API**: Keep the public interface clean and intuitive
- **Internal Implementation**: Mark internal helpers as `internal` or `private`
- **Error Handling**: Use Swift's error handling patterns
- **Documentation**: Include doc comments for public APIs

## Mozilla Readability Compatibility

**Critical**: ReadabilitySwift aims to maintain 100% behavioral compatibility with Mozilla's JavaScript Readability library.

### Before Making Changes

1. **Understand the JavaScript behavior**: Test your changes against the original Mozilla implementation
2. **Verify compatibility**: Ensure your changes don't break existing behavior
3. **Add tests**: Include tests that verify compatibility with expected JavaScript output

### Compatibility Guidelines

- All parsing results should match JavaScript output
- All configuration options should behave identically
- Error conditions should occur at the same points
- Performance should be comparable or better

## Testing

### Running Tests

```bash
# Run all tests
swift test

# Run tests with coverage
swift test --enable-code-coverage

# Run specific test
swift test --filter ReadabilitySwiftTests.testSpecificFunction

# Run performance tests
swift test --filter ReadabilitySwiftTests.testParsingPerformance
```

### Test Organization

- **Unit Tests**: Test individual functions and methods
- **Integration Tests**: Test complete parsing workflows
- **Mozilla Compatibility Tests**: Verify against JavaScript behavior
- **Performance Tests**: Ensure performance meets expectations
- **Edge Case Tests**: Handle malformed HTML and unusual content

### Adding Tests

When adding new functionality:

1. **Write tests first** (TDD approach recommended)
2. **Test both success and failure cases**
3. **Include Mozilla compatibility tests** if applicable
4. **Add performance tests** for parsing-heavy features
5. **Test cross-platform compatibility**

Example test structure:
```swift
func testNewFeature() throws {
    // Arrange
    let html = createTestHTML()
    let options = ReadabilityOptions(newFeature: true)
    
    // Act
    let readability = try Readability(html: html, options: options)
    let result = try readability.parse()
    
    // Assert
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.expectedProperty, "expectedValue")
}
```

## Reporting Bugs

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/your-username/ReadabilitySwift/issues).

### Bug Report Requirements

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample HTML if possible
- What you expected would happen
- What actually happens
- Comparison with Mozilla's JavaScript implementation (if applicable)
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

### Sample HTML for Bug Reports

When reporting parsing issues, please provide:
- Minimal HTML that reproduces the issue
- Expected extraction result
- Actual ReadabilitySwift result
- JavaScript Readability result (if available)

## Feature Requests

We actively welcome feature requests! Please use the Feature Request template and consider:

1. **Mozilla Compatibility**: Does this feature exist in the JavaScript version?
2. **Use Case**: What specific problem does this solve?
3. **Breaking Changes**: Will this require API changes?
4. **Performance Impact**: Could this affect parsing performance?

## Code Review Process

1. **Automated Checks**: All PRs must pass CI/CD tests
2. **Manual Review**: Core maintainers will review your code
3. **Compatibility Verification**: We may test against Mozilla's implementation
4. **Documentation Review**: Ensure documentation is updated
5. **Performance Review**: Large changes may need performance testing

### Review Criteria

- **Correctness**: Does the code work as intended?
- **Compatibility**: Does it maintain Mozilla compatibility?
- **Performance**: Does it meet performance requirements?
- **Testing**: Are there adequate tests?
- **Documentation**: Is the code well-documented?
- **Style**: Does it follow project conventions?

## Release Process

1. **Version Bumping**: Follow semantic versioning
2. **Changelog**: Update CHANGELOG.md
3. **Testing**: Full test suite must pass
4. **Documentation**: Update README if needed
5. **Compatibility**: Verify against latest Mozilla version

## Development Setup

### Prerequisites

- Xcode 15.0+ (for macOS development)
- Swift 5.9+
- SwiftLint (install via `brew install swiftlint`)

### Local Development

```bash
# Clone the repository
git clone https://github.com/your-username/ReadabilitySwift.git
cd ReadabilitySwift

# Build the project
swift build

# Run tests
swift test

# Run linting
swiftlint

# Run performance tests
swift test --filter Performance
```

### Debugging

For debugging parsing issues:

1. **Enable debug mode**: Use `ReadabilityOptions(debug: true)`
2. **Add test cases**: Create minimal reproduction cases
3. **Compare with JavaScript**: Test the same HTML with Mozilla's library
4. **Use logging**: Add strategic print statements for complex logic

## Community

### Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and community chat
- **Documentation**: Check the README and API documentation first

### Code of Conduct

This project follows a standard Code of Conduct. Be respectful, inclusive, and constructive in all interactions.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Apache 2.0, maintaining compatibility with Mozilla's Readability).

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- CHANGELOG.md for significant contributions
- README.md for major features or fixes

Thank you for contributing to ReadabilitySwift! 🎉