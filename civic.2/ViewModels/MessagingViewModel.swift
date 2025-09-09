import Foundation
import Combine

class MessagingViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var currentChat: Chat?
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var newMessageText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadChats()
    }
    
    func loadChats() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chats = self.generateSampleChats()
            self.isLoading = false
        }
    }
    
    func selectChat(_ chat: Chat) {
        currentChat = chat
        loadMessages(for: chat.id)
    }
    
    func loadMessages(for chatId: String) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messages = self.generateSampleMessages(for: chatId)
            self.isLoading = false
        }
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let chat = currentChat else { return }
        
        let message = Message(
            chatId: chat.id,
            senderId: "current_user", // This would be the actual current user ID
            content: newMessageText,
            messageType: .text
        )
        
        messages.append(message)
        newMessageText = ""
        
        // Update last message in chat
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            var updatedChat = chats[index]
            updatedChat.lastMessage = message
            updatedChat.lastMessageAt = message.timestamp
            chats[index] = updatedChat
        }
        
        // In a real app, this would send the message to the server
    }
    
    func deleteChat(_ chat: Chat) {
        // Remove from chats array
        chats.removeAll { $0.id == chat.id }
        
        // If the deleted chat was currently selected, clear the current chat
        if currentChat?.id == chat.id {
            currentChat = nil
            messages = []
        }
        
        // In a real app, this would also delete the chat from the server
    }
    
    func createNewChat(with userIds: [String], isGroup: Bool = false, groupName: String? = nil) {
        let chat = Chat(
            participants: userIds,
            isGroup: isGroup,
            groupName: groupName
        )
        
        chats.insert(chat, at: 0)
        selectChat(chat)
    }
    
    private func generateSampleChats() -> [Chat] {
        let sampleMessages = [
            Message(
                chatId: "chat1",
                senderId: "user1",
                content: "Hey! Did you see the new infrastructure proposal?",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            Message(
                chatId: "chat2",
                senderId: "user2",
                content: "The community meeting was really informative!",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-1800)
            )
        ]
        
        return [
            Chat(
                id: "chat1",
                participants: ["current_user", "user1"],
                lastMessage: sampleMessages[0],
                lastMessageAt: sampleMessages[0].timestamp,
                isGroup: false
            ),
            Chat(
                id: "chat2",
                participants: ["current_user", "user2"],
                lastMessage: sampleMessages[1],
                lastMessageAt: sampleMessages[1].timestamp,
                isGroup: false
            ),
            Chat(
                id: "chat3",
                participants: ["current_user", "user3", "user4", "user5"],
                lastMessage: Message(
                    chatId: "chat3",
                    senderId: "user3",
                    content: "Thanks everyone for the great discussion!",
                    messageType: .text,
                    timestamp: Date().addingTimeInterval(-900)
                ),
                lastMessageAt: Date().addingTimeInterval(-900),
                isGroup: true,
                groupName: "Community Advocates"
            )
        ]
    }
    
    private func generateSampleMessages(for chatId: String) -> [Message] {
        return [
            Message(
                chatId: chatId,
                senderId: "user1",
                content: "Hello! How are you doing today?",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-7200)
            ),
            Message(
                chatId: chatId,
                senderId: "current_user",
                content: "I'm doing great! Just finished reading about the new education policy.",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-7000)
            ),
            Message(
                chatId: chatId,
                senderId: "user1",
                content: "That's interesting! What are your thoughts on it?",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-6800)
            ),
            Message(
                chatId: chatId,
                senderId: "current_user",
                content: "I think it's a step in the right direction, but there are some areas that could be improved.",
                messageType: .text,
                timestamp: Date().addingTimeInterval(-6500)
            )
        ]
    }
}
