import Foundation
import SwiftSoup

// MARK: - Metadata Extraction Extension
extension Readability {
    
    // MARK: - JSON-LD Extraction
    internal func _getJSONLD() -> [String: Any]? {
        if options.disableJSONLD {
            return nil
        }
        
        do {
            let scripts = try document.select("script[type=\"application/ld+json\"]")
            
            for script in scripts {
                let jsonText = try script.html().trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let data = jsonText.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return json
                }
            }
        } catch {
            if options.debug {
                print("Error extracting JSON-LD: \(error)")
            }
        }
        
        return nil
    }
    
    // MARK: - Article Metadata Extraction
    internal func _extractMetadata() {
        _extractTitle()
        _extractByline()
        _extractDir()
        _extractSiteName()
        _extractLanguage()
        _extractPublishedTime()
    }
    
    internal func _extractTitle() {
        do {
            // Try Open Graph title first
            if let ogTitle = try document.select("meta[property=\"og:title\"]").first() {
                let content = try ogTitle.attr("content")
                if !content.isEmpty {
                    articleTitle = content
                    return
                }
            }
            
            // Try Twitter title
            if let twitterTitle = try document.select("meta[name=\"twitter:title\"]").first() {
                let content = try twitterTitle.attr("content")
                if !content.isEmpty {
                    articleTitle = content
                    return
                }
            }
            
            // Try DC title
            if let dcTitle = try document.select("meta[name=\"DC.title\"]").first() {
                let content = try dcTitle.attr("content")
                if !content.isEmpty {
                    articleTitle = content
                    return
                }
            }
            
            // Use document title as fallback, but clean it
            if let titleElement = try document.select("title").first() {
                articleTitle = _cleanTitle(try titleElement.text())
            }
        } catch {
            if options.debug {
                print("Error extracting title: \(error)")
            }
        }
    }
    
    private func _cleanTitle(_ title: String) -> String {
        var cleanedTitle = title
        
        // Remove common separators and site names from title
        let separators = [" | ", " - ", " :: ", " · ", " • ", " — ", " – ", " / "]
        
        for separator in separators {
            if cleanedTitle.contains(separator) {
                let parts = cleanedTitle.components(separatedBy: separator)
                if parts.count >= 2 {
                    // Usually the first part is the article title
                    let firstPart = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let lastPart = parts[parts.count - 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Choose the longer part as it's likely the article title
                    if firstPart.count > lastPart.count {
                        cleanedTitle = firstPart
                    } else if parts.count > 2 {
                        // If there are multiple separators, take the first part
                        cleanedTitle = firstPart
                    }
                    break
                }
            }
        }
        
        return cleanedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    internal func _extractByline() {
        do {
            // Try JSON-LD first
            if let jsonLD = _getJSONLD(),
               let author = jsonLD["author"] as? [String: Any],
               let name = author["name"] as? String {
                articleByline = name
                return
            }
            
            // Try meta tags
            let authorSelectors = [
                "meta[name=\"author\"]",
                "meta[name=\"article:author\"]",
                "meta[name=\"article:author_name\"]",
                "meta[name=\"DC.creator\"]",
                "meta[property=\"article:author\"]"
            ]
            
            for selector in authorSelectors {
                if let authorMeta = try document.select(selector).first() {
                    let content = try authorMeta.attr("content")
                    if !content.isEmpty {
                        articleByline = content
                        return
                    }
                }
            }
            
            // Try to find byline in content using regex
            if let bylineRegex = try? NSRegularExpression(pattern: String(ReadabilityConstants.regexps["byline"]!.dropFirst().dropLast(2)), options: [.caseInsensitive]) {
                let allElements = try document.getAllElements()
                
                for element in allElements {
                    let className = try element.attr("class")
                    let elementId = try element.attr("id")
                    let rel = try element.attr("rel")
                    
                    if bylineRegex.firstMatch(in: "\(className) \(elementId) \(rel)", options: [], range: NSRange(location: 0, length: "\(className) \(elementId) \(rel)".count)) != nil {
                        let text = try element.text().trimmingCharacters(in: .whitespacesAndNewlines)
                        if text.count > 0 && text.count < 100 {
                            articleByline = text
                            return
                        }
                    }
                }
            }
        } catch {
            if options.debug {
                print("Error extracting byline: \(error)")
            }
        }
    }
    
    internal func _extractDir() {
        do {
            // Check document dir attribute
            if let htmlElement = try document.select("html").first() {
                let dir = try htmlElement.attr("dir")
                if ["ltr", "rtl"].contains(dir.lowercased()) {
                    articleDir = dir.lowercased()
                    return
                }
            }
            
            // Check body dir attribute
            if let bodyElement = try document.select("body").first() {
                let dir = try bodyElement.attr("dir")
                if ["ltr", "rtl"].contains(dir.lowercased()) {
                    articleDir = dir.lowercased()
                    return
                }
            }
            
            // Try meta tag
            if let dirMeta = try document.select("meta[name=\"direction\"]").first() {
                let content = try dirMeta.attr("content").lowercased()
                if ["ltr", "rtl"].contains(content) {
                    articleDir = content
                }
            }
        } catch {
            if options.debug {
                print("Error extracting direction: \(error)")
            }
        }
    }
    
    internal func _extractSiteName() {
        do {
            // Try Open Graph site name
            if let ogSiteName = try document.select("meta[property=\"og:site_name\"]").first() {
                let content = try ogSiteName.attr("content")
                if !content.isEmpty {
                    articleSiteName = content
                    return
                }
            }
            
            // Try application name
            if let appName = try document.select("meta[name=\"application-name\"]").first() {
                let content = try appName.attr("content")
                if !content.isEmpty {
                    articleSiteName = content
                    return
                }
            }
            
            // Try DC publisher
            if let dcPublisher = try document.select("meta[name=\"DC.publisher\"]").first() {
                let content = try dcPublisher.attr("content")
                if !content.isEmpty {
                    articleSiteName = content
                }
            }
        } catch {
            if options.debug {
                print("Error extracting site name: \(error)")
            }
        }
    }
    
    internal func _extractLanguage() {
        do {
            // Check html lang attribute
            if let htmlElement = try document.select("html").first() {
                let lang = try htmlElement.attr("lang")
                if !lang.isEmpty {
                    articleLang = lang
                    return
                }
            }
            
            // Try meta tags
            let langSelectors = [
                "meta[name=\"language\"]",
                "meta[http-equiv=\"content-language\"]",
                "meta[name=\"DC.language\"]"
            ]
            
            for selector in langSelectors {
                if let langMeta = try document.select(selector).first() {
                    let content = try langMeta.attr("content")
                    if !content.isEmpty {
                        articleLang = content
                        return
                    }
                }
            }
        } catch {
            if options.debug {
                print("Error extracting language: \(error)")
            }
        }
    }
    
    internal func _extractPublishedTime() {
        do {
            // Try JSON-LD first
            if let jsonLD = _getJSONLD() {
                if let datePublished = jsonLD["datePublished"] as? String {
                    articlePublishedTime = datePublished
                    return
                }
                
                if let dateCreated = jsonLD["dateCreated"] as? String {
                    articlePublishedTime = dateCreated
                    return
                }
            }
            
            // Try meta tags
            let dateSelectors = [
                "meta[name=\"article:published_time\"]",
                "meta[property=\"article:published_time\"]",
                "meta[name=\"article:modified_time\"]",
                "meta[property=\"article:modified_time\"]",
                "meta[name=\"pubdate\"]",
                "meta[name=\"DC.date\"]",
                "meta[name=\"date\"]",
                "meta[name=\"DC.date.created\"]"
            ]
            
            for selector in dateSelectors {
                if let dateMeta = try document.select(selector).first() {
                    let content = try dateMeta.attr("content")
                    if !content.isEmpty {
                        articlePublishedTime = content
                        return
                    }
                }
            }
            
            // Try time elements with datetime attribute
            if let timeElement = try document.select("time[datetime]").first() {
                let datetime = try timeElement.attr("datetime")
                if !datetime.isEmpty {
                    articlePublishedTime = datetime
                }
            }
        } catch {
            if options.debug {
                print("Error extracting published time: \(error)")
            }
        }
    }
}

// MARK: - Enhanced Readability Detection
extension Readability {
    
    public static func isProbablyReaderable(_ document: Document, options: ReadabilityOptions = ReadabilityOptions()) -> Bool {
        let minScore = 20.0
        let minContentLength = 140
        
        do {
            var score = 0.0
            
            // Get nodes to check - p, pre, article, and divs with br tags
            let paragraphs = try document.select("p")
            let pres = try document.select("pre")  
            let articles = try document.select("article")
            let divsWithBr = try document.select("div").filter { div in
                do {
                    return try div.select("br").count > 0
                } catch {
                    return false
                }
            }
            
            let allNodes = paragraphs.array() + pres.array() + articles.array() + divsWithBr
            
            // Check each node
            for node in allNodes {
                let innerText = try node.text().trimmingCharacters(in: .whitespacesAndNewlines)
                let textContentLength = innerText.count
                
                // Skip if too short
                if textContentLength < minContentLength {
                    continue
                }
                
                // Check if this node should be excluded based on class/id
                let className = try node.attr("class").lowercased()
                let nodeId = try node.attr("id").lowercased()
                let classAndId = "\(className) \(nodeId)"
                
                // Skip unlikely candidates (similar to JavaScript regex)
                if _isUnlikelyCandidate(classAndId) && !_isOkayCandidate(classAndId) {
                    continue
                }
                
                // Skip if it's a paragraph inside a list item
                if node.tagName() == "p" && node.parent()?.tagName() == "li" {
                    continue
                }
                
                // Add to score using JavaScript formula
                let contentScore = Double(textContentLength - minContentLength).squareRoot()
                score += contentScore
                
            }
            
            return score >= minScore
        } catch {
            return false
        }
    }
    
    private static func _isUnlikelyCandidate(_ classAndId: String) -> Bool {
        let unlikelyPattern = "banner|breadcrumbs|combx|comment|community|cover-wrap|disqus|extra|footer|gdpr|header|legends|menu|related|remark|replies|rss|shoutbox|sidebar|skyscraper|social|sponsor|supplemental|ad-break|agegate|pagination|pager|popup|yom-remote"
        
        let regex = try? NSRegularExpression(pattern: unlikelyPattern, options: [.caseInsensitive])
        return regex?.firstMatch(in: classAndId, options: [], range: NSRange(location: 0, length: classAndId.count)) != nil
    }
    
    private static func _isOkayCandidate(_ classAndId: String) -> Bool {
        let okayPattern = "and|article|body|column|content|main|shadow"
        
        let regex = try? NSRegularExpression(pattern: okayPattern, options: [.caseInsensitive])
        return regex?.firstMatch(in: classAndId, options: [], range: NSRange(location: 0, length: classAndId.count)) != nil
    }
}