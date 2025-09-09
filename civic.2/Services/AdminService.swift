import Foundation
import Combine

// MARK: - Admin Service

class AdminService: ObservableObject {
    static let shared = AdminService()
    
    private let baseURL = "https://api.civicvoice.com" // Replace with your actual API URL
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Authentication
    
    func authenticateAdmin(email: String, password: String) -> AnyPublisher<User, Error> {
        let endpoint = "/api/admin/auth"
        let body = ["email": email, "password": password]
        
        return makeRequest(endpoint: endpoint, method: "POST", body: body)
            .tryMap { (response: AdminAPIResponse<User>) in
                guard response.success, let user = response.data else {
                    throw AdminError.authenticationFailed(response.message ?? "Authentication failed")
                }
                return user
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - User Management
    
    func getAllUsers(page: Int = 1, pageSize: Int = 50) -> AnyPublisher<UserListResponse, Error> {
        let endpoint = "/api/admin/users?page=\(page)&pageSize=\(pageSize)"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<UserListResponse>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch users")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func updateUserRole(userId: String, newRole: UserRole) -> AnyPublisher<User, Error> {
        let endpoint = "/api/admin/users/\(userId)/role"
        let body = ["role": newRole.rawValue]
        
        return makeRequest(endpoint: endpoint, method: "PUT", body: body)
            .tryMap { (response: AdminAPIResponse<User>) in
                guard response.success, let user = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to update user role")
                }
                return user
            }
            .eraseToAnyPublisher()
    }
    
    func suspendUser(userId: String, reason: String) -> AnyPublisher<Bool, Error> {
        let endpoint = "/api/admin/users/\(userId)/suspend"
        let body = ["reason": reason]
        
        return makeRequest(endpoint: endpoint, method: "POST", body: body)
            .tryMap { (response: AdminAPIResponse<[String: String]>) in
                guard response.success else {
                    throw AdminError.apiError(response.message ?? "Failed to suspend user")
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func activateUser(userId: String) -> AnyPublisher<Bool, Error> {
        let endpoint = "/api/admin/users/\(userId)/activate"
        
        return makeRequest(endpoint: endpoint, method: "POST")
            .tryMap { (response: AdminAPIResponse<[String: String]>) in
                guard response.success else {
                    throw AdminError.apiError(response.message ?? "Failed to activate user")
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Content Moderation
    
    func getReportedContent(page: Int = 1, pageSize: Int = 50) -> AnyPublisher<ContentReportResponse, Error> {
        let endpoint = "/api/admin/content/reported?page=\(page)&pageSize=\(pageSize)"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<ContentReportResponse>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch reported content")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func moderateContent(contentId: String, action: ModerationAction, reason: String?) -> AnyPublisher<Bool, Error> {
        let endpoint = "/api/admin/content/\(contentId)/moderate"
        let body: [String: Any] = [
            "action": action.rawValue,
            "reason": reason ?? ""
        ]
        
        return makeRequest(endpoint: endpoint, method: "POST", body: body)
            .tryMap { (response: AdminAPIResponse<[String: String]>) in
                guard response.success else {
                    throw AdminError.apiError(response.message ?? "Failed to moderate content")
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Analytics
    
    func getAnalytics(timeRange: AnalyticsTimeRange = .last30Days) -> AnyPublisher<AnalyticsResponse, Error> {
        let endpoint = "/api/admin/analytics?timeRange=\(timeRange.rawValue)"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<AnalyticsResponse>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch analytics")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - System Management
    
    func getSystemHealth() -> AnyPublisher<SystemHealthStatus, Error> {
        let endpoint = "/api/admin/system/health"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<SystemHealthStatus>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch system health")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func getDashboardData() -> AnyPublisher<AdminDashboardData, Error> {
        let endpoint = "/api/admin/dashboard"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<AdminDashboardData>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch dashboard data")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Settings
    
    func getAdminSettings() -> AnyPublisher<AdminSettings, Error> {
        let endpoint = "/api/admin/settings"
        
        return makeRequest(endpoint: endpoint, method: "GET")
            .tryMap { (response: AdminAPIResponse<AdminSettings>) in
                guard response.success, let data = response.data else {
                    throw AdminError.apiError(response.message ?? "Failed to fetch settings")
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func updateAdminSettings(_ settings: AdminSettings) -> AnyPublisher<Bool, Error> {
        let endpoint = "/api/admin/settings"
        
        return makeRequest(endpoint: endpoint, method: "PUT", body: settings)
            .tryMap { (response: AdminAPIResponse<[String: String]>) in
                guard response.success else {
                    throw AdminError.apiError(response.message ?? "Failed to update settings")
                }
                return true
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: String,
        body: Any? = nil
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: AdminError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                return Fail(error: AdminError.invalidData)
                    .eraseToAnyPublisher()
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func getAuthToken() -> String? {
        // In a real app, this would retrieve the stored authentication token
        return UserDefaults.standard.string(forKey: "adminAuthToken")
    }
    
    private func setAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "adminAuthToken")
    }
    
    private func clearAuthToken() {
        UserDefaults.standard.removeObject(forKey: "adminAuthToken")
    }
}

// MARK: - Supporting Types

enum AdminError: Error, LocalizedError {
    case invalidURL
    case invalidData
    case authenticationFailed(String)
    case apiError(String)
    case networkError(Error)
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidData:
            return "Invalid data format"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}

enum ModerationAction: String, Codable {
    case approve = "approve"
    case remove = "remove"
    case flag = "flag"
    case dismiss = "dismiss"
}

enum AnalyticsTimeRange: String, Codable {
    case last24Hours = "24h"
    case last7Days = "7d"
    case last30Days = "30d"
    case last90Days = "90d"
    case lastYear = "1y"
    case allTime = "all"
}
