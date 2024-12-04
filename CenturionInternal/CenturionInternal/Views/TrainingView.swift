import SwiftUI
import WebKit
import Foundation

struct TrainingView: View {
    @StateObject private var progressManager = TrainingProgressManager()
    @State private var selectedSection = 0
    @State private var showingProgress = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Training Section", selection: $selectedSection) {
                    Text("Videos").tag(0)
                    Text("Articles").tag(1)
                    Text("Sales").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selection
                switch selectedSection {
                case 0:
                    VideosView()
                case 1:
                    ArticlesView()
                case 2:
                    SalesToolsView()
                default:
                    EmptyView()
                }
                
                Spacer()
            }
            .navigationTitle("Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingProgress = true
                    } label: {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingProgress) {
                NavigationView {
                    TrainingProgressView(progressManager: progressManager)
                        .navigationTitle("Training Progress")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingProgress = false
                                }
                            }
                        }
                }
            }
            .background(Theme.background)
        }
    }
}

struct SalesToolsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Objection Handling") {
                    ObjectionHandlingView()
                }
                // Add any other sales tools here
            }
            .navigationTitle("Sales Tools")
        }
    }
}

struct VideosView: View {
    @StateObject private var viewModel = VideosViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .tint(Theme.accent)
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.videos) { video in
                        VideoCard(video: video)
                            .onTapGesture {
                                viewModel.selectedVideo = video
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $viewModel.selectedVideo) { video in
            VideoPlayerView(videoId: video.id)
        }
        .task {
            await viewModel.loadVideos()
        }
    }
}

class VideosViewModel: ObservableObject {
    @Published var videos: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedVideo: YouTubeVideo?
    
    private let youtubeService = YouTubeService()
    
    static let defaultVideos = [
        YouTubeVideo(
            id: "zJLGA_FrZzU",
            title: "Internal Training Video",
            description: "Centurion Boats Training Content",
            thumbnailURL: "",
            publishedAt: Date()
        ),
        YouTubeVideo(
            id: "YOUR_UNLISTED_VIDEO_ID",
            title: "Your Training Video Title",
            description: "Description of your training content",
            thumbnailURL: "",
            publishedAt: Date()
        ),
        YouTubeVideo(
            id: "VIDEO_ID_1",
            title: "Product Knowledge: Fe Series",
            description: "Learn about the Fe Series lineup",
            thumbnailURL: "",
            publishedAt: Date()
        ),
        YouTubeVideo(
            id: "VIDEO_ID_2",
            title: "Product Knowledge: Ri Series",
            description: "Learn about the Ri Series lineup",
            thumbnailURL: "",
            publishedAt: Date()
        ),
        // Add more default videos
    ]
    
    func loadVideos() async {
        await MainActor.run { isLoading = true }
        do {
            let fetchedVideos = try await youtubeService.fetchLatestVideos()
            print("Fetched \(fetchedVideos.count) videos")
            await MainActor.run { videos = fetchedVideos }
        } catch {
            print("Error loading videos:", error)
            await MainActor.run { self.error = error }
        }
        await MainActor.run { isLoading = false }
    }
}

struct VideoCard: View {
    let video: YouTubeVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(video.title)
                .font(.headline)
                .foregroundColor(Theme.text)
            
            Text(video.description)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y)
    }
}

struct VideoPlayerView: View {
    let videoId: String
    @EnvironmentObject var progressManager: TrainingProgressManager
    
    var body: some View {
        YouTubePlayerView(videoId: videoId)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                progressManager.markCompleted(videoId: videoId)
            }
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        loadVideo(in: webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func loadVideo(in webView: WKWebView) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoId)?playsinline=1") else { return }
        webView.load(URLRequest(url: url))
    }
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: String
    let url: String
    let thumbnailUrl: String
}

struct ArticlesView: View {
    @State private var selectedArticle: Article?
    let articles = [
        // Page 1
        Article(
            title: "Discover the Affordable Excellence of Centurion Boats Fe22",
            description: "Join Mitch as he takes you on a comprehensive tour of the 2024 Centurion Boats Fe22.",
            date: "May 30 2024",
            url: "https://boardcoboats.com/blogs/surf-boat/discover-the-affordable-excellence-of-centurion-boats-fe22",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/fe22-thumb_750x.jpg"
        ),
        Article(
            title: "Wake Boat Fit and Finish: A Comparative Analysis",
            description: "In this video we explore Wake Boat Fit and Finish by comparing a Centurion Ri265, Supreme S240, and an Axis.",
            date: "May 29 2024",
            url: "https://boardcoboats.com/blogs/surf-boat/wake-boat-fit-and-finish-a-comparative-analysis",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/wake-boat-fit-and-finish_750x.jpg"
        ),
        Article(
            title: "Revolutionizing Marine Power: The PCM ZZ8s Engine Unleashed",
            description: "The marine industry is set to witness a significant leap in engine performance with the introduction of the PCM ZZ8s.",
            date: "December 14 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/revolutionizing-marine-power-the-pcm-zz8s-engine-unleashed",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/pcm-zz8s_750x.jpg"
        ),
        Article(
            title: "The Centurion Boats Fe22: A Trailblazer in Premium Surf Boating",
            description: "Introducing a New Era in Wakesurf and Wakeboard Boating. The Centurion Boats legacy takes a thrilling leap forward.",
            date: "December 04 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/the-centurion-boats-fe22-a-trailblazer-in-premium-surf-boating",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/fe22-trailblazer_750x.jpg"
        ),
        Article(
            title: "The All New Centurion Boat Predator Tower",
            description: "Discover the revolutionary Predator Tower on Centurion Boats' RI series! Join Mitch from BoardCo as he gives you an in-depth look.",
            date: "September 27 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/the-all-new-centurion-boat-predator-tower",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/predator-tower_750x.jpg"
        ),
        // Page 2
        Article(
            title: "Supreme vs. Axis Boats: A Comprehensive Comparison",
            description: "When it comes to wakeboarding and surfing, choosing the right boat is crucial for an enjoyable experience on the water.",
            date: "July 05 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/supreme-vs-axis-boats-a-comprehensive-comparison",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/supreme-vs-axis_750x.jpg"
        ),
        Article(
            title: "How Wakesurf Waves Work & Top Boat Brands Surf Wave Characteristics",
            description: "When it comes to wake surfing, the quality of the surf wave plays a significant role in the overall experience.",
            date: "June 27 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/how-wakesurf-waves-work",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/how-waves-work_750x.jpg"
        ),
        Article(
            title: "Centurion vs Mastercraft Wake Boats",
            description: "In this episode we will be diving into a topic that is one of the most asked questions we receive.",
            date: "June 22 2023",
            url: "https://boardcoboats.com/blogs/surf-boat/centurion-vs-mastercraft-wake-boats",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/centurion-vs-mastercraft_750x.jpg"
        ),
        // Page 3
        Article(
            title: "The Best Time to Buy a Boat",
            description: "Buying a boat is an exciting thing! However, WHEN you purchase can be an important consideration.",
            date: "December 28 2022",
            url: "https://boardcoboats.com/blogs/surf-boat/the-best-time-to-buy-a-boat",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/best-time-to-buy_750x.jpg"
        ),
        Article(
            title: "Centurion Boats Wakeboard Wake",
            description: "The new Centurion boats with the Opti-V hull produce a wakeboard wake that is unlike anything ever seen before.",
            date: "August 17 2022",
            url: "https://boardcoboats.com/blogs/surf-boat/centurion-boats-wakeboard-wake",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/wakeboard-wake_750x.jpg"
        ),
        Article(
            title: "Centurion Ri230 Walkthrough",
            description: "Welcome to the Centurion Ri230 - the most advanced and best performing 23 foot wakesurf boat on the market.",
            date: "November 16 2021",
            url: "https://boardcoboats.com/blogs/surf-boat/centurion-ri230-walkthrough",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/ri230-walkthrough_750x.jpg"
        ),
        Article(
            title: "Centurion Ri230 / Ri245 / Ri265 Wakesurf Wave - The Best Wakesurf Wave on Earth",
            description: "The Centurion Ri series boats are considered to be the best surf boats in the world.",
            date: "April 15 2021",
            url: "https://boardcoboats.com/blogs/surf-boat/centurion-ri230-ri245-ri265-wakesurf-wave",
            thumbnailUrl: "https://boardcoboats.com/cdn/shop/articles/ri-series-wave_750x.jpg"
        )
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(articles) { article in
                    ArticleCard(article: article)
                        .onTapGesture {
                            selectedArticle = article
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedArticle) { article in
            ArticleViewer(article: article)
        }
    }
}

struct ArticleCard: View {
    let article: Article
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)
                        .lineLimit(2)
                    
                    Text(article.description)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 24, height: 24)
                    .opacity(isHovered ? 1.0 : 0.7)
                    .overlay(
                        Text("→")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.textSecondary)
                        .frame(width: 16, height: 16)
                        .opacity(0.5)
                        .overlay(
                            Text("📅")
                                .font(.system(size: 10))
                        )
                    Text(article.date)
                }
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text("Read More")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.accent)
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: isHovered ? Theme.accent.opacity(0.3) : Theme.Shadows.card.color,
                radius: isHovered ? 8 : Theme.Shadows.card.radius,
                x: 0, y: isHovered ? 4 : Theme.Shadows.card.y)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ArticleViewer: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressManager: TrainingProgressManager
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: article.url)!)
                .navigationTitle("Article")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: URL(string: article.url)!)
                    }
                }
                .onAppear {
                    progressManager.markCompleted(articleUrl: article.url)
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
} 
