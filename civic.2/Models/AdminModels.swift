import Foundation
import SwiftUI

// MARK: - Admin API Access Models

struct AdminAPIEndpoint {
    let path: String
    let method: HTTPMethod
    let requiresAuth: Bool
    let requiredPermissions: [AdminPermission]
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
}

// MARK: - Admin API Endpoints

extension AdminAPIEndpoint {
    static let getAllUsers = AdminAPIEndpoint(
        path: "/api/admin/users",
        method: .GET,
        requiresAuth: true,
        requiredPermissions: [.viewUsers]
    )
    
    static let updateUserRole = AdminAPIEndpoint(
        path: "/api/admin/users/{userId}/role",
        method: .PUT,
        requiresAuth: true,
        requiredPermissions: [.manageUsers]
    )
    
    static let suspendUser = AdminAPIEndpoint(
        path: "/api/admin/users/{userId}/suspend",
        method: .POST,
        requiresAuth: true,
        requiredPermissions: [.manageUsers]
    )
    
    static let getReportedContent = AdminAPIEndpoint(
        path: "/api/admin/content/reported",
        method: .GET,
        requiresAuth: true,
        requiredPermissions: [.viewReports]
    )
    
    static let moderateContent = AdminAPIEndpoint(
        path: "/api/admin/content/{contentId}/moderate",
        method: .POST,
        requiresAuth: true,
        requiredPermissions: [.moderateContent]
    )
    
    static let getAnalytics = AdminAPIEndpoint(
        path: "/api/admin/analytics",
        method: .GET,
        requiresAuth: true,
        requiredPermissions: [.viewAnalytics]
    )
    
    static let getSystemHealth = AdminAPIEndpoint(
        path: "/api/admin/system/health",
        method: .GET,
        requiresAuth: true,
        requiredPermissions: [.manageSystem]
    )
}

// MARK: - Admin API Response Models

struct AdminAPIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct UserListResponse: Codable {
    let users: [User]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

struct ContentReportResponse: Codable {
    let reports: [ContentReport]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

struct ContentReport: Codable, Identifiable {
    let id: String
    let contentId: String
    let contentType: String // "post", "comment", "reply"
    let reportedBy: String
    let reason: String
    let description: String?
    let status: ReportStatus
    let createdAt: Date
    let reviewedAt: Date?
    let reviewedBy: String?
    
    enum ReportStatus: String, Codable {
        case pending = "pending"
        case reviewed = "reviewed"
        case dismissed = "dismissed"
        case actionTaken = "action_taken"
    }
}

struct AnalyticsResponse: Codable {
    let userStats: UserStats
    let contentStats: ContentStats
    let engagementStats: EngagementStats
    let systemStats: SystemStats
}

struct UserStats: Codable {
    let totalUsers: Int
    let activeUsers: Int
    let newUsersToday: Int
    let newUsersThisWeek: Int
    let newUsersThisMonth: Int
    let verifiedUsers: Int
    let adminUsers: Int
    let moderatorUsers: Int
}

struct ContentStats: Codable {
    let totalPosts: Int
    let postsToday: Int
    let postsThisWeek: Int
    let postsThisMonth: Int
    let totalComments: Int
    let totalReplies: Int
    let reportedContent: Int
    let pendingReports: Int
}

struct EngagementStats: Codable {
    let totalVotes: Int
    let totalRatings: Int
    let totalRecommendations: Int
    let averageEngagementRate: Double
    let mostEngagedContent: [String]
    let trendingTopics: [String]
}

struct SystemStats: Codable {
    let serverUptime: Double
    let averageResponseTime: Double
    let errorRate: Double
    let activeConnections: Int
    let databaseSize: Double
    let lastBackup: Date?
}

// MARK: - Admin Management Models

struct AdminAction: Codable {
    let id: String
    let type: ActionType
    let targetId: String
    let targetType: String
    let performedBy: String
    let reason: String?
    let timestamp: Date
    let metadata: [String: String]?
    
    enum ActionType: String, Codable {
        case userSuspended = "user_suspended"
        case userActivated = "user_activated"
        case roleChanged = "role_changed"
        case contentRemoved = "content_removed"
        case contentApproved = "content_approved"
        case reportDismissed = "report_dismissed"
        case reportActionTaken = "report_action_taken"
        case systemSettingChanged = "system_setting_changed"
    }
}

struct AdminNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let priority: Priority
    let isRead: Bool
    let createdAt: Date
    let actionRequired: Bool
    let relatedId: String?
    
    enum NotificationType: String, Codable {
        case newReport = "new_report"
        case userSuspension = "user_suspension"
        case systemAlert = "system_alert"
        case securityAlert = "security_alert"
        case maintenanceScheduled = "maintenance_scheduled"
    }
    
    enum Priority: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
    }
}

// MARK: - Admin Dashboard Models

struct AdminDashboardData: Codable {
    let overview: DashboardOverview
    let recentActivity: [AdminAction]
    let notifications: [AdminNotification]
    let systemHealth: SystemHealthStatus
    let quickStats: QuickStats
}

struct DashboardOverview: Codable {
    let totalUsers: Int
    let activeUsers: Int
    let totalContent: Int
    let pendingReports: Int
    let systemUptime: Double
    let lastUpdate: Date
}

struct SystemHealthStatus: Codable {
    let status: HealthStatus
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double
    let networkLatency: Double
    let lastCheck: Date
    
    enum HealthStatus: String, Codable {
        case healthy = "healthy"
        case warning = "warning"
        case critical = "critical"
        case offline = "offline"
    }
}

struct QuickStats: Codable {
    let usersOnline: Int
    let postsToday: Int
    let reportsToday: Int
    let errorsToday: Int
}

// MARK: - Admin Settings Models

struct AdminSettings: Codable {
    let contentModeration: ContentModerationSettings
    let userManagement: UserManagementSettings
    let systemSettings: SystemSettings
    let securitySettings: SecuritySettings
    let notificationSettings: NotificationSettings
}

struct ContentModerationSettings: Codable {
    let autoModerationEnabled: Bool
    let autoModerationLevel: ModerationLevel
    let requireApprovalForNewUsers: Bool
    let maxReportsBeforeAutoAction: Int
    let allowedContentTypes: [String]
    let blockedKeywords: [String]
    
    enum ModerationLevel: String, Codable {
        case strict = "strict"
        case moderate = "moderate"
        case lenient = "lenient"
    }
}

struct UserManagementSettings: Codable {
    let allowSelfRegistration: Bool
    let requireEmailVerification: Bool
    let defaultUserRole: UserRole
    let maxUsersPerDay: Int
    let userSuspensionDuration: Int // in days
    let allowRoleChanges: Bool
}

struct SystemSettings: Codable {
    let maintenanceMode: Bool
    let maintenanceMessage: String
    let maxFileUploadSize: Int // in MB
    let allowedFileTypes: [String]
    let backupFrequency: BackupFrequency
    let logRetentionDays: Int
    
    enum BackupFrequency: String, Codable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
    }
}

struct SecuritySettings: Codable {
    let twoFactorRequired: Bool
    let sessionTimeout: Int // in minutes
    let maxLoginAttempts: Int
    let lockoutDuration: Int // in minutes
    let ipWhitelist: [String]
    let auditLogEnabled: Bool
}

