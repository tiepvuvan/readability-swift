---
name: Bug report
about: Create a report to help us improve ReadabilitySwift
title: '[BUG] '
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Create HTML content with '...'
2. Call Readability with options '...'
3. Parse the content with '...'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Code Example**
```swift
let html = """
<!-- Your HTML content here -->
"""

let options = ReadabilityOptions(
    // Your options here
)

let readability = try Readability(html: html, options: options)
let result = try readability.parse()
```

**Actual vs Expected Results**
- **Actual Result**: What ReadabilitySwift extracted
- **Expected Result**: What should have been extracted
- **JavaScript Comparison**: If you tested with Mozilla's JS version, include those results

**Environment:**
 - OS: [e.g. iOS 17.0, macOS 14.0]
 - Xcode Version: [e.g. 15.0]
 - Swift Version: [e.g. 5.9]
 - ReadabilitySwift Version: [e.g. 1.0.0]

**HTML Sample**
If possible, provide a minimal HTML sample that reproduces the issue:

```html
<!-- Paste your HTML here -->
```

**Additional context**
Add any other context about the problem here. If this relates to a specific website or article, please provide the URL if publicly accessible.