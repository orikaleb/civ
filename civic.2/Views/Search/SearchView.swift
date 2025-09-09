import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SearchViewModel()
    @State private var isEditing = false
    @State private var recentSearches: [String] = ["Healthcare policy", "Education reform", "Local elections", "Road projects"]
    @FocusState private var searchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with search and Cancel
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search people and posts", text: $viewModel.searchText, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .onSubmit {
                        let term = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !term.isEmpty else { return }
                        if let idx = recentSearches.firstIndex(of: term) { recentSearches.remove(at: idx) }
                        recentSearches.insert(term, at: 0)
                        if recentSearches.count > 10 { _ = recentSearches.popLast() }
                    }
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($searchFocused)
                }
                .padding(10)
                .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
                .cornerRadius(10)
                
                if isEditing || searchFocused || !viewModel.searchText.isEmpty {
                    Button("Cancel") {
                        viewModel.searchText = ""
                        isEditing = false
                        searchFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
            
            // No chips (match X style)
            
            // Content based on selected tab
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.searchText.isEmpty {
                if searchFocused {
                    RecentSearchesList(recentSearches: $recentSearches, onClearAll: {
                        recentSearches.removeAll()
                    }, onSelectRecent: { term in
                        viewModel.searchText = term
                        searchFocused = false
                    })
                } else {
                    TrendingOnlyContent { topic in
                        viewModel.searchText = topic
                    }
                }
            } else {
                // Search results (unified)
                UnifiedSearchResultsContent(viewModel: viewModel)
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
}

struct TrendingOnlyContent: View {
    var onSelectTopic: (String) -> Void
    
    private let sections: [(title: String, topics: [String])] = [
        ("Health", ["Hospitals", "Primary Care", "Insurance", "Vaccines", "Mental Health", "Clinics"]),
        ("Education", ["STEM", "Teacher Training", "Scholarships", "School Feeding", "Curriculum", "EdTech"]),
        ("Economy", ["Inflation", "Jobs", "SMEs", "Manufacturing", "Exports", "Markets"]),
        ("Security", ["Police", "Community Watch", "Cybersecurity", "CCTV", "Border Patrol", "Emergency"]),
        ("Transport", ["Roads", "Rail", "BRT", "Airports", "Ports", "Bikes"]),
        ("Environment", ["Climate", "Waste", "Water", "Air Quality", "Parks", "Energy"])
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        VStack(spacing: 0) {
                            ForEach(section.topics, id: \.self) { topic in
                                Button(action: { onSelectTopic(topic) }) {
                                    HStack {
                                        Text("#\(topic)")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(Int.random(in: 100...1000))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 100)
        }
    }
}

struct RecentSearchesList: View {
    @Binding var recentSearches: [String]
    var onClearAll: () -> Void
    var onSelectRecent: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Clear") { onClearAll() }
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(recentSearches, id: \.self) { term in
                        Button(action: { onSelectRecent(term) }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                Text(term)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
}

struct UnifiedSearchResultsContent: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Users section
                if !viewModel.searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("People")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        ForEach(viewModel.searchResults) { result in
                            SearchResultCard(result: result)
                        }
                    }
                }
                
                // Posts section (sample data)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Posts")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    ForEach(0..<5, id: \.self) { index in
                        PostSearchCard(
                            username: "User\(index + 1)",
                            content: "This is a sample post about civic engagement and community participation...",
                            likes: 50 + index * 10,
                            comments: 10 + index * 2
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Supporting Views

struct TrendingTopicCard: View {
    let topic: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(topic)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct PopularUserCard: View {
    let username: String
    let interests: [String]
    let activity: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(username.prefix(1)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(interests.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(activity)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button("Follow") {
                // Follow user
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.appPrimary)
            .cornerRadius(16)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentSearchRow: View {
    let searchTerm: String
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(searchTerm)
                .font(.body)
            
            Spacer()
            
            Button("Remove") {
                // Remove from recent searches
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 8)
    }
}

struct SearchResultCard: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.type.icon)
                .font(.title2)
                .foregroundColor(.appPrimary)
                .frame(width: 40, height: 40)
                .background(Color.appPrimary.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(result.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(result.type.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appPrimary.opacity(0.1))
                .foregroundColor(.appPrimary)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.dynamicTertiaryBackground(for: .system))
        .cornerRadius(12)
    }
}

struct UserSearchCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(String(user.username.prefix(1)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(user.interests.isEmpty ? "No interests available" : user.interests.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button("Follow") {
                // Follow user
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.appPrimary)
            .cornerRadius(16)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PostSearchCard: View {
    let username: String
    let content: String
    let likes: Int
    let comments: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(username.prefix(1)))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    )
                
                Text(username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("2h ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(content)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                        .font(.caption)
                    Text("\(likes)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "message")
                        .font(.caption)
                    Text("\(comments)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Removed PollSearchCard in redesigned Search to simplify to People/Posts

#Preview {
    SearchView()
}


