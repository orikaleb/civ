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
        // Mock polls - Ghana-specific civic engagement topics
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
            ),
            Poll(
                question: "What should be the government's top priority for infrastructure development?",
                options: [
                    PollOption(text: "Roads and highways", votes: 2100),
                    PollOption(text: "Electricity grid expansion", votes: 1800),
                    PollOption(text: "Water and sanitation", votes: 1650),
                    PollOption(text: "Digital infrastructure", votes: 1200),
                    PollOption(text: "Public transportation", votes: 950)
                ],
                endDate: Date().addingTimeInterval(10 * 24 * 3600),
                category: "Infrastructure",
                createdBy: "system"
            ),
            Poll(
                question: "How should Ghana address the rising cost of living?",
                options: [
                    PollOption(text: "Increase minimum wage", votes: 1950),
                    PollOption(text: "Reduce taxes on essential goods", votes: 1750),
                    PollOption(text: "Subsidize fuel prices", votes: 1400),
                    PollOption(text: "Strengthen social safety nets", votes: 1200),
                    PollOption(text: "Promote local production", votes: 1100)
                ],
                endDate: Date().addingTimeInterval(8 * 24 * 3600),
                category: "Economy",
                createdBy: "system"
            ),
            Poll(
                question: "What is the most effective way to combat corruption in Ghana?",
                options: [
                    PollOption(text: "Strengthen anti-corruption institutions", votes: 1850),
                    PollOption(text: "Increase transparency in government", votes: 1600),
                    PollOption(text: "Harsher penalties for corrupt officials", votes: 1450),
                    PollOption(text: "Public education and awareness", votes: 1200),
                    PollOption(text: "Whistleblower protection programs", votes: 900)
                ],
                endDate: Date().addingTimeInterval(12 * 24 * 3600),
                category: "Governance",
                createdBy: "system"
            ),
            Poll(
                question: "Should Ghana invest more in renewable energy sources?",
                options: [
                    PollOption(text: "Yes, prioritize solar energy", votes: 2200),
                    PollOption(text: "Yes, focus on wind power", votes: 1100),
                    PollOption(text: "Yes, develop hydroelectric projects", votes: 1300),
                    PollOption(text: "No, stick to traditional energy", votes: 800),
                    PollOption(text: "Mixed approach is best", votes: 1600)
                ],
                endDate: Date().addingTimeInterval(9 * 24 * 3600),
                category: "Environment",
                createdBy: "system"
            ),
            Poll(
                question: "What should be done to improve youth employment in Ghana?",
                options: [
                    PollOption(text: "Create more government jobs", votes: 1400),
                    PollOption(text: "Support entrepreneurship programs", votes: 1800),
                    PollOption(text: "Improve technical and vocational training", votes: 1650),
                    PollOption(text: "Attract foreign investment", votes: 1200),
                    PollOption(text: "Develop digital economy opportunities", votes: 1350)
                ],
                endDate: Date().addingTimeInterval(6 * 24 * 3600),
                category: "Youth Development",
                createdBy: "system"
            ),
            Poll(
                question: "How should Ghana address climate change impacts?",
                options: [
                    PollOption(text: "Implement climate adaptation programs", votes: 1700),
                    PollOption(text: "Promote sustainable agriculture", votes: 1550),
                    PollOption(text: "Protect coastal areas from erosion", votes: 1300),
                    PollOption(text: "Develop early warning systems", votes: 1100),
                    PollOption(text: "International climate partnerships", votes: 950)
                ],
                endDate: Date().addingTimeInterval(11 * 24 * 3600),
                category: "Climate Change",
                createdBy: "system"
            ),
            Poll(
                question: "What is the best approach to improve healthcare access in rural areas?",
                options: [
                    PollOption(text: "Build more rural health centers", votes: 1900),
                    PollOption(text: "Mobile health clinics", votes: 1600),
                    PollOption(text: "Telemedicine services", votes: 1400),
                    PollOption(text: "Train more community health workers", votes: 1750),
                    PollOption(text: "Improve transportation to existing facilities", votes: 1200)
                ],
                endDate: Date().addingTimeInterval(7 * 24 * 3600),
                category: "Healthcare",
                createdBy: "system"
            ),
            Poll(
                question: "Should Ghana implement a national digital ID system?",
                options: [
                    PollOption(text: "Yes, it will improve service delivery", votes: 1650),
                    PollOption(text: "Yes, but with strong privacy protections", votes: 1800),
                    PollOption(text: "No, privacy concerns are too great", votes: 1100),
                    PollOption(text: "Need more public consultation first", votes: 1350),
                    PollOption(text: "Unsure", votes: 600)
                ],
                endDate: Date().addingTimeInterval(14 * 24 * 3600),
                category: "Digital Governance",
                createdBy: "system"
            ),
            Poll(
                question: "What should be the priority for improving public transportation in Accra?",
                options: [
                    PollOption(text: "Expand the BRT system", votes: 2000),
                    PollOption(text: "Improve existing trotro services", votes: 1500),
                    PollOption(text: "Build a metro/light rail system", votes: 1800),
                    PollOption(text: "Better traffic management", votes: 1200),
                    PollOption(text: "Promote cycling infrastructure", votes: 800)
                ],
                endDate: Date().addingTimeInterval(8 * 24 * 3600),
                category: "Transportation",
                createdBy: "system"
            ),
            Poll(
                question: "How should Ghana promote local manufacturing and industry?",
                options: [
                    PollOption(text: "Provide tax incentives to manufacturers", votes: 1750),
                    PollOption(text: "Improve access to credit for businesses", votes: 1600),
                    PollOption(text: "Develop industrial zones", votes: 1400),
                    PollOption(text: "Protect local industries from imports", votes: 1200),
                    PollOption(text: "Invest in skills training for workers", votes: 1450)
                ],
                endDate: Date().addingTimeInterval(10 * 24 * 3600),
                category: "Industry",
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

