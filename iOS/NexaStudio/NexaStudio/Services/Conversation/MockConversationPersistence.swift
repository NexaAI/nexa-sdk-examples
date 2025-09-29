
import Foundation
import SwiftData

@MainActor
class MockConversationPersistence: ConversationPersistence {

    private var convs: [Conversation] = []
    private var messagesMap: [String: [Message]] = .init()

    init() {
        convs = Conversation.mocks
    }

    func addConversation(_ firstMessage: Message) throws -> Conversation {
        let conv = Conversation(title: firstMessage.content)
        convs.append(conv)
        return conv
    }

    func getConversations() throws -> [Conversation] {
        convs
    }

    func updateTitle(of conversationId: String, title: String) throws {

    }

    func addMessage(conversationId: String, message: Message) throws {
        messagesMap[conversationId, default: []].append(message)
    }

    func removeMessage(conversationId: String, message: Message) throws {
        messagesMap[conversationId, default: []].removeAll { $0.id == message.id }
    }

    func removeMessages(of conversationId: String, after message: Message) throws {

    }

    func getConversation(by conversationId: String) throws -> Conversation {
        if let conv = convs.first(where: { $0.id == conversationId }) {
            return conv
        }
        throw NSError(domain: "conversation not found", code: 404)
    }

    func fetchMessages(by conversationId: String, offset: Int, limit: Int = 50) throws -> [Message] {
        messagesMap[conversationId, default: []]
    }

    func fetchMessages(by conversationId: String) throws -> [Message] {
        try fetchMessages(by: conversationId, offset: 0)
    }

    func deleteConversation(by conversationId: String) throws {
        convs.removeAll { $0.id == conversationId }
    }
}
