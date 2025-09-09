import Foundation
import SwiftUI

// MARK: - Notification Type Enum
enum NotificationType: String, CaseIterable, Codable {
    case like = "like"
    case comment = "comment"
    case follow = "follow"
    case mention = "mention"
    case pollUpdate = "poll_update"
    case ratingUpdate = "rating_update"
    case system = "system"
    case recommendation = "recommendation"
    
    var displayName: String {
        switch self {
        case .like: return "Like"
        case .comment: return "Comment"
        case .follow: return "Follow"
        case .mention: return "Mention"
        case .pollUpdate: return "Poll Update"
        case .ratingUpdate: return "Rating Update"
        case .system: return "System"
        case .recommendation: return "Recommendation"
        }
    }
    
    var icon: String {
        switch self {
        case .like: return "heart.fill"
        case .comment: return "message.fill"
        case .follow: return "person.badge.plus"
        case .mention: return "at"
        case .pollUpdate: return "chart.bar.fill"
        case .ratingUpdate: return "star.fill"
        case .system: return "gear"
        case .recommendation: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .like: return .red
        case .comment: return .blue
        case .follow: return .green
        case .mention: return .orange
        case .pollUpdate: return .purple
        case .ratingUpdate: return .yellow
        case .system: return .gray
        case .recommendation: return .cyan
        }
    }
}

// MARK: - App Notification Model
struct AppNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let isRead: Bool
    let createdAt: Date
    let userId: String
    let relatedId: String? // ID of related post, poll, etc.
    let actionUrl: String?
    
    init(id: String = UUID().uuidString, type: NotificationType, title: String, message: String, isRead: Bool = false, createdAt: Date = Date(), userId: String, relatedId: String? = nil, actionUrl: String? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.isRead = isRead
        self.createdAt = createdAt
        self.userId = userId
        self.relatedId = relatedId
        self.actionUrl = actionUrl
    }
}

// MARK: - Notification Settings Model
struct NotificationSettings: Codable {
    var likes: Bool = true
    var comments: Bool = true
    var follows: Bool = true
    var mentions: Bool = true
    var pollUpdates: Bool = true
    var ratingUpdates: Bool = true
    var systemNotifications: Bool = true
    var recommendations: Bool = true
    var pushNotifications: Bool = true
    var emailNotifications: Bool = false
    
    init() {}
}
