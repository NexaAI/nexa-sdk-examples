import Foundation

struct Conversation: Identifiable, Equatable {
    var id: String
    var title: String
    var createAt: Date

    init(id: String = UUID().uuidString, title: String, createAt: Date = .now) {
        self.id = id
        self.title = title
        self.createAt = createAt
    }
}

extension Conversation {
    static var mocks: [Conversation] {
        [
            Conversation(title: "Project Discuss"),
            Conversation(title: "Record", createAt: Date().addingTimeInterval(-3600)),
            Conversation(title: "Hello", createAt: Date().addingTimeInterval(-7200)),
            Conversation(title: "World", createAt: Date().addingTimeInterval(-86400)),
            Conversation(title: "Are You OK", createAt: Date().addingTimeInterval(-172800)),
            Conversation(title: "Today", createAt: Date()),
            Conversation(title: "LastWeak", createAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!),
            Conversation(title: "两周前", createAt: Calendar.current.date(byAdding: .day, value: -14, to: Date())!),
            Conversation(title: "三周前", createAt: Calendar.current.date(byAdding: .day, value: -21, to: Date())!),
            Conversation(title: "1个月前", createAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            Conversation(title: "1个月前", createAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            Conversation(title: "2024", createAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)

        ]
    }
}
