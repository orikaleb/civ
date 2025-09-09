import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let username: String
    let userProfileImage: String?
    let content: String
    let postType: PostType
    let images: [String]?
    let poll: Poll?
    let performanceReference: PerformanceReference?
    var likes: Int
    let comments: Int
    let shares: Int
    let createdAt: Date
    var isLiked: Bool
    
    init(id: String = UUID().uuidString, userId: String, username: String, userProfileImage: String? = nil, content: String, postType: PostType = .text, images: [String]? = nil, poll: Poll? = nil, performanceReference: PerformanceReference? = nil, likes: Int = 0, comments: Int = 0, shares: Int = 0, createdAt: Date = Date(), isLiked: Bool = false) {
        self.id = id
        self.userId = userId
        self.username = username
        self.userProfileImage = userProfileImage
        self.content = content
        self.postType = postType
        self.images = images
        self.poll = poll
        self.performanceReference = performanceReference
        self.likes = likes
        self.comments = comments
        self.shares = shares
        self.createdAt = createdAt
        self.isLiked = isLiked
    }
}

enum PostType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case poll = "poll"
    case rating = "rating"
    case recommendation = "recommendation"
    case performance = "performance"
    
    var icon: String {
        switch self {
        case .text: return "text.bubble"
        case .image: return "photo"
        case .poll: return "vote.yea"
        case .rating: return "star"
        case .recommendation: return "lightbulb"
        case .performance: return "chart.bar.fill"
        }
    }
}

// MARK: - Performance Reference Model
struct PerformanceReference: Codable, Identifiable {
    let id: String
    let title: String
    let percentage: Int
    let change: Int
    let category: String
    let icon: String
    let colorName: String
    let referencedAt: Date
    
    init(title: String, percentage: Int, change: Int, category: String, icon: String, colorName: String, referencedAt: Date = Date()) {
        self.id = UUID().uuidString
        self.title = title
        self.percentage = percentage
        self.change = change
        self.category = category
        self.icon = icon
        self.colorName = colorName
        self.referencedAt = referencedAt
    }
}







