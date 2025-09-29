import SwiftUI
import AVFoundation

struct ChatAssistantBubbleView: View {
    @Environment(ModelManager.self) private var modelManager

    let message: Message
    let isComplete: Bool
    var showAction: Bool = false
    @State var isExpand: Bool = false
    @State var isThinkModeOn: Bool = false
    @State var showMenu: Bool = false

    var onExpandButtonPressed: ((Bool) -> Void)?
    var onCopyButtonPress: ((Message) -> Void)?
    var onVolumeButtonPress: ((Message) -> Void)?
    var onRegenerateButtonPress: ((Message) -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            if modelManager.configManager.isThinkModeOn, !message.partation.think.isEmpty {
                thinkView
            }

            if !isComplete, message.partation.other.isEmpty {
                ActivityIndicatorView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            } else {
                if !message.partation.other.isEmpty {
                    let rawStr = message.partation.other
                    MarkdownView(content: rawStr)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .onLongPressGesture(perform: {
                            UIDevice.impactOccurred(style: .medium)
                            showMenu = true
                        })
                        .anyPopover(
                            isPresented: $showMenu,
                            position: .auto,
                            contentSize: .init(width: 250, height: 152-51)
                        ) {
                            MenuListView(items: [
                                .init(title: "Copy", icon: .copy, action: {
                                    UIPasteboard.general.string = rawStr.trimmingCharacters(in: .whitespacesAndNewlines)
                                    showMenu = false
                                }),
//                                .init(title: "Play Text", icon: .volume2, action: {
//                                    showMenu = false
//                                    speak()
//                                }),
                                .init(title: "Regenerate", icon: .refreshCw, action: {
                                    showMenu = false
                                    onRegenerateButtonPress?(message)
                                })
                            ])
                            .frame(width: 250, height: 152-51)
                            .offset(x: 16)
                        }
                }
            }

            if message.profile != nil {
                AssistentProfilingView(
                    message: message,
                    showAction: showAction,
                    onVolumeButtonPress: { _ in
                        speak()
                    },
                    onRegenerateButtonPress: onRegenerateButtonPress
                )
            }
        }
    }

    private var thinkView: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.Thinkingbox.dotFront)
                    .square(14)
                    .padding(3.5)
                    .background(
                        Circle()
                            .fill(Color.Thinkingbox.dotBack)
                    )
                Text(isComplete ? "Thinking Completed" : "Thinking ...")
                    .textStyle(.subtitle1(textColor: Color.Thinkingbox.font))
                Spacer()
                Image(.chevronDown)
                    .renderingMode(.template)
                    .scaledToFit()
                    .square(16)
                    .rotationEffect(isExpand ? .degrees(0) : .degrees(-90))
                    .foregroundStyle(Color.Thinkingbox.icon)
            }
            .anyButton {
                isExpand.toggle()
                onExpandButtonPressed?(isExpand)
            }
            if isExpand {
                let think = message.partation.think
                MarkdownView(content: think, fontSize: 14, fontColor: Color.Thinkingbox.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.Thinkingbox.border, lineWidth: 1)
        )
    }

    private func speak() {
        AudioPlayerManager.speak(message.partation.other)
    }
}

#Preview {
    ScrollView {
        ChatAssistantBubbleView(message: .assistant("thiLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreis a think message this is a think this is a think this is a think this is a think</think> orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor "), isComplete: true, showAction: true, isExpand: false)

        ChatAssistantBubbleView(message: .assistant("<think>thiLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreis a think message this is a think this is a think this is a think this is a think</think> orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor "), isComplete: true, isExpand: false)

        ChatAssistantBubbleView(message: .assistant("<think>thiLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreis a think message this is a think this is a think this is a think this is a think</think>"), isComplete: false, isExpand: false)

        ChatAssistantBubbleView(message: .assistant("<think>thiLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et doloreis a think message this is a think this is a think this is a think this is a think</think>\n this is answer iscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, conseiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, conseiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, conseiscing elit, sed do eiusmod tempor incididunt ut labore et dolore Lorem ipsum dolor sit amet, conse"), isComplete: false, isExpand: false)
        ChatAssistantBubbleView(message: .assistant("<think>this is a think message</think>\n this is answer"), isComplete: true, isExpand: true)
        Spacer()
    }
    .previewEnvironment()
}
