
import Foundation
import SwiftData

@Model
class ConversationEntity: Identifiable {
    @Attribute(.unique)
    private(set) var id: String
    
    var title: String
    private(set) var createAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MessageEntity.conversation)
    private var messages: [MessageEntity]

    init(from conversation: Conversation) {
        self.id = conversation.id
        self.title = conversation.title
        self.createAt = conversation.createAt
        self.messages = []
    }
    
    var toConversation: Conversation {
        return Conversation(id: id, title: title, createAt: createAt)
    }
}

