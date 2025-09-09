import Foundation

struct Ad: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String?
    let advertiser: String
    let category: AdCategory
    let callToAction: String
    let targetUrl: String
    let isSponsored: Bool
    let createdAt: Date
    
    init(id: String = UUID().uuidString, title: String, description: String, imageUrl: String? = nil, advertiser: String, category: AdCategory, callToAction: String, targetUrl: String, isSponsored: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.advertiser = advertiser
        self.category = category
        self.callToAction = callToAction
        self.targetUrl = targetUrl
        self.isSponsored = isSponsored
        self.createdAt = createdAt
    }
}

enum AdCategory: String, CaseIterable, Codable {
    case education = "Education"
    case healthcare = "Healthcare"
    case technology = "Technology"
    case finance = "Finance"
    case government = "Government"
    case community = "Community"
    case business = "Business"
    case lifestyle = "Lifestyle"
    
    var icon: String {
        switch self {
        case .education: return "graduationcap.fill"
        case .healthcare: return "cross.circle.fill"
        case .technology: return "laptopcomputer"
        case .finance: return "dollarsign.circle.fill"
        case .government: return "building.2.fill"
        case .community: return "person.3.fill"
        case .business: return "briefcase.fill"
        case .lifestyle: return "heart.fill"
        }
    }
    
    var color: String {
        switch self {
        case .education: return "blue"
        case .healthcare: return "green"
        case .technology: return "purple"
        case .finance: return "orange"
        case .government: return "red"
        case .community: return "mint"
        case .business: return "indigo"
        case .lifestyle: return "pink"
        }
    }
}
