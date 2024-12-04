import Foundation

struct TrainingItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let type: TrainingType
    let sourceId: String  // YouTube ID or article URL
    var isCompleted: Bool
    
    enum TrainingType: String, Codable {
        case video
        case article
    }
}

@MainActor
class TrainingProgressManager: ObservableObject {
    @Published var trainingItems: [TrainingItem]
    private let userDefaults = UserDefaults.standard
    private let storageKey = "trainingProgress"
    
    init() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TrainingItem].self, from: data) {
            self.trainingItems = decoded
        } else {
            // Initialize with all videos and articles
            var items: [TrainingItem] = []
            
            // Add videos
            VideosViewModel.defaultVideos.forEach { video in
                items.append(TrainingItem(
                    id: UUID(),
                    title: video.title,
                    type: .video,
                    sourceId: video.id,
                    isCompleted: false
                ))
            }
            
            // Add articles
            let articles = [
                TrainingItem(
                    id: UUID(),
                    title: "Wake Boat Fit and Finish",
                    type: .article,
                    sourceId: "wake-boat-fit-and-finish",
                    isCompleted: false
                ),
                TrainingItem(
                    id: UUID(),
                    title: "PCM ZZ8s Engine",
                    type: .article,
                    sourceId: "pcm-zz8s",
                    isCompleted: false
                ),
                // Add more articles
            ]
            
            items.append(contentsOf: articles)
            self.trainingItems = items
        }
    }
    
    func toggleCompletion(for item: TrainingItem) {
        if let index = trainingItems.firstIndex(where: { $0.id == item.id }) {
            trainingItems[index].isCompleted.toggle()
            saveProgress()
        }
    }
    
    func markCompleted(videoId: String) {
        if let index = trainingItems.firstIndex(where: { $0.sourceId == videoId }) {
            trainingItems[index].isCompleted = true
            saveProgress()
        }
    }
    
    func markCompleted(articleUrl: String) {
        if let index = trainingItems.firstIndex(where: { $0.sourceId == articleUrl }) {
            trainingItems[index].isCompleted = true
            saveProgress()
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(trainingItems) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }
    
    var completionPercentage: Double {
        guard !trainingItems.isEmpty else { return 0 }
        let completed = trainingItems.filter { $0.isCompleted }.count
        return Double(completed) / Double(trainingItems.count)
    }
    
    var videoItems: [TrainingItem] {
        trainingItems.filter { $0.type == .video }
    }
    
    var articleItems: [TrainingItem] {
        trainingItems.filter { $0.type == .article }
    }
} 