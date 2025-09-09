import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePosts = true
    @Published var currentPage = 0
    @Published var selectedFilter: FeedFilter = .all
    @Published var filteredPosts: [Post] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    
    init() {
        loadInitialPosts()
        setupFiltering()
    }
    
    private func setupFiltering() {
        Publishers.CombineLatest3($posts, $selectedFilter, $isLoading)
            .map { posts, filter, isLoading in
                guard !isLoading else { return posts }
                return self.filterPosts(posts, by: filter)
            }
            .assign(to: &$filteredPosts)
    }
    
    private func filterPosts(_ posts: [Post], by filter: FeedFilter) -> [Post] {
        switch filter {
        case .all:
            return posts
        case .following:
            // For now, return all posts since we don't have following logic yet
            return posts
        case .trending:
            return posts.sorted { $0.likes > $1.likes }
        case .politics:
            return posts.filter { $0.postType == .rating || $0.content.lowercased().contains("politics") }
        case .education:
            return posts.filter { $0.postType == .recommendation || $0.content.lowercased().contains("education") }
        case .healthcare:
            return posts.filter { $0.postType == .recommendation || $0.content.lowercased().contains("healthcare") }
        case .economy:
            return posts.filter { $0.postType == .performance || $0.content.lowercased().contains("economy") }
        case .environment:
            return posts.filter { $0.postType == .recommendation || $0.content.lowercased().contains("environment") }
        }
    }
    
    func refreshFeed() {
        currentPage = 0
        hasMorePosts = true
        posts.removeAll()
        loadInitialPosts()
    }
    
    func loadInitialPosts() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.posts = self.generateSamplePosts()
            self.isLoading = false
        }
    }
    
    func loadMorePosts() {
        guard !isLoading && hasMorePosts else { return }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let newPosts = self.generateSamplePosts()
            self.posts.append(contentsOf: newPosts)
            self.currentPage += 1
            self.isLoading = false
            
            // Simulate end of data after 5 pages
            if self.currentPage >= 5 {
                self.hasMorePosts = false
            }
        }
    }
    
    func refreshPosts() {
        currentPage = 0
        hasMorePosts = true
        loadInitialPosts()
    }
    
    func likePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isLiked.toggle()
            posts[index].likes += posts[index].isLiked ? 1 : -1
        }
    }
    
    func sharePost(_ post: Post) {
        // Handle post sharing
        print("Sharing post: \(post.id)")
    }
    
    private func generateSamplePosts() -> [Post] {
        let samplePosts = [
            Post(
                userId: "user1",
                username: "john_doe",
                userProfileImage: nil,
                content: "Just attended an amazing community meeting about infrastructure improvements. The government is really listening to our concerns!",
                postType: .text,
                likes: 24,
                comments: 8,
                shares: 3
            ),
            Post(
                userId: "user2",
                username: "sarah_smith",
                userProfileImage: nil,
                content: "Check out this new park that was built based on community recommendations. It's exactly what we needed!",
                postType: .image,
                images: ["park_image_1", "park_image_2"],
                likes: 45,
                comments: 12,
                shares: 7
            ),
            Post(
                userId: "user3",
                username: "mike_wilson",
                userProfileImage: nil,
                content: "What do you think about the new education policy? Should we have more focus on technology in schools?",
                postType: .text,
                likes: 18,
                comments: 15,
                shares: 2
            )
        ]
        
        return samplePosts
    }
}
