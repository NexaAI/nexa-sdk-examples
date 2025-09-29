import SwiftUI

struct ChatAssistantGenerationView: View {
    let message: Message
    var onExpandButtonPressed: ((Bool) -> Void)?
    var body: some View {
        VStack(spacing: 0) {
            ChatAssistantBubbleView(
                message: message,
                isComplete: !message.partation.other.isEmpty,
                onExpandButtonPressed: onExpandButtonPressed
            )
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    ChatAssistantGenerationView(message: .assistant("hello world")) { _ in

    }
}
