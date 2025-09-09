import Foundation
import SwiftUI

// MARK: - Live Stream Model
struct LiveStream: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let streamUrl: String
    let thumbnailUrl: String?
    let isLive: Bool
    let viewerCount: Int
    let startedAt: Date
    let endedAt: Date?
    let createdBy: String
    let category: String
    let tags: [String]
    let isPublic: Bool
    
    init(id: String = UUID().uuidString, title: String, description: String, streamUrl: String, thumbnailUrl: String? = nil, isLive: Bool = false, viewerCount: Int = 0, startedAt: Date = Date(), endedAt: Date? = nil, createdBy: String, category: String = "General", tags: [String] = [], isPublic: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.streamUrl = streamUrl
        self.thumbnailUrl = thumbnailUrl
        self.isLive = isLive
        self.viewerCount = viewerCount
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.createdBy = createdBy
        self.category = category
        self.tags = tags
        self.isPublic = isPublic
    }
}

// MARK: - Live Stream Category Enum
enum LiveStreamCategory: String, CaseIterable, Codable {
    case government = "government"
    case community = "community"
    case education = "education"
    case news = "news"
    case entertainment = "entertainment"
    case sports = "sports"
    case technology = "technology"
    case health = "health"
    case environment = "environment"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .government: return "Government"
        case .community: return "Community"
        case .education: return "Education"
        case .news: return "News"
        case .entertainment: return "Entertainment"
        case .sports: return "Sports"
        case .technology: return "Technology"
        case .health: return "Health"
        case .environment: return "Environment"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .government: return "building.columns.fill"
        case .community: return "person.3.fill"
        case .education: return "graduationcap.fill"
        case .news: return "newspaper.fill"
        case .entertainment: return "tv.fill"
        case .sports: return "sportscourt.fill"
        case .technology: return "laptopcomputer"
        case .health: return "cross.fill"
        case .environment: return "leaf.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .government: return .blue
        case .community: return .green
        case .education: return .purple
        case .news: return .red
        case .entertainment: return .orange
        case .sports: return .yellow
        case .technology: return .cyan
        case .health: return .pink
        case .environment: return .mint
        case .other: return .gray
        }
    }
}
