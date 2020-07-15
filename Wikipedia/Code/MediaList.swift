public struct MediaListItemSource: Codable {
    public let urlString: String
    public let scale: String
    
    enum CodingKeys: String, CodingKey {
        case urlString = "src"
        case scale
    }

    public init (urlString: String, scale: String) {
        self.urlString = urlString
        self.scale = scale
    }
}

public enum MediaListItemType: String {
    case image
    case audio
    case video
}

public struct MediaListItem: Codable {
    public let title: String?
    public let sectionID: Int
    public let type: String
    public let showInGallery: Bool
    public let sources: [MediaListItemSource]?
    public let audioType: String?
    enum CodingKeys: String, CodingKey {
        case title
        case sectionID = "section_id"
        case showInGallery
        case sources = "srcset"
        case type
        case audioType
    }

    public init(title: String?, sectionID: Int, type: String, showInGallery: Bool, sources: [MediaListItemSource]?, audioType: String? = nil) {
        self.title = title
        self.sectionID = sectionID
        self.type = type
        self.showInGallery = showInGallery
        self.sources = sources
        self.audioType = audioType
    }
}

extension MediaListItem {
    public var itemType: MediaListItemType? {
        return MediaListItemType(rawValue: type)
    }
}

public struct MediaList: Codable {
    public let items: [MediaListItem]

    public init(items: [MediaListItem]) {
        self.items = items
    }
}
