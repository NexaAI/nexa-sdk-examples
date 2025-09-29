
import SwiftUI


struct ChatBubbleView: View {

    let message: Message
    
    // only assistant message used
    var isExpand: Bool = false
    var showAction: Bool = false
    var onRegenerateButtonPress: ((Message) -> Void)?

    // only use message used
    var onEditMenuPressed: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch message.role {
        case .user:
            ChatUserBubbleView(
                message: message,
                onEditMenuPressed: onEditMenuPressed
            )
        case .assistant:
            ChatAssistantBubbleView(
                message: message,
                isComplete: true,
                showAction: true,
                isExpand: isExpand,
                onRegenerateButtonPress: onRegenerateButtonPress
            )
            .padding(.vertical, 8)
        case .system:
            EmptyView()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView(message: .user("This is a user message"))
            ChatBubbleView(message: .user("This is a user long longlonglonglonglonglonglonglonglong longlonglonglong message"))
            ChatBubbleView(message: .assistant("This is a assistant message"), isExpand: false)
            ChatBubbleView(message: .init(role: .assistant, content: "gl glong longlongloglong longlongloglong longlongloglong longlongloglong longlongloglong longlongloo glo ", images: [URL(string: Constants.randomImage)!]), isExpand: true)

            ChatBubbleView(message: .assistant("This is a This is a user long longlonglonglonglonglonglonglonglong longlonglonglong message generate image"))
            ChatBubbleView(message: .init(role: .user, content: "gl glong longlongloglong longlongloglong longlongloglong longlongloglong longlongloglong longlongloo glo ", images: [URL(string: Constants.randomImage)!]))
        }
    }
    .previewEnvironment()
}
