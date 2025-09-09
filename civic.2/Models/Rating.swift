import Foundation

// MARK: - Rating Category Enum
enum RatingCategory: String, CaseIterable, Codable {
    case economy = "economy"
    case education = "education"
    case healthcare = "healthcare"
    case infrastructure = "infrastructure"
    case security = "security"
    case environment = "environment"
    case governance = "governance"
    case socialWelfare = "social_welfare"
    case energy = "energy"
    case foodSecurity = "food_security"
    
    var displayName: String {
        switch self {
        case .economy: return "Economy"
        case .education: return "Education"
        case .healthcare: return "Healthcare"
        case .infrastructure: return "Infrastructure"
        case .security: return "Security"
        case .environment: return "Environment"
        case .governance: return "Governance"
        case .socialWelfare: return "Social Welfare"
        case .energy: return "Energy"
        case .foodSecurity: return "Food Security"
        }
    }
    
    var icon: String {
        switch self {
        case .economy: return "dollarsign.circle.fill"
        case .education: return "graduationcap.fill"
        case .healthcare: return "cross.fill"
        case .infrastructure: return "building.2.fill"
        case .security: return "shield.fill"
        case .environment: return "leaf.fill"
        case .governance: return "building.columns.fill"
        case .socialWelfare: return "heart.fill"
        case .energy: return "bolt.fill"
        case .foodSecurity: return "fork.knife"
        }
    }
    
    var color: String {
        switch self {
        case .economy: return "green"
        case .education: return "blue"
        case .healthcare: return "red"
        case .infrastructure: return "orange"
        case .security: return "purple"
        case .environment: return "green"
        case .governance: return "indigo"
        case .socialWelfare: return "pink"
        case .energy: return "yellow"
        case .foodSecurity: return "brown"
        }
    }
}

// MARK: - Government Rating Model
struct GovernmentRating: Codable, Identifiable {
    let id: String
    let category: RatingCategory
    let rating: Double
    let totalVotes: Int
    let lastUpdated: Date
    let trend: RatingTrend
    let description: String
    
    init(id: String = UUID().uuidString, category: RatingCategory, rating: Double, totalVotes: Int = 0, lastUpdated: Date = Date(), trend: RatingTrend = .stable, description: String = "") {
        self.id = id
        self.category = category
        self.rating = rating
        self.totalVotes = totalVotes
        self.lastUpdated = lastUpdated
        self.trend = trend
        self.description = description
    }
}

// MARK: - Rating Trend Enum
enum RatingTrend: String, Codable, CaseIterable {
    case improving = "improving"
    case declining = "declining"
    case stable = "stable"
    
    var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        }
    }
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .improving: return "green"
        case .declining: return "red"
        case .stable: return "gray"
        }
    }
}

// MARK: - User Rating Model
struct UserRating: Codable, Identifiable {
    let id: String
    let userId: String
    let category: RatingCategory
    let rating: Double
    let comment: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, userId: String, category: RatingCategory, rating: Double, comment: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.category = category
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
