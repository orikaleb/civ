import Foundation
import Combine

class LiveViewModel: ObservableObject {
    @Published var liveStreams: [LiveStream] = []
    @Published var featuredStream: LiveStream?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: LiveStreamCategory?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLiveStreams()
    }
    
    func loadLiveStreams() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.liveStreams = self.generateSampleStreams()
            self.featuredStream = self.liveStreams.first
            self.isLoading = false
        }
    }
    
    func refreshStreams() {
        loadLiveStreams()
    }
    
    func joinStream(_ stream: LiveStream) {
        // Handle joining a live stream
        print("Joining stream: \(stream.id)")
    }
    
    func setCategoryFilter(_ category: LiveStreamCategory?) {
        selectedCategory = category
    }
    
    func filterByCategory(_ category: LiveStreamCategory?) {
        selectedCategory = category
    }
    
    func leaveStream() {
        // Handle leaving stream
        print("Leaving stream")
    }
    
    var filteredStreams: [LiveStream] {
        if let category = selectedCategory {
            return liveStreams.filter { $0.category.lowercased() == category.rawValue.lowercased() }
        }
        return liveStreams
    }
    
    private func generateSampleStreams() -> [LiveStream] {
        return [
            LiveStream(
                title: "City Council Meeting - Budget Discussion",
                description: "Join us for the monthly city council meeting where we'll discuss the upcoming budget allocation.",
                streamUrl: "https://example.com/stream1",
                thumbnailUrl: "https://example.com/thumb1.jpg",
                isLive: true,
                viewerCount: 1247,
                startedAt: Date().addingTimeInterval(-3600), // 1 hour ago
                createdBy: "city_council",
                category: "Government",
                tags: ["government", "budget", "meeting"]
            ),
            LiveStream(
                title: "Community Health Workshop",
                description: "Learn about preventive healthcare and wellness tips from local health professionals.",
                streamUrl: "https://example.com/stream2",
                thumbnailUrl: "https://example.com/thumb2.jpg",
                isLive: true,
                viewerCount: 456,
                startedAt: Date().addingTimeInterval(-1800), // 30 minutes ago
                createdBy: "health_department",
                category: "Health",
                tags: ["health", "wellness", "education"]
            ),
            LiveStream(
                title: "Environmental Conservation Panel",
                description: "Discussion about local environmental initiatives and conservation efforts.",
                streamUrl: "https://example.com/stream3",
                thumbnailUrl: "https://example.com/thumb3.jpg",
                isLive: false,
                viewerCount: 0,
                startedAt: Date().addingTimeInterval(-7200), // 2 hours ago
                endedAt: Date().addingTimeInterval(-1800), // 30 minutes ago
                createdBy: "env_committee",
                category: "Environment",
                tags: ["environment", "conservation", "sustainability"]
            ),
            LiveStream(
                title: "Technology Innovation Summit",
                description: "Exploring how technology can improve government services and citizen engagement.",
                streamUrl: "https://example.com/stream4",
                thumbnailUrl: "https://example.com/thumb4.jpg",
                isLive: true,
                viewerCount: 892,
                startedAt: Date().addingTimeInterval(-2700), // 45 minutes ago
                createdBy: "tech_committee",
                category: "Technology",
                tags: ["technology", "innovation", "digital"]
            )
        ]
    }
}
