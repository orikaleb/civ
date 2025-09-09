import Foundation

// MARK: - Recommendation Status Enum
enum RecommendationStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case underReview = "under_review"
    case approved = "approved"
    case rejected = "rejected"
    case implemented = "implemented"
    case inProgress = "in_progress"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .underReview: return "Under Review"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .implemented: return "Implemented"
        case .inProgress: return "In Progress"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .underReview: return "eye.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .implemented: return "checkmark.seal.fill"
        case .inProgress: return "arrow.clockwise.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .underReview: return "blue"
        case .approved: return "green"
        case .rejected: return "red"
        case .implemented: return "purple"
        case .inProgress: return "yellow"
        }
    }
}

// MARK: - Recommendation Category Enum
enum RecommendationCategory: String, CaseIterable, Codable {
    case infrastructure = "infrastructure"
    case education = "education"
    case healthcare = "healthcare"
    case economy = "economy"
    case environment = "environment"
    case socialWelfare = "social_welfare"
    case governance = "governance"
    case technology = "technology"
    case transportation = "transportation"
    case publicSafety = "public_safety"
    
    var displayName: String {
        switch self {
        case .infrastructure: return "Infrastructure"
        case .education: return "Education"
        case .healthcare: return "Healthcare"
        case .economy: return "Economy"
        case .environment: return "Environment"
        case .socialWelfare: return "Social Welfare"
        case .governance: return "Governance"
        case .technology: return "Technology"
        case .transportation: return "Transportation"
        case .publicSafety: return "Public Safety"
        }
    }
    
    var icon: String {
        switch self {
        case .infrastructure: return "building.2.fill"
        case .education: return "graduationcap.fill"
        case .healthcare: return "cross.fill"
        case .economy: return "dollarsign.circle.fill"
        case .environment: return "leaf.fill"
        case .socialWelfare: return "heart.fill"
        case .governance: return "building.columns.fill"
        case .technology: return "laptopcomputer"
        case .transportation: return "car.fill"
        case .publicSafety: return "shield.fill"
        }
    }
}

// MARK: - Recommendation Model
struct Recommendation: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: RecommendationCategory
    var status: RecommendationStatus
    let priority: RecommendationPriority
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date
    var votes: Int
    let comments: Int
    let estimatedCost: Double?
    let estimatedTimeframe: String?
    let tags: [String]
    let attachments: [String] // URLs to attached files/images
    let reviewNotes: String?
    let implementationNotes: String?
    
    init(id: String = UUID().uuidString, title: String, description: String, category: RecommendationCategory, status: RecommendationStatus = .pending, priority: RecommendationPriority = .medium, createdBy: String, createdAt: Date = Date(), updatedAt: Date = Date(), votes: Int = 0, comments: Int = 0, estimatedCost: Double? = nil, estimatedTimeframe: String? = nil, tags: [String] = [], attachments: [String] = [], reviewNotes: String? = nil, implementationNotes: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.status = status
        self.priority = priority
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.votes = votes
        self.comments = comments
        self.estimatedCost = estimatedCost
        self.estimatedTimeframe = estimatedTimeframe
        self.tags = tags
        self.attachments = attachments
        self.reviewNotes = reviewNotes
        self.implementationNotes = implementationNotes
    }
}

// MARK: - Recommendation Priority Enum
enum RecommendationPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .high: return "3.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}
