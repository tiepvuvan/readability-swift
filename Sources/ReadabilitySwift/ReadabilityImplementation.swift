import Foundation
import SwiftSoup

// MARK: - Private Implementation
extension Readability {
    
    // MARK: - Document Preparation
    // swiftlint:disable:next identifier_name
    internal func _removeScripts() {
        do {
            let scripts = try document.select("script")
            for script in scripts {
                try script.remove()
            }
            
            let noscripts = try document.select("noscript")
            for noscript in noscripts {
                try noscript.remove()
            }
        } catch {
            if options.debug {
                print("Error removing scripts: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _prepDocument() {
        do {
            _unwrapNoscriptImages()
            _removeUnlikelyCandidates()
            _transformMisusedDivsIntoParagraphs()
            
            let replaceBrsRegex = try NSRegularExpression(pattern: "(<br[^>]*>[ \\n\\r\\t]*){2,}", options: [.caseInsensitive])
            let documentHtml = try document.html()
            let processedHtml = replaceBrsRegex.stringByReplacingMatches(in: documentHtml, options: [], range: NSRange(location: 0, length: documentHtml.count), withTemplate: "</p><p>")
            
            try document.html(processedHtml)
        } catch {
            if options.debug {
                print("Error preparing document: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _unwrapNoscriptImages() {
        do {
            let imgs = try document.select("img")
            for img in imgs {
                for node in img.getChildNodes() {
                    if let element = node as? Element, element.tagName() == "noscript" {
                        let tmp = try SwiftSoup.parseBodyFragment(element.html())
                        let tmpImgs = try tmp.select("img")
                        
                        for tmpImg in tmpImgs {
                            if tmpImg.hasAttr("src") || tmpImg.hasAttr("srcset") || tmpImg.hasAttr("data-src") {
                                try img.replaceWith(tmpImg)
                                break
                            }
                        }
                    }
                }
            }
        } catch {
            if options.debug {
                print("Error unwrapping noscript images: \(error)")
            }
        }
    }
    
    // MARK: - Candidate Selection
    // swiftlint:disable:next identifier_name
    internal func _removeUnlikelyCandidates() {
        do {
            if let regex = try? NSRegularExpression(pattern: String(ReadabilityConstants.regexps["unlikelyCandidates"]!.dropFirst().dropLast(2)), options: [.caseInsensitive]) {
                let allElements = try document.getAllElements()
                
                for element in allElements {
                    let className = try element.attr("class")
                    let elementId = try element.attr("id")
                    let matchString = "\(className) \(elementId)"
                    
                    if regex.firstMatch(in: matchString, options: [], range: NSRange(location: 0, length: matchString.count)) != nil {
                        if let okayRegex = try? NSRegularExpression(pattern: String(ReadabilityConstants.regexps["okMaybeItsACandidate"]!.dropFirst().dropLast(2)), options: [.caseInsensitive]),
                           okayRegex.firstMatch(in: matchString, options: [], range: NSRange(location: 0, length: matchString.count)) == nil {
                            try element.remove()
                        }
                    }
                }
            }
        } catch {
            if options.debug {
                print("Error removing unlikely candidates: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _transformMisusedDivsIntoParagraphs() {
        do {
            let divs = try document.select("div")
            
            for div in divs {
                if _hasSingleTagInside(element: div, tagName: "p") ||
                   _hasSingleTagInside(element: div, tagName: "a") ||
                   _hasSingleTagInside(element: div, tagName: "span") ||
                   _hasSingleTagInside(element: div, tagName: "img") ||
                   _hasSingleTagInside(element: div, tagName: "ul") ||
                   _hasSingleTagInside(element: div, tagName: "ol") {
                    continue
                }
                
                let divText = try div.text()
                if divText.range(of: "<(a|blockquote|dl|div|img|ol|p|pre|table|ul|select)", options: .regularExpression) == nil {
                    try div.tagName("p")
                }
            }
        } catch {
            if options.debug {
                print("Error transforming divs: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _hasSingleTagInside(element: Element, tagName: String) -> Bool {
        do {
            return try element.select(tagName).count == 1 && element.text().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Candidate Scoring
    // swiftlint:disable:next identifier_name
    internal func _getCandidates() -> [String: CandidateInfo] {
        var candidates: [String: CandidateInfo] = [:]
        
        do {
            let elementsToScore = try document.select(ReadabilityConstants.defaultTagsToScore)
            
            for element in elementsToScore {
                let innerText = try element.text()
                
                if innerText.count < 25 {
                    continue
                }
                
                _ = element
                var candidateScore = 0.0
                
                candidateScore += 1
                candidateScore += Double(innerText.count / 100)
                candidateScore += _getClassWeight(element: element)
                
                var parentNode = element.parent()
                var level = 0
                
                while let parent = parentNode, level < 3 {
                    if candidates[try _getElementId(parent)] == nil {
                        candidates[try _getElementId(parent)] = CandidateInfo(element: parent)
                    }
                    
                    let scoreToAdd = candidateScore / Double(level + 1)
                    candidates[try _getElementId(parent)]!.contentScore += scoreToAdd
                    
                    parentNode = parent.parent()
                    level += 1
                }
            }
        } catch {
            if options.debug {
                print("Error getting candidates: \(error)")
            }
        }
        
        return candidates
    }
    
    // swiftlint:disable:next identifier_name
    internal func _getTopCandidate(candidates: [String: CandidateInfo]) -> Element? {
        var topCandidate: CandidateInfo?
        var topScore = 0.0
        
        for (_, candidate) in candidates {
            let score = candidate.contentScore * (1 - _getLinkDensity(element: candidate.element))
            
            if score > topScore {
                topCandidate = candidate
                topScore = score
            }
        }
        
        return topCandidate?.element
    }
    
    // swiftlint:disable:next identifier_name
    internal func _getClassWeight(element: Element) -> Double {
        var weight = 0.0
        
        do {
            let className = try element.attr("class")
            let elementId = try element.attr("id")
            
            if let positiveRegex = try? NSRegularExpression(pattern: String(ReadabilityConstants.regexps["positive"]!.dropFirst().dropLast(2)), options: [.caseInsensitive]) {
                if positiveRegex.firstMatch(in: className, options: [], range: NSRange(location: 0, length: className.count)) != nil ||
                   positiveRegex.firstMatch(in: elementId, options: [], range: NSRange(location: 0, length: elementId.count)) != nil {
                    weight += 25
                }
            }
            
            if let negativeRegex = try? NSRegularExpression(pattern: String(ReadabilityConstants.regexps["negative"]!.dropFirst().dropLast(2)), options: [.caseInsensitive]) {
                if negativeRegex.firstMatch(in: className, options: [], range: NSRange(location: 0, length: className.count)) != nil ||
                   negativeRegex.firstMatch(in: elementId, options: [], range: NSRange(location: 0, length: elementId.count)) != nil {
                    weight -= 25
                }
            }
        } catch {
            if options.debug {
                print("Error calculating class weight: \(error)")
            }
        }
        
        return weight
    }
    
    // swiftlint:disable:next identifier_name
    internal func _getLinkDensity(element: Element) -> Double {
        do {
            let textLength = try element.text().count
            if textLength == 0 {
                return 0
            }
            
            let links = try element.select("a")
            var linkLength = 0
            
            for link in links {
                let href = try link.attr("href")
                if href.count > 0 && !href.hasPrefix("#") {
                    linkLength += try link.text().count
                }
            }
            
            return Double(linkLength) / Double(textLength)
        } catch {
            return 0
        }
    }
    
    // MARK: - Content Extraction
    // swiftlint:disable:next identifier_name
    internal func _getArticleContent(topCandidate: Element, candidates: [String: CandidateInfo]) -> Element {
        do {
            let articleContent = try Element(Tag.valueOf("div"), "")
            let siblingScoreThreshold = max(10.0, candidates[try _getElementId(topCandidate)]?.contentScore ?? 0 * 0.2)
            
            if let parent = topCandidate.parent() {
                let siblings = parent.children()
                
                for sibling in siblings {
                    var append = false
                    
                    if sibling == topCandidate {
                        append = true
                    } else if let candidateInfo = candidates[try _getElementId(sibling)],
                              candidateInfo.contentScore >= siblingScoreThreshold {
                        append = true
                    } else if sibling.tagName() == "p" {
                        let linkDensity = _getLinkDensity(element: sibling)
                        let siblingText = try sibling.text()
                        
                        if siblingText.count > 80 && linkDensity < 0.25 {
                            append = true
                        } else if siblingText.count < 80 && linkDensity == 0 && siblingText.range(of: "\\.( |$)") != nil {
                            append = true
                        }
                    }
                    
                    if append {
                        if !ReadabilityConstants.alterToDIVExceptions.contains(sibling.tagName()) {
                            try sibling.tagName("div")
                        }
                        try articleContent.appendChild(sibling)
                    }
                }
            }
            
            return articleContent
        } catch {
            if options.debug {
                print("Error getting article content: \(error)")
            }
            return topCandidate
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _cleanConditionally(element: Element, tag: String) -> Element {
        do {
            let elements = try element.select(tag)
            
            for el in elements {
                let weight = _getClassWeight(element: el)
                
                if options.debug {
                    let className = try el.attr("class")
                    let elementId = try el.attr("id")
                    print("Cleaning conditionally \(tag) (\(className):\(elementId)) with weight \(weight)")
                }
                
                if weight < 0 {
                    try el.remove()
                }
            }
        } catch {
            if options.debug {
                print("Error cleaning conditionally: \(error)")
            }
        }
        
        return element
    }
    
    // MARK: - Post Processing
    // swiftlint:disable:next identifier_name
    internal func _postProcessContent(_ articleContent: Element) throws {
        _fixRelativeUris(articleContent)
        _simplifyNestedElements(articleContent)
        
        if !options.keepClasses {
            try _cleanClasses(articleContent)
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _fixRelativeUris(_ articleContent: Element) {
        do {
            let baseUri = ""
            if baseUri.isEmpty {
                return
            }
            
            let links = try articleContent.select("a[href]")
            for link in links {
                let href = try link.attr("href")
                if let url = URL(string: href, relativeTo: URL(string: baseUri)) {
                    try link.attr("href", url.absoluteString)
                }
            }
            
            let imgs = try articleContent.select("img[src]")
            for img in imgs {
                let src = try img.attr("src")
                if let url = URL(string: src, relativeTo: URL(string: baseUri)) {
                    try img.attr("src", url.absoluteString)
                }
            }
        } catch {
            if options.debug {
                print("Error fixing relative URIs: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _simplifyNestedElements(_ articleContent: Element) {
        do {
            let elements = try articleContent.select("div")
            
            for element in elements {
                if element.children().count == 1 && element.children().first()?.tagName() == "div" {
                    if let child = element.children().first() {
                        try element.replaceWith(child)
                    }
                }
            }
        } catch {
            if options.debug {
                print("Error simplifying nested elements: \(error)")
            }
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _cleanClasses(_ articleContent: Element) throws {
        let allElements = try articleContent.getAllElements()
        
        for element in allElements {
            let className = try element.attr("class")
            if !options.classesToPreserve.contains(where: { className.contains($0) }) {
                try element.removeAttr("class")
            }
            
            try element.removeAttr("id")
            
            for attr in ReadabilityConstants.presentationalAttributes {
                try element.removeAttr(attr)
            }
        }
    }
    
    // MARK: - Metadata Extraction
    // swiftlint:disable:next identifier_name
    internal func _getArticleTitle() -> String {
        do {
            var title = ""
            var originalTitle = ""
            
            if let titleElement = try document.select("title").first() {
                originalTitle = try titleElement.text()
                title = originalTitle
            }
            
            let h1s = try document.select("h1")
            if h1s.count == 1 {
                let h1Text = try h1s.first()!.text()
                if h1Text.count > 0 && originalTitle.count > 0 {
                    if h1Text.count < originalTitle.count * 2 && originalTitle.count < h1Text.count * 2 {
                        title = h1Text
                    }
                }
            }
            
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return ""
        }
    }
    
    // swiftlint:disable:next identifier_name
    internal func _getExcerpt(textContent: String) -> String {
        let paragraphs = textContent.components(separatedBy: "\n\n")
        
        for paragraph in paragraphs {
            let cleanParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanParagraph.count > 80 {
                return String(cleanParagraph.prefix(250))
            }
        }
        
        return String(textContent.prefix(250))
    }
    
    // MARK: - Utility Methods
    // swiftlint:disable:next identifier_name
    internal func _getElementId(_ element: Element) throws -> String {
        let className = try element.attr("class")
        let elementId = try element.attr("id")
        return "\(element.tagName())#\(elementId).\(className)"
    }
}