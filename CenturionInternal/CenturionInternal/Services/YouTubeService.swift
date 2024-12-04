import Foundation

class YouTubeService {
    private let apiKey = "AIzaSyBzwqxLH_F_AYCsL_DVLqzzu-sWB5ue6A0"
    private let channelId = "UCoXqN7tF_HXqREgTD4CA-3w"
    
    func fetchLatestVideos() async throws -> [YouTubeVideo] {
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(channelId)&maxResults=50&order=date&type=video&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(YouTubeResponse.self, from: data)
        
        return response.items.map { item in
            YouTubeVideo(
                id: item.id.videoId,
                title: item.snippet.title,
                description: item.snippet.description,
                thumbnailURL: item.snippet.thumbnails.high.url,
                publishedAt: ISO8601DateFormatter().date(from: item.snippet.publishedAt) ?? Date()
            )
        }
    }
}

// Response structures
private struct YouTubeResponse: Codable {
    let items: [YouTubeItem]
}

private struct YouTubeItem: Codable {
    let id: VideoId
    let snippet: Snippet
}

private struct VideoId: Codable {
    let videoId: String
}

private struct Snippet: Codable {
    let title: String
    let description: String
    let publishedAt: String
    let thumbnails: Thumbnails
}

private struct Thumbnails: Codable {
    let high: Thumbnail
}

private struct Thumbnail: Codable {
    let url: String
} 