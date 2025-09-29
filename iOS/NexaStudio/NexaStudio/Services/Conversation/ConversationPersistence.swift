
import Foundation
import SwiftData

@MainActor
protocol ConversationPersistence {
    func addConversation(_ firstMessage: Message) throws -> Conversation 
    func getConversations() throws -> [Conversation]
    func getConversation(by conversationId: String) throws -> Conversation
    func updateTitle(of conversationId: String, title: String) throws
    func deleteConversation(by conversationId: String) throws
    func addMessage(conversationId: String, message: Message) throws
    func removeMessage(conversationId: String, message: Message) throws
    func removeMessages(of conversationId: String, after message: Message) throws 
    func fetchMessages(by conversationId: String) throws -> [Message]
    func fetchMessages(by conversationId: String, offset: Int, limit: Int) throws -> [Message]
}
