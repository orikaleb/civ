import Foundation

// MARK: - Poll Model
struct Poll: Codable, Identifiable {
    let id: String
    let question: String
    let options: [PollOption]
    let totalVotes: Int
    let isActive: Bool
    let createdAt: Date
    let expiresAt: Date?
    let endDate: Date?
    let category: String
    let createdBy: String
    
    init(id: String = UUID().uuidString, question: String, options: [PollOption], totalVotes: Int = 0, isActive: Bool = true, createdAt: Date = Date(), expiresAt: Date? = nil, endDate: Date? = nil, category: String = "General", createdBy: String) {
        self.id = id
        self.question = question
        self.options = options
        self.totalVotes = totalVotes
        self.isActive = isActive
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.endDate = endDate
        self.category = category
        self.createdBy = createdBy
    }
}

// MARK: - Poll Option Model
struct PollOption: Codable, Identifiable {
    let id: String
    let text: String
    let votes: Int
    let percentage: Double
    
    init(id: String = UUID().uuidString, text: String, votes: Int = 0, percentage: Double = 0.0) {
        self.id = id
        self.text = text
        self.votes = votes
        self.percentage = percentage
    }
}

// MARK: - Poll Vote Model
struct PollVote: Codable, Identifiable {
    let id: String
    let pollId: String
    let optionId: String
    let userId: String
    let votedAt: Date
    
    init(id: String = UUID().uuidString, pollId: String, optionId: String, userId: String, votedAt: Date = Date()) {
        self.id = id
        self.pollId = pollId
        self.optionId = optionId
        self.userId = userId
        self.votedAt = votedAt
    }
}
