import SwiftUI

struct RecommendationsView: View {
    @StateObject private var viewModel = RecommendationsViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingNewRecommendation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                filterTabsSection
                recommendationsListSection
            }
            .navigationTitle("Recommendations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewRecommendation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private var filterTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecommendationFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var recommendationsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredRecommendations) { recommendation in
                    RecommendationCard(
                        recommendation: recommendation,
                        onUpvote: {
                            viewModel.upvoteRecommendation(recommendation)
                        },
                        onDownvote: {
                            viewModel.downvoteRecommendation(recommendation)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            viewModel.refreshData()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
    }
}

struct RecommendationCard: View {
    let recommendation: Recommendation
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(recommendation.category.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    StatusBadge(status: recommendation.status)
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(recommendation.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(recommendation.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
                
                // Author and date
                HStack {
                    Text("by \(recommendation.createdBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(recommendation.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Voting section
                HStack {
                    // Upvote button
                    Button(action: onUpvote) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.caption)
                            Text("\(recommendation.votes)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Downvote button
                    Button(action: onDownvote) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.caption)
                            Text("0")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Net votes
                    Text("\(recommendation.votes) votes")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(recommendation.votes >= 0 ? .green : .red)
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: RecommendationStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color))
            .cornerRadius(8)
    }
}

struct NewRecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = "General"
    
    let onSubmit: (String, String, String) -> Void
    
    private let categories = [
        "General", "Infrastructure", "Education", "Healthcare", "Environment",
        "Technology", "Transportation", "Housing", "Social Welfare", "Economy"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submit a Recommendation")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Share your ideas for improving government services and community life.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        CivicTextField(placeholder: "Title", text: $title, icon: "textformat")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                    }
                    
                    CivicButton("Submit Recommendation") {
                        onSubmit(title, description, selectedCategory)
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("New Recommendation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecommendationsView()
        .environmentObject(AppViewModel())
}


