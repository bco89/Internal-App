import Foundation

struct YouTubeVideo: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let publishedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case thumbnailURL = "thumbnailUrl"
        case publishedAt
    }
    
    init(id: String, title: String, description: String, thumbnailURL: String, publishedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.publishedAt = publishedAt
    }
} 