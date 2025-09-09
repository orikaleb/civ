import Foundation
import Combine

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var filteredRecommendations: [Recommendation] = []
    @Published var selectedCategory: RecommendationCategory?
    @Published var selectedStatus: RecommendationStatus?
    @Published var selectedFilter: RecommendationFilter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecommendations()
        
        // Filter recommendations when search text or filters change
        Publishers.CombineLatest3($recommendations, $searchText, $selectedCategory)
            .map { [weak self] recommendations, searchText, category in
                self?.filterRecommendations(recommendations, searchText: searchText, category: category) ?? []
            }
            .assign(to: &$filteredRecommendations)
    }
    
    func loadRecommendations() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.recommendations = self.generateSampleRecommendations()
            self.isLoading = false
        }
    }
    
    func createRecommendation(_ recommendation: Recommendation) {
        recommendations.insert(recommendation, at: 0)
        // In a real app, this would make an API call
    }
    
    func voteRecommendation(_ recommendation: Recommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) {
            recommendations[index].votes += 1
        }
    }
    
    func updateRecommendationStatus(_ recommendationId: String, status: RecommendationStatus) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendationId }) {
            recommendations[index].status = status
        }
    }
    
    func setCategoryFilter(_ category: RecommendationCategory?) {
        selectedCategory = category
    }
    
    func setStatusFilter(_ status: RecommendationStatus?) {
        selectedStatus = status
    }
    
    func upvoteRecommendation(_ recommendation: Recommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) {
            recommendations[index].votes += 1
        }
    }
    
    func downvoteRecommendation(_ recommendation: Recommendation) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) {
            recommendations[index].votes = max(0, recommendations[index].votes - 1)
        }
    }
    
    func refreshData() {
        loadRecommendations()
    }
    
    func submitRecommendation(title: String, description: String, category: RecommendationCategory, userId: String, username: String) {
        let newRecommendation = Recommendation(
            title: title,
            description: description,
            category: category,
            status: .pending,
            priority: .medium,
            createdBy: username,
            votes: 0,
            comments: 0,
            tags: []
        )
        createRecommendation(newRecommendation)
    }
    
    private func filterRecommendations(_ recommendations: [Recommendation], searchText: String, category: RecommendationCategory?) -> [Recommendation] {
        var filtered = recommendations
        
        // Filter by category
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by status
        if let status = selectedStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { recommendation in
                recommendation.title.localizedCaseInsensitiveContains(searchText) ||
                recommendation.description.localizedCaseInsensitiveContains(searchText) ||
                recommendation.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    private func generateSampleRecommendations() -> [Recommendation] {
        return [
            Recommendation(
                title: "Improve Public Transportation",
                description: "Add more bus routes to underserved areas and increase frequency during peak hours.",
                category: .transportation,
                status: .underReview,
                priority: .high,
                createdBy: "user1",
                votes: 156,
                comments: 23,
                estimatedCost: 500000,
                estimatedTimeframe: "6-12 months",
                tags: ["transportation", "infrastructure", "accessibility"]
            ),
            Recommendation(
                title: "Digital Government Services",
                description: "Implement online services for common government transactions to reduce wait times.",
                category: .technology,
                status: .approved,
                priority: .medium,
                createdBy: "user2",
                votes: 89,
                comments: 15,
                estimatedCost: 200000,
                estimatedTimeframe: "3-6 months",
                tags: ["technology", "efficiency", "digital"]
            ),
            Recommendation(
                title: "Community Garden Program",
                description: "Establish community gardens in residential areas to promote healthy living and community bonding.",
                category: .environment,
                status: .implemented,
                priority: .low,
                createdBy: "user3",
                votes: 234,
                comments: 45,
                estimatedCost: 75000,
                estimatedTimeframe: "2-4 months",
                tags: ["environment", "health", "community"]
            ),
            Recommendation(
                title: "Enhanced School Security",
                description: "Install security cameras and improve access control systems in all public schools.",
                category: .publicSafety,
                status: .inProgress,
                priority: .critical,
                createdBy: "user4",
                votes: 312,
                comments: 67,
                estimatedCost: 800000,
                estimatedTimeframe: "8-12 months",
                tags: ["security", "education", "safety"]
            )
        ]
    }
}
