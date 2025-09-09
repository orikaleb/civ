import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var polls: [Poll] = []
    @Published var trendingRatings: [GovernmentRating] = []
    @Published var newsSnippets: [NewsSnippet] = []
    @Published var ads: [Ad] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
    }
    
    func refreshData() {
        isRefreshing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadMockData()
            self.isRefreshing = false
        }
    }
    
    private func loadMockData() {
        // Mock polls
        polls = [
            Poll(
                question: "Should the government increase funding for public education?",
                options: [
                    PollOption(text: "Yes, significantly", votes: 1250),
                    PollOption(text: "Yes, moderately", votes: 890),
                    PollOption(text: "No, current funding is sufficient", votes: 450),
                    PollOption(text: "No, funding should be reduced", votes: 120)
                ],
                endDate: Date().addingTimeInterval(7 * 24 * 3600),
                category: "Education",
                createdBy: "system"
            ),
            Poll(
                question: "Do you support the new healthcare reform bill?",
                options: [
                    PollOption(text: "Strongly support", votes: 980),
                    PollOption(text: "Support", votes: 750),
                    PollOption(text: "Neutral", votes: 320),
                    PollOption(text: "Oppose", votes: 280),
                    PollOption(text: "Strongly oppose", votes: 150)
                ],
                endDate: Date().addingTimeInterval(5 * 24 * 3600),
                category: "Healthcare",
                createdBy: "system"
            )
        ]
        
        // Mock trending ratings
        trendingRatings = [
            GovernmentRating(category: .education, rating: 3.8),
            GovernmentRating(category: .healthcare, rating: 2.9),
            GovernmentRating(category: .economy, rating: 4.1),
            GovernmentRating(category: .infrastructure, rating: 3.2)
        ]
        
        // Mock news snippets
        newsSnippets = [
            NewsSnippet(
                title: "New Education Policy Announced",
                summary: "Government introduces comprehensive education reform focusing on digital literacy and STEM education.",
                category: "Education",
                publishedAt: Date().addingTimeInterval(-3600)
            ),
            NewsSnippet(
                title: "Healthcare Budget Increased by 15%",
                summary: "Parliament approves significant increase in healthcare funding for the upcoming fiscal year.",
                category: "Healthcare",
                publishedAt: Date().addingTimeInterval(-7200)
            ),
            NewsSnippet(
                title: "Infrastructure Development Plan",
                summary: "Major infrastructure projects announced to improve transportation and connectivity.",
                category: "Infrastructure",
                publishedAt: Date().addingTimeInterval(-10800)
            )
        ]
        
        // Mock ads
        ads = [
            Ad(
                title: "Learn Digital Skills for Free",
                description: "Join our online courses and boost your career with in-demand digital skills. Government-sponsored program.",
                imageUrl: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400",
                advertiser: "Ministry of Education",
                category: .education,
                callToAction: "Enroll Now",
                targetUrl: "https://education.gov.gh/digital-skills"
            ),
            Ad(
                title: "Healthcare Access Made Easy",
                description: "Get instant access to healthcare services through our mobile app. Book appointments, consult doctors online.",
                imageUrl: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400",
                advertiser: "HealthConnect Ghana",
                category: .healthcare,
                callToAction: "Download App",
                targetUrl: "https://healthconnect.gh"
            ),
            Ad(
                title: "Start Your Business Today",
                description: "Get funding and support for your startup. Government grants available for innovative business ideas.",
                imageUrl: "https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=400",
                advertiser: "Ghana Enterprise Agency",
                category: .business,
                callToAction: "Apply Now",
                targetUrl: "https://gea.gov.gh/startup-fund"
            ),
            Ad(
                title: "Community Development Program",
                description: "Join hands with your neighbors to improve your community. Volunteer opportunities available.",
                imageUrl: "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400",
                advertiser: "Community First Initiative",
                category: .community,
                callToAction: "Get Involved",
                targetUrl: "https://communityfirst.gh"
            )
        ]
    }
}

struct NewsSnippet: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let category: String
    let publishedAt: Date
}

