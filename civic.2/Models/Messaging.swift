import Foundation

// MARK: - Chat Model
struct Chat: Codable, Identifiable {
    let id: String
    let participants: [String] // User IDs
    var lastMessage: Message?
    var lastMessageAt: Date?
    let isGroup: Bool
    let groupName: String?
    let groupImage: String?
    let createdAt: Date
    let isActive: Bool
    
    init(id: String = UUID().uuidString, participants: [String], lastMessage: Message? = nil, lastMessageAt: Date? = nil, isGroup: Bool = false, groupName: String? = nil, groupImage: String? = nil, createdAt: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.lastMessageAt = lastMessageAt
        self.isGroup = isGroup
        self.groupName = groupName
        self.groupImage = groupImage
        self.createdAt = createdAt
        self.isActive = isActive
    }
}

// MARK: - Message Model
struct Message: Codable, Identifiable {
    let id: String
    let chatId: String
    let senderId: String
    let content: String
    let messageType: MessageType
    let timestamp: Date
    let isRead: Bool
    let readBy: [String] // User IDs who have read the message
    let replyTo: String? // ID of message being replied to
    let attachments: [MessageAttachment]
    let reactions: [MessageReaction]
    
    init(id: String = UUID().uuidString, chatId: String, senderId: String, content: String, messageType: MessageType = .text, timestamp: Date = Date(), isRead: Bool = false, readBy: [String] = [], replyTo: String? = nil, attachments: [MessageAttachment] = [], reactions: [MessageReaction] = []) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.content = content
        self.messageType = messageType
        self.timestamp = timestamp
        self.isRead = isRead
        self.readBy = readBy
        self.replyTo = replyTo
        self.attachments = attachments
        self.reactions = reactions
    }
}

// MARK: - Message Type Enum
enum MessageType: String, CaseIterable, Codable {
    case text = "text"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case file = "file"
    case location = "location"
    case poll = "poll"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        case .file: return "File"
        case .location: return "Location"
        case .poll: return "Poll"
        case .system: return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .text: return "text.bubble"
        case .image: return "photo"
        case .video: return "video"
        case .audio: return "mic"
        case .file: return "doc"
        case .location: return "location"
        case .poll: return "chart.bar"
        case .system: return "gear"
        }
    }
}

// MARK: - Message Attachment Model
struct MessageAttachment: Codable, Identifiable {
    let id: String
    let type: MessageType
    let url: String
    let filename: String
    let size: Int64
    let mimeType: String
    let thumbnailUrl: String?
    
    init(id: String = UUID().uuidString, type: MessageType, url: String, filename: String, size: Int64, mimeType: String, thumbnailUrl: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.filename = filename
        self.size = size
        self.mimeType = mimeType
        self.thumbnailUrl = thumbnailUrl
    }
}

// MARK: - Message Reaction Model
struct MessageReaction: Codable, Identifiable {
    let id: String
    let messageId: String
    let userId: String
    let emoji: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString, messageId: String, userId: String, emoji: String, timestamp: Date = Date()) {
        self.id = id
        self.messageId = messageId
        self.userId = userId
        self.emoji = emoji
        self.timestamp = timestamp
    }
}
