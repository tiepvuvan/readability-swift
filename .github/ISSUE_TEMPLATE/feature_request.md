---
name: Feature request
about: Suggest an idea for ReadabilitySwift
title: '[FEATURE] '
labels: enhancement
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Mozilla Readability Compatibility**
- [ ] This feature exists in Mozilla's JavaScript Readability library
- [ ] This is a Swift-specific enhancement
- [ ] This is a new feature not in the original library

**Use Case**
Provide a specific use case for this feature:
- What type of content would this help with?
- What platforms would benefit?
- How would this improve the extraction quality?

**Code Example (if applicable)**
```swift
// Example of how you'd like to use this feature
let options = ReadabilityOptions(
    newFeature: true,
    newParameter: "value"
)

let readability = try Readability(html: html, options: options)
let result = try readability.parse()
// Expected new functionality
```

**Additional context**
Add any other context, screenshots, or examples about the feature request here.