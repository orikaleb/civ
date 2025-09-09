import SwiftUI

struct RatingView: View {
    @StateObject private var viewModel = RatingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rate Government Performance")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Share your opinion on how the government is performing in different areas. Your ratings help inform policy decisions.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Rating categories
                    ForEach(RatingCategory.allCases, id: \.self) { category in
                        RatingCategoryCard(
                            category: category,
                            rating: viewModel.getRating(for: category),
                            onRatingChanged: { newRating in
                                viewModel.updateRating(for: category, rating: newRating)
                            }
                        )
                    }
                    
                    // Submit button
                    if viewModel.hasAnyRating {
                        CivicButton("Submit Ratings") {
                            viewModel.submitRatings(userId: appViewModel.currentUser?.id ?? "")
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Recent ratings
                    if !viewModel.recentRatings.isEmpty {
                        RecentRatingsSection(ratings: viewModel.recentRatings)
                    }
                }
            }
            .refreshable {
                viewModel.loadRecentRatings()
            }
            .navigationTitle("Rate Government")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct RatingCategoryCard: View {
    let category: RatingCategory
    let rating: Double
    let onRatingChanged: (Double) -> Void
    
    @State private var currentRating: Double = 0
    
    var body: some View {
        CivicCard {
            VStack(alignment: .leading, spacing: 16) {
                // Category header
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(Color(category.color))
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Rate from 1 to 5 stars")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if rating > 0 {
                        Text(String(format: "%.1f", rating))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                // Star rating
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            currentRating = Double(star)
                            onRatingChanged(currentRating)
                        }) {
                            Image(systemName: star <= Int(currentRating) ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(star <= Int(currentRating) ? .yellow : .gray)
                        }
                    }
                    
                    Spacer()
                }
                
                // Slider for fine-tuning
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Fine-tune rating:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", currentRating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: $currentRating, in: 0...5, step: 0.1)
                        .accentColor(.blue)
                        .onChange(of: currentRating) { _, newValue in
                            onRatingChanged(newValue)
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            currentRating = rating
        }
    }
}

struct RecentRatingsSection: View {
    let ratings: [GovernmentRating]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Community Ratings")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ratings.prefix(10)) { rating in
                        RecentRatingCard(rating: rating)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct RecentRatingCard: View {
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
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(rating.lastUpdated, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140)
    }
}

class RatingViewModel: ObservableObject {
    @Published var ratings: [RatingCategory: Double] = [:]
    @Published var recentRatings: [GovernmentRating] = []
    
    init() {
        loadRecentRatings()
    }
    
    func getRating(for category: RatingCategory) -> Double {
        return ratings[category] ?? 0
    }
    
    func updateRating(for category: RatingCategory, rating: Double) {
        ratings[category] = rating
    }
    
    var hasAnyRating: Bool {
        !ratings.values.allSatisfy { $0 == 0 }
    }
    
    func submitRatings(userId: String) {
        // Here you would typically send ratings to the backend
        for (category, rating) in ratings where rating > 0 {
            let _ = GovernmentRating(
                category: category,
                rating: rating
            )
            // Send to backend
            print("Submitting rating: \(category.rawValue) - \(rating)")
        }
        
        // Clear ratings after submission
        ratings.removeAll()
    }
    
    func loadRecentRatings() {
        // Mock data for recent ratings
        recentRatings = [
            GovernmentRating(category: .education, rating: 3.8),
            GovernmentRating(category: .healthcare, rating: 2.9),
            GovernmentRating(category: .economy, rating: 4.1),
            GovernmentRating(category: .infrastructure, rating: 3.2),
            GovernmentRating(category: .security, rating: 4.5),
            GovernmentRating(category: .environment, rating: 3.7)
        ]
    }
}

#Preview {
    RatingView()
        .environmentObject(AppViewModel())
}







