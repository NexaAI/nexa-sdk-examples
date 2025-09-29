
import Foundation
import SwiftData

@MainActor
struct LocalConversationPersistence: ConversationPersistence {

    private static var conversationNumber: Int = 1

    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }

    init() {
        self.container = try! ModelContainer(for: ConversationEntity.self)
    }

    func addConversation(_ firstMessage: Message) throws -> Conversation {
        let title: String
        if firstMessage.content.isEmpty {
            title = "chat\(Self.conversationNumber)"
            Self.conversationNumber += 1
        } else {
            title = firstMessage.content
        }

        let conversation = Conversation(title: title)

        let conversationEntity = ConversationEntity(from: conversation)
        mainContext.insert(conversationEntity)

        let messageEntity = MessageEntity(from: firstMessage)
        messageEntity.conversation = conversationEntity
        mainContext.insert(messageEntity)

        try mainContext.save()
        return conversation
    }

    func getConversations() throws -> [Conversation] {
        let descriptor = FetchDescriptor<ConversationEntity>(sortBy: [SortDescriptor(\.createAt, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map {
            $0.toConversation
        }
    }

    func removeMessages(of conversationId: String, after message: Message) throws {
        let createAt = message.createAt
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate {
                $0.conversation?.id == conversationId &&
                $0.createAt >= createAt
            }
        )
        let oldMessages = try mainContext.fetch(descriptor)
        for message in oldMessages {
            mainContext.delete(message)
        }
        try mainContext.save()
    }

    func updateTitle(of conversationId: String, title: String) throws {
        let descriptor = FetchDescriptor<ConversationEntity>(
            predicate: #Predicate { $0.id == conversationId }
        )

        let conversionEntity = try mainContext.fetch(descriptor).first
        guard let conversionEntity else {
            throw LocalConversationError.notFoundConversation(conversationId)
        }
        conversionEntity.title = title
        try mainContext.save()
    }

    func addMessage(conversationId: String, message: Message) throws {
        let descriptor = FetchDescriptor<ConversationEntity>(
            predicate: #Predicate { $0.id == conversationId }
        )
        let conversionEntity = try mainContext.fetch(descriptor).first
        guard let conversionEntity else {
            throw LocalConversationError.notFoundConversation(conversationId)
        }

        let messageEntity = MessageEntity(from: message)
        messageEntity.conversation = conversionEntity
        mainContext.insert(messageEntity)
        try mainContext.save()
    }

    func removeMessage(conversationId: String, message: Message) throws {
        let msgId = message.id
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate {
                $0.conversation?.id == conversationId &&
                $0.id == msgId
            }
        )
        if let entity = try mainContext.fetch(descriptor).first {
            mainContext.delete(entity)
        }
    }

    func deleteConversation(by conversationId: String) throws {
        try mainContext.delete(model: ConversationEntity.self, where: #Predicate { $0.id == conversationId })
    }

    func getConversation(by conversationId: String) throws -> Conversation {
        var descriptor = FetchDescriptor<ConversationEntity>(
            predicate: #Predicate { $0.id == conversationId }
        )
        descriptor.fetchLimit = 1
        let conversionEntity = try mainContext.fetch(descriptor).first
        guard let conversionEntity else {
            throw LocalConversationError.notFoundConversation(conversationId)
        }
        return conversionEntity.toConversation
    }

    func fetchMessages(by conversationId: String) throws -> [Message] {
        let descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { $0.conversation?.id == conversationId },
            sortBy: [SortDescriptor(\.createAt)]
        )
        let entity = try mainContext.fetch(descriptor)
        return entity.map { $0.toMessage }
    }

    func fetchMessages(by conversationId: String, offset: Int, limit: Int = 50) throws -> [Message] {
        var descriptor = FetchDescriptor<MessageEntity>(
            predicate: #Predicate { $0.conversation?.id == conversationId },
            sortBy: [SortDescriptor(\.createAt)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        let entity = try mainContext.fetch(descriptor)
        return entity.map { $0.toMessage }
    }

    enum LocalConversationError: Error {
        case notFoundConversation(String)
    }
}
