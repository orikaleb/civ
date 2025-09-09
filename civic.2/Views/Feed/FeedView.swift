import SwiftUI

// MARK: - Feed Filter Enum
enum FeedFilter: String, CaseIterable {
    case all = "all"
    case following = "following"
    case trending = "trending"
    case politics = "politics"
    case education = "education"
    case healthcare = "healthcare"
    case economy = "economy"
    case environment = "environment"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .following: return "Following"
        case .trending: return "Trending"
        case .politics: return "Politics"
        case .education: return "Education"
        case .healthcare: return "Healthcare"
        case .economy: return "Economy"
        case .environment: return "Environment"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .following: return "person.2.fill"
        case .trending: return "flame.fill"
        case .politics: return "building.columns.fill"
        case .education: return "graduationcap.fill"
        case .healthcare: return "cross.fill"
        case .economy: return "dollarsign.circle.fill"
        case .environment: return "leaf.fill"
        }
    }
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingMessages = false
    @State private var showingLive = false
    @State private var showingNotifications = false
    
    
        var body: some View {
        VStack(spacing: 0) {
            headerSection
            feedContentSection
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationDestination(isPresented: $showingMessages) {
            MessagingView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .navigationDestination(isPresented: $showingNotifications) {
            NotificationsView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .navigationDestination(isPresented: $showingLive) {
            LiveView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            navigationBarSection
            filterTabsSection
        }
    }
    
    private var navigationBarSection: some View {
        HStack {
            Text("CivicVoice")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    showingNotifications = true
                }) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(Color.appPrimary)
                }
                Button(action: {
                    showingMessages = true
                }) {
                    Image(systemName: "message.fill")
                        .font(.title2)
                        .foregroundColor(Color.appPrimary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 3)
    }
    
    private var filterTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FeedFilter.allCases, id: \.self) { filter in
                    FeedFilterChip(
                        title: filter.displayName,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var feedContentSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredPosts) { post in
                    PostCard(post: post, viewModel: viewModel)
                        .padding(.bottom, 8)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 80 && abs(value.translation.height) < 50 {
                        showingLive = true
                    }
                }
        )
        .refreshable {
            viewModel.refreshFeed()
        }
    }
}

struct FeedFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(isSelected ? .white : Color.appPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minWidth: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.appPrimary, lineWidth: isSelected ? 0 : 1.5)
                        )
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PostCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let post: Post
    @ObservedObject var viewModel: FeedViewModel
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post header
            HStack(spacing: 12) {
                // Profile image
                AsyncImage(url: URL(string: post.userProfileImage ?? "")) { image in
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
                
                // User info
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(post.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Post type indicator
                Image(systemName: post.postType.icon)
                    .font(.caption)
                    .foregroundColor(Color.appPrimary)
                    .padding(6)
                    .background(Color.appPrimary.opacity(0.1))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Post content
            VStack(alignment: .leading, spacing: 12) {
                Text(post.content)
                    .font(.body)
                    .lineLimit(nil)
                    .padding(.horizontal, 16)
                
                // Images
                if let images = post.images, !images.isEmpty {
                    ImageCarousel(images: images)
                        .padding(.horizontal, 16)
                }
                
                // Poll
                if let poll = post.poll {
                    FeedPollCard(poll: poll)
                        .padding(.horizontal, 16)
                }
                
                // Performance Reference
                if let performanceRef = post.performanceReference {
                    PerformanceReferenceCard(performanceRef: performanceRef)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
            
            // Action buttons
            HStack(spacing: 24) {
                // Like button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        viewModel.likePost(post)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(post.isLiked ? .red : .primary)
                            .scaleEffect(post.isLiked ? 1.2 : 1.0)
                        
                        Text("\(post.likes)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Comment button
                Button(action: {
                    showingComments = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        Text("\(post.comments)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Share button
                Button(action: {
                    // Share functionality
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        Text("\(post.shares)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .cornerRadius(12)
        // Primary shadow (main depth)
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
        // Secondary shadow (ambient depth)
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 6,
            x: 0,
            y: 2
        )
        // Tertiary shadow (soft glow)
        .shadow(
            color: Color.black.opacity(0.02),
            radius: 3,
            x: 0,
            y: 1
        )
        // Inner shadow effect with gradient overlay
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.clear,
                            Color.black.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        // Subtle inner highlight
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                .blendMode(.overlay)
        )
        .padding(.horizontal, 16)
        .navigationDestination(isPresented: $showingComments) {
            CommentsView(post: post)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
}

struct ImageCarousel: View {
    let images: [String]
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FeedPollCard: View {
    let poll: Poll
    @State private var selectedOption: PollOption?
    @State private var hasVoted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(poll.question)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(poll.options) { option in
                    FeedPollOptionRow(
                        option: option,
                        totalVotes: poll.totalVotes,
                        isSelected: selectedOption?.id == option.id,
                        hasVoted: hasVoted
                    ) {
                        if !hasVoted {
                            selectedOption = option
                        }
                    }
                }
            }
            
            if !hasVoted {
                CivicButton("Vote") {
                    hasVoted = true
                }
                .disabled(selectedOption == nil)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FeedPollOptionRow: View {
    let option: PollOption
    let totalVotes: Int
    let isSelected: Bool
    let hasVoted: Bool
    let action: () -> Void
    
    private var percentage: Double {
        guard totalVotes > 0 else { return 0 }
        return Double(option.votes) / Double(totalVotes) * 100
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(option.text)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if hasVoted {
                            Text("\(Int(percentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.appPrimary)
                        }
                    }
                    
                    if hasVoted {
                        ProgressView(value: percentage, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.appPrimary))
                            .scaleEffect(y: 0.8)
                    }
                }
                
                if isSelected && !hasVoted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.appPrimary)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color(.systemGray5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .disabled(hasVoted)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Performance Reference Card
struct PerformanceReferenceCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let performanceRef: PerformanceReference
    
    private var color: Color {
        switch performanceRef.colorName {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "mint": return .mint
        default: return .primary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Performance Reference")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(performanceRef.referencedAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Performance data
            HStack(spacing: 16) {
                // Icon and title
                HStack(spacing: 8) {
                    if performanceRef.title == "Economy" {
                        ZStack {
                            Image(systemName: performanceRef.icon)
                                .font(.title3)
                                .foregroundColor(color)
                            
                            Text("₵")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: performanceRef.icon)
                            .font(.title3)
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(performanceRef.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(performanceRef.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Percentage and change
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(performanceRef.percentage)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: performanceRef.change >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(performanceRef.change >= 0 ? .green : .red)
                        
                        Text("\(abs(performanceRef.change))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(performanceRef.change >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Comments View
struct CommentsView: View {
    let post: Post
    
    var body: some View {
        VStack {
            Text("Comments for: \(post.content)")
                .font(.headline)
                .padding()
            
            Text("Comments functionality coming soon...")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FeedView()
        .environmentObject(AppViewModel())
}

