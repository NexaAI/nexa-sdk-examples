import SwiftData
import Foundation

@Observable
@MainActor
class ConversationManager {

    let persistence: ConversationPersistence

    init(persistence: ConversationPersistence) {
        self.persistence = persistence
    }

    func addMessage(conversationId: String, message: Message) throws {
        try persistence.addMessage(conversationId: conversationId, message: message)
    }

    func removeMessage(conversationId: String, message: Message) throws {
        try persistence.removeMessage(conversationId: conversationId, message: message)
    }

    func removeMessages(of conversationId: String, after message: Message) throws {
        try persistence.removeMessages(of: conversationId, after: message)
    }

    func addConversation(_ firstMessage: Message) throws -> Conversation {
        try persistence.addConversation(firstMessage)
    }

    func getConversations() throws -> [Conversation] {
        try persistence.getConversations()
    }

    func updateTitle(of conversationId: String, title: String) throws {
        try persistence.updateTitle(of: conversationId, title: title)
    }

    func getConversationsAndGroupByWeekAndMonth() throws -> [(ConversationGroup, [Conversation])] {
        let conversations = try getConversations().sorted { $0.createAt > $1.createAt }
        var grouped: [ConversationGroup: [Conversation]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for conversation in conversations  {
            let date = conversation.createAt
            if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                grouped[.thisWeek, default: []].append(conversation)
            } else if
                let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
                calendar.isDate(date, equalTo: lastWeek, toGranularity: .weekOfYear) {
                grouped[.lastWeek, default: []].append(conversation)
            } else {
                let comps = calendar.dateComponents([.year, .month], from: date)
                if let year = comps.year, let month = comps.month {
                    grouped[.month(year: year, month: month), default: []].append(conversation)
                }
            }
        }
        return grouped.map { ($0, $1) }.sorted(by: { $0.0 > $1.0 })
    }

    func getConversationsAndGroupByWeek() throws -> [(title: String, conversations: [Conversation])] {
        let conversations = try getConversations()
        let calendar = Calendar.current
        let now = Date()

        struct Week {
            let diff: Int
            var data: [Conversation]
        }
        var weeks = [Int: Week]()
        for conversation in conversations {
            if calendar.isDateInToday(conversation.createAt) {
                weeks[-1, default: .init(diff: -1, data: [])].data.append(conversation)
            } else {
                let weeksDiff = calendar.dateComponents([.weekOfYear], from: conversation.createAt, to: now).weekOfYear ?? 0
                weeks[weeksDiff, default: .init(diff: -1, data: [])].data.append(conversation)
            }
        }

        let sorted = weeks.sorted { $0.key < $1.key }
        var result = [(title: String, conversations: [Conversation])]()
        for week in sorted {
            if week.key == -1 {
                result.append(("Today", week.value.data))
            } else if week.key == 0 {
                result.append(("This Week", week.value.data))
            } else if week.key == 1 {
                result.append(("Last Week", week.value.data))
            } else  {
                result.append(("\(week.key) Weeks Ago", week.value.data))
            }
        }

        return result
    }

    func getConversation(by conversationId: String) throws -> Conversation {
        try persistence.getConversation(by: conversationId)
    }

    func fetchMessages(by conversationId: String) throws -> [Message] {
        try persistence.fetchMessages(by: conversationId)
    }

    func fetchMessages(by conversationId: String, offset: Int, limit: Int = 50) throws -> [Message] {
        try persistence.fetchMessages(by: conversationId, offset: offset, limit: limit)
    }

    func deleteConversation(by conversationId: String) throws {
        try persistence.deleteConversation(by: conversationId)
    }
}

enum ConversationGroup: Hashable, Comparable {
    case thisWeek
    case lastWeek
    case month(year: Int, month: Int)

    var sortOrder: Int {
        switch self {
        case .thisWeek: return Int.max
        case .lastWeek: return Int.max - 1
        case .month(let year, let month): return year * 12 + month
        }
    }

    static func > (lhs: ConversationGroup, rhs: ConversationGroup) -> Bool {
        return lhs.sortOrder > rhs.sortOrder
    }

    var displayName: String {
        switch self {
        case .thisWeek: return "This Week"
        case .lastWeek: return "Last Week"
        case .month(let year, let month):
            let monthAbbreviations = [
                "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
            ]
            return "\(monthAbbreviations[month - 1]) \(year)"
        }
    }
}
