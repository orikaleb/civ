import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    NotificationCell(notification: notification) {
                        viewModel.markAsRead(notification)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
            .padding(.top, 8)
        }
        .refreshable {
            viewModel.refreshNotifications()
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct NotificationCell: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                    .frame(width: 40, height: 40)
                
                // Notification content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(notification.message)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    
                    Text(notification.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Notification type icon
                Image(systemName: notification.type.icon)
                    .font(.title3)
                    .foregroundColor(notification.type.color)
                    .frame(width: 24)
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(notification.isRead ? Color(.systemBackground) : Color.appPrimary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    init() {
        loadMockNotifications()
    }
    
    func refreshNotifications() {
        loadMockNotifications()
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = AppNotification(
                id: notification.id,
                type: notification.type,
                title: notification.title,
                message: notification.message,
                isRead: true,
                createdAt: notification.createdAt,
                userId: notification.userId,
                relatedId: notification.relatedId,
                actionUrl: notification.actionUrl
            )
        }
    }
    
    private func loadMockNotifications() {
        notifications = [
            AppNotification(
                type: .like,
                title: "JohnDoe",
                message: "liked your post about healthcare improvements",
                isRead: false,
                createdAt: Date().addingTimeInterval(-300),
                userId: "user1",
                relatedId: "post1"
            ),
            AppNotification(
                type: .comment,
                title: "JaneSmith",
                message: "commented on your poll about city budget priorities",
                isRead: false,
                createdAt: Date().addingTimeInterval(-900),
                userId: "user2",
                relatedId: "post2"
            ),
            AppNotification(
                type: .follow,
                title: "EcoWarrior",
                message: "started following you",
                isRead: true,
                createdAt: Date().addingTimeInterval(-1800),
                userId: "user3"
            ),
            AppNotification(
                type: .pollUpdate,
                title: "HealthAdvocate",
                message: "invited you to vote on a new healthcare policy poll",
                isRead: true,
                createdAt: Date().addingTimeInterval(-3600),
                userId: "user4",
                relatedId: "post3"
            ),
            AppNotification(
                type: .mention,
                title: "TechInnovator",
                message: "mentioned you in a post about digital infrastructure",
                isRead: true,
                createdAt: Date().addingTimeInterval(-7200),
                userId: "user5",
                relatedId: "post4"
            ),
            AppNotification(
                type: .like,
                title: "CommunityLeader",
                message: "liked your recommendation about public transportation",
                isRead: true,
                createdAt: Date().addingTimeInterval(-10800),
                userId: "user6",
                relatedId: "post5"
            ),
            AppNotification(
                type: .comment,
                title: "PolicyMaker",
                message: "replied to your comment on the education funding discussion",
                isRead: true,
                createdAt: Date().addingTimeInterval(-14400),
                userId: "user7",
                relatedId: "post6"
            ),
            AppNotification(
                type: .pollUpdate,
                title: "LocalActivist",
                message: "created a new poll about environmental policies and invited you to vote",
                isRead: true,
                createdAt: Date().addingTimeInterval(-18000),
                userId: "user8",
                relatedId: "post7"
            )
        ]
    }
}

#Preview {
    NotificationsView()
}
