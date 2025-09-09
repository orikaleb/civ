import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var recentSearches: [String] = []
    @Published var trendingTopics: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var searchTimer: Timer?
    
    init() {
        loadRecentSearches()
        loadTrendingTopics()
        
        // Debounce search
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                if !searchText.isEmpty {
                    self?.performSearch(searchText)
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Add to recent searches
        addToRecentSearches(query)
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchResults = self.generateSearchResults(for: query)
            self.isLoading = false
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
    
    private func addToRecentSearches(_ query: String) {
        recentSearches.removeAll { $0 == query }
        recentSearches.insert(query, at: 0)
        
        // Keep only last 10 searches
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = saved
        }
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
    
    private func loadTrendingTopics() {
        trendingTopics = [
            "Infrastructure",
            "Education Policy",
            "Healthcare Access",
            "Environmental Protection",
            "Economic Development",
            "Public Safety",
            "Technology Innovation",
            "Social Welfare"
        ]
    }
    
    private func generateSearchResults(for query: String) -> [SearchResult] {
        let sampleResults = [
            SearchResult(
                id: "1",
                type: .post,
                title: "Community Discussion: \(query)",
                subtitle: "Active discussion about \(query) in our community",
                imageUrl: nil
            ),
            SearchResult(
                id: "2",
                type: .user,
                title: "John Smith",
                subtitle: "Community advocate for \(query)",
                imageUrl: nil
            ),
            SearchResult(
                id: "3",
                type: .poll,
                title: "Poll: Your opinion on \(query)",
                subtitle: "Vote and share your thoughts",
                imageUrl: nil
            )
        ]
        
        return sampleResults
    }
}

// MARK: - Search Result Model
struct SearchResult: Codable, Identifiable {
    let id: String
    let type: SearchResultType
    let title: String
    let subtitle: String
    let imageUrl: String?
    
    init(id: String, type: SearchResultType, title: String, subtitle: String, imageUrl: String? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
    }
}

enum SearchResultType: String, Codable, CaseIterable {
    case post = "post"
    case user = "user"
    case poll = "poll"
    case recommendation = "recommendation"
    case topic = "topic"
    
    var displayName: String {
        switch self {
        case .post: return "Post"
        case .user: return "User"
        case .poll: return "Poll"
        case .recommendation: return "Recommendation"
        case .topic: return "Topic"
        }
    }
    
    var icon: String {
        switch self {
        case .post: return "doc.text"
        case .user: return "person"
        case .poll: return "chart.bar"
        case .recommendation: return "lightbulb"
        case .topic: return "tag"
        }
    }
}
