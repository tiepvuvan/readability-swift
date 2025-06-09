import Foundation
import SwiftSoup

// MARK: - Readability Options
public struct ReadabilityOptions {
    public let debug: Bool
    public let maxElemsToParse: Int
    public let nbTopCandidates: Int
    public let charThreshold: Int
    public let classesToPreserve: [String]
    public let keepClasses: Bool
    public let serializer: ((Element) throws -> String)?
    public let disableJSONLD: Bool
    public let allowedVideoRegex: String?
    
    public init(
        debug: Bool = false,
        maxElemsToParse: Int = 0,
        nbTopCandidates: Int = 5,
        charThreshold: Int = 500,
        classesToPreserve: [String] = [],
        keepClasses: Bool = false,
        serializer: ((Element) throws -> String)? = nil,
        disableJSONLD: Bool = false,
        allowedVideoRegex: String? = nil
    ) {
        self.debug = debug
        self.maxElemsToParse = maxElemsToParse
        self.nbTopCandidates = nbTopCandidates
        self.charThreshold = charThreshold
        self.classesToPreserve = classesToPreserve
        self.keepClasses = keepClasses
        self.serializer = serializer
        self.disableJSONLD = disableJSONLD
        self.allowedVideoRegex = allowedVideoRegex
    }
}

// MARK: - Readability Result
public struct ReadabilityResult {
    public let title: String
    public let content: String
    public let textContent: String
    public let length: Int
    public let excerpt: String
    public let byline: String?
    public let dir: String?
    public let siteName: String?
    public let lang: String?
    public let publishedTime: String?
    
    public init(
        title: String,
        content: String,
        textContent: String,
        length: Int,
        excerpt: String,
        byline: String? = nil,
        dir: String? = nil,
        siteName: String? = nil,
        lang: String? = nil,
        publishedTime: String? = nil
    ) {
        self.title = title
        self.content = content
        self.textContent = textContent
        self.length = length
        self.excerpt = excerpt
        self.byline = byline
        self.dir = dir
        self.siteName = siteName
        self.lang = lang
        self.publishedTime = publishedTime
    }
}

// MARK: - Node Candidate Info
internal struct CandidateInfo {
    var contentScore: Double = 0.0
    var element: Element
    
    init(element: Element) {
        self.element = element
    }
}

// MARK: - Readability Constants
internal struct ReadabilityConstants {
    static let maxPages = 5
    static let defaultTagsToScore = "section,h2,h3,h4,h5,h6,p,td,pre"
    static let alterToDIVExceptions = ["div", "article", "section", "p"]
    static let presentationalAttributes = ["align", "background", "bgcolor", "border", "cellpadding", "cellspacing", "frame", "hspace", "rules", "style", "valign", "vspace"]
    static let deprecatedSizeAttributeElems = ["table", "th", "td", "hr", "pre"]
    
    // Regular expressions
    static let regexps = [
        "unlikelyCandidates": "/-ad-|ai2html|banner|breadcrumbs|combx|comment|community|cover-wrap|disqus|extra|footer|gdpr|header|legends|menu|related|remark|replies|rss|shoutbox|sidebar|skyscraper|social|sponsor|supplemental|ad-break|agegate|pagination|pager|popup|yom-remote/i",
        "okMaybeItsACandidate": "/and|article|body|column|content|main|shadow/i",
        "positive": "/article|body|content|entry|hentry|h-entry|main|page|pagination|post|text|blog|story/i",
        "negative": "/-ad-|hidden|^hid$|hid$|hid |^hid |banner|combx|comment|com-|contact|foot|footer|footnote|gdpr|masthead|media|meta|outbrain|promo|related|scroll|share|shoutbox|sidebar|skyscraper|sponsor|shopping|tags|tool|widget/i",
        "extraneous": "/print|archive|comment|discuss|e[\\-]?mail|share|reply|all|login|sign|single|utility/i",
        "byline": "/byline|author|dateline|writtenby|p-author/i",
        "replaceFonts": "/<(\\/?)font[^>]*>/gi",
        "normalize": "/\\s{2,}/g",
        "videos": "/\\/\\/(www\\.)?(dailymotion|youtube|youtube-nocookie|player\\.vimeo|v\\.qq)\\.com/i",
        "shareElements": "/(\\\\b|_)(share|sharedaddy)(\\\\b|_)/i",
        "nextLink": "/(next|weiter|continue|>([^\\|]|$)|»([^\\|]|$))/i",
        "prevLink": "/(prev|earl|old|new|<|«)/i",
        "tokenize": "/\\W+/g",
        "whitespace": "/^\\s*$/",
        "hasContent": "/\\S$/"
    ]
}

// MARK: - Main Readability Class
public class Readability {
    internal let document: Document
    internal let options: ReadabilityOptions
    internal var articleTitle: String = ""
    internal var articleByline: String?
    internal var articleDir: String?
    internal var articleSiteName: String?
    internal var articleLang: String?
    internal var articlePublishedTime: String?
    private var attempts: [Element] = []
    internal var elemsToParse = 0
    private var candidates: [String: CandidateInfo] = [:]
    
    public init(document: Document, options: ReadabilityOptions = ReadabilityOptions()) throws {
        self.document = document
        self.options = options
        self._removeScripts()
        self._extractMetadata()
        self._prepDocument()
    }
    
    public convenience init(html: String, options: ReadabilityOptions = ReadabilityOptions()) throws {
        let document = try SwiftSoup.parse(html)
        try self.init(document: document, options: options)
    }
    
    public convenience init(html: String, baseUri: String, options: ReadabilityOptions = ReadabilityOptions()) throws {
        let document = try SwiftSoup.parse(html, baseUri)
        try self.init(document: document, options: options)
    }
}

// MARK: - Public API
extension Readability {
    public func parse() throws -> ReadabilityResult? {
        // Check element count upfront like JavaScript version
        if options.maxElemsToParse > 0 {
            let allElementsCount = try document.getAllElements().count
            if allElementsCount > options.maxElemsToParse {
                throw ReadabilityError.tooManyElements(allElementsCount)
            }
        }
        
        if options.debug {
            print("Starting to parse document...")
        }
        
        _removeUnlikelyCandidates()
        _transformMisusedDivsIntoParagraphs()
        
        let candidates = _getCandidates()
        let topCandidate = _getTopCandidate(candidates: candidates)
        
        guard let topCandidate = topCandidate else {
            return nil
        }
        
        let articleContent = _getArticleContent(topCandidate: topCandidate, candidates: candidates)
        let cleanedContent = _cleanConditionally(element: articleContent, tag: "form")
        
        try _postProcessContent(cleanedContent)
        
        let textContent = try cleanedContent.text()
        
        return ReadabilityResult(
            title: articleTitle.isEmpty ? _getArticleTitle() : articleTitle,
            content: try cleanedContent.outerHtml(),
            textContent: textContent,
            length: textContent.count,
            excerpt: _getExcerpt(textContent: textContent),
            byline: articleByline,
            dir: articleDir,
            siteName: articleSiteName,
            lang: articleLang,
            publishedTime: articlePublishedTime
        )
    }
    
}

// MARK: - Readability Error
public enum ReadabilityError: Error {
    case tooManyElements(Int)
    case parsingFailed(String)
    case invalidDocument
}