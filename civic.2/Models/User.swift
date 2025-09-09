import Foundation
import SwiftUI

// MARK: - User Role Enum
enum UserRole: String, Codable, CaseIterable {
    case user = "user"
    case moderator = "moderator"
    case admin = "admin"
    case superAdmin = "super_admin"
    
    var displayName: String {
        switch self {
        case .user: return "User"
        case .moderator: return "Moderator"
        case .admin: return "Administrator"
        case .superAdmin: return "Super Administrator"
        }
    }
    
    var icon: String {
        switch self {
        case .user: return "person.fill"
        case .moderator: return "shield.fill"
        case .admin: return "crown.fill"
        case .superAdmin: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .user: return "blue"
        case .moderator: return "orange"
        case .admin: return "purple"
        case .superAdmin: return "red"
        }
    }
    
    var permissions: [AdminPermission] {
        switch self {
        case .user:
            return []
        case .moderator:
            return [.viewUsers, .moderateContent, .viewReports]
        case .admin:
            return [.viewUsers, .moderateContent, .viewReports, .manageUsers, .viewAnalytics, .manageContent]
        case .superAdmin:
            return AdminPermission.allCases
        }
    }
}

// MARK: - Admin Permission Enum
enum AdminPermission: String, Codable, CaseIterable {
    case viewUsers = "view_users"
    case manageUsers = "manage_users"
    case moderateContent = "moderate_content"
    case manageContent = "manage_content"
    case viewReports = "view_reports"
    case viewAnalytics = "view_analytics"
    case manageSystem = "manage_system"
    case manageSettings = "manage_settings"
    
    var displayName: String {
        switch self {
        case .viewUsers: return "View Users"
        case .manageUsers: return "Manage Users"
        case .moderateContent: return "Moderate Content"
        case .manageContent: return "Manage Content"
        case .viewReports: return "View Reports"
        case .viewAnalytics: return "View Analytics"
        case .manageSystem: return "Manage System"
        case .manageSettings: return "Manage Settings"
        }
    }
}

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var username: String
    var fullName: String
    var bio: String
    var profileImage: String?
    var interests: [String]
    var joinDate: Date
    var totalVotes: Int
    var totalRatings: Int
    var totalRecommendations: Int
    var followers: [String]
    var following: [String]
    var role: UserRole
    var isVerified: Bool
    var isActive: Bool
    var lastActive: Date
    var adminNotes: String?
    
    init(id: String = UUID().uuidString, email: String, username: String, fullName: String = "", bio: String = "", profileImage: String? = nil, interests: [String] = [], joinDate: Date = Date(), totalVotes: Int = 0, totalRatings: Int = 0, totalRecommendations: Int = 0, followers: [String] = [], following: [String] = [], role: UserRole = .user, isVerified: Bool = false, isActive: Bool = true, lastActive: Date = Date(), adminNotes: String? = nil) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.profileImage = profileImage
        self.interests = interests
        self.joinDate = joinDate
        self.totalVotes = totalVotes
        self.totalRatings = totalRatings
        self.totalRecommendations = totalRecommendations
        self.followers = followers
        self.following = following
        self.role = role
        self.isVerified = isVerified
        self.isActive = isActive
        self.lastActive = lastActive
        self.adminNotes = adminNotes
    }
    
    // MARK: - Admin Helper Methods
    var isAdmin: Bool {
        return role == .admin || role == .superAdmin
    }
    
    var isModerator: Bool {
        return role == .moderator || isAdmin
    }
    
    func hasPermission(_ permission: AdminPermission) -> Bool {
        return role.permissions.contains(permission)
    }
    
    var roleColor: Color {
        switch role.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .blue
        }
    }
}

