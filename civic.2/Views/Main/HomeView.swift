import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Welcome section
                    if let user = appViewModel.currentUser {
                        WelcomeSection(username: user.username)
                    }
                    
                    // Active polls section
                    if !viewModel.polls.isEmpty {
                        PollsSection(polls: viewModel.polls)
                    }
                    
                    // Trending ratings section
                    if !viewModel.trendingRatings.isEmpty {
                        TrendingRatingsSection(ratings: viewModel.trendingRatings)
                    }
                    
                    // News section
                    if !viewModel.newsSnippets.isEmpty {
                        NewsSection(news: viewModel.newsSnippets)
                    }
                    
                    // Ads section
                    if !viewModel.ads.isEmpty {
                        AdsSection(ads: viewModel.ads)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .refreshable {
                viewModel.refreshData()
            }
            .navigationTitle("CivicVoice")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WelcomeSection: View {
    let username: String
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "hand.wave.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text("Welcome back, \(username)!")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("Stay informed and make your voice heard. Check out the latest polls and community updates below.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PollsSection: View {
    let polls: [Poll]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Active Polls", icon: "vote.yea")
            
            ForEach(polls.prefix(2)) { poll in
                NavigationLink(destination: PollDetailView(poll: poll)) {
                    PollCard(poll: poll)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct TrendingRatingsSection: View {
    let ratings: [GovernmentRating]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Trending Ratings", icon: "star.fill")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ratings.prefix(4)) { rating in
                    RatingCard(rating: rating)
                }
            }
        }
    }
}

struct NewsSection: View {
    let news: [NewsSnippet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Latest News", icon: "newspaper.fill")
            
            ForEach(news.prefix(3)) { snippet in
                NewsCard(snippet: snippet)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            NavigationLink("See All") {
                Text("See All View")
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
    }
}

struct PollCard: View {
    let poll: Poll
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(poll.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(poll.totalVotes) votes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(poll.question)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    if let endDate = poll.endDate {
                        Text("Ends \(endDate, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if poll.isActive {
                        Text("Active")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct RatingCard: View {
    let rating: GovernmentRating
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: rating.category.icon)
                        .foregroundColor(Color(rating.category.color))
                        .font(.title3)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(rating.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
                
                Text(rating.category.rawValue)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(String(format: "%.1f", rating.rating))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct NewsCard: View {
    let snippet: NewsSnippet
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(snippet.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(snippet.publishedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(snippet.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(snippet.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
    }
}

struct AdsSection: View {
    let ads: [Ad]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Sponsored Content", icon: "megaphone.fill")
            
            ForEach(ads.prefix(2)) { ad in
                AdCard(ad: ad)
            }
        }
    }
}

struct AdCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let ad: Ad
    
    private var categoryColor: Color {
        switch ad.category.color {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "mint": return .mint
        case "indigo": return .indigo
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header with sponsored label
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "megaphone.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("Sponsored")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(ad.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Ad content
                HStack(spacing: 12) {
                    // Image placeholder or actual image
                    if let imageUrl = ad.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: ad.category.icon)
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(categoryColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: ad.category.icon)
                                    .foregroundColor(categoryColor)
                                    .font(.title2)
                            )
                    }
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(ad.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        Text(ad.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                        
                        Text("by \(ad.advertiser)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Call to action button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Handle ad click - could open URL or track analytics
                        if let url = URL(string: ad.targetUrl) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(ad.callToAction)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [categoryColor, categoryColor.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(categoryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}







