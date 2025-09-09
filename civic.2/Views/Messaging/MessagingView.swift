import SwiftUI

struct MessagingView: View {
    @StateObject private var viewModel = MessagingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingNewChat = false
    @State private var showingNotifications = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            if let currentChat = viewModel.currentChat {
                // Chat header
                HStack {
                    Button("Back") {
                        viewModel.currentChat = nil
                    }
                    
                    Spacer()
                    
                    Text("Chat")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.dynamicBackground(for: appViewModel.themeMode))
                
                // Chat detail view
                ChatDetailView(chat: currentChat, viewModel: viewModel)
            } else {
                // Messages header
                HStack {
                    Button(action: {
                        showingNotifications = true
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundColor(Color.appPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Messages")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingNewChat = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(Color.appPrimary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.dynamicBackground(for: appViewModel.themeMode))
                
                // Chats list view
                ChatsListView(viewModel: viewModel, showingNewChat: $showingNewChat)
            }
        }
        .navigationDestination(isPresented: $showingNewChat) {
            NewChatView { selectedUser in
                // Start new chat with selected user
                showingNewChat = false
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
}

struct ChatsListView: View {
    @ObservedObject var viewModel: MessagingViewModel
    @Binding var showingNewChat: Bool
    
    var body: some View {
        List {
            ForEach(viewModel.chats) { chat in
                ChatRow(chat: chat) {
                    viewModel.selectChat(chat)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ChatRow: View {
    let chat: Chat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image
                AsyncImage(url: URL(string: "https://picsum.photos/200/200?random=\(chat.id.hashValue % 10)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.participants.first { $0 != "currentUser" } ?? "Unknown User")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let lastMessage = chat.lastMessage {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(chat.lastMessageAt ?? Date(), style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if (chat.lastMessage?.isRead == false) {
                        Text("1")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.appPrimary)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChatDetailView: View {
    let chat: Chat
    @ObservedObject var viewModel: MessagingViewModel
    @State private var newMessageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == "currentUser"
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            // Message input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    let _ = chat.participants.first { $0 != "currentUser" } ?? ""
                    viewModel.sendMessage()
                    newMessageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.appPrimary)
                        )
                }
                .disabled(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isFromCurrentUser ? Color.appPrimary : Color(.systemGray5))
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFilter: ChatFilter = .all
    let onUserSelected: (User) -> Void
    
    // Mock users for demo
    private let mockUsers = [
        User(id: "user1", email: "john@example.com", username: "JohnDoe", profileImage: "https://picsum.photos/200/200?random=1", interests: ["Politics", "Community"], totalVotes: 45, totalRatings: 23, totalRecommendations: 12),
        User(id: "user2", email: "jane@example.com", username: "JaneSmith", profileImage: "https://picsum.photos/200/200?random=2", interests: ["Activism", "Education"], totalVotes: 67, totalRatings: 34, totalRecommendations: 18),
        User(id: "user3", email: "mike@example.com", username: "MikeJohnson", profileImage: "https://picsum.photos/200/200?random=3", interests: ["Environment", "Policy"], totalVotes: 89, totalRatings: 56, totalRecommendations: 25)
    ]
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return mockUsers
        }
        return mockUsers.filter { user in
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.interests.contains { interest in
                interest.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and cancel button
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Text("New Chat")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search users...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChatFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: filter.icon)
                                    .font(.caption)
                                Text(filter.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedFilter == filter ? .white : Color.appPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedFilter == filter ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // User list
            List(filteredUsers) { user in
                UserRow(user: user) {
                    onUserSelected(user)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// Local enum for chat filters
enum ChatFilter: String, CaseIterable {
    case all = "All"
    case online = "Online"
    case recent = "Recent"
    
    var icon: String {
        switch self {
        case .all: return "person.3"
        case .online: return "circle.fill"
        case .recent: return "clock"
        }
    }
}

struct UserRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(user.interests.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MessagingView()
        .environmentObject(AppViewModel())
}
