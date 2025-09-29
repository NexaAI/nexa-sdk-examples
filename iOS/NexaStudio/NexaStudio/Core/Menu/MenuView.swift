import SwiftUI

struct MenuView: View {

    @Environment(ConversationManager.self) var conversationManager
    @State private var conversationsGroup: [(key: ConversationGroup, conversations: [Conversation])] = .init()
    @State private var proxy: ScrollViewProxy?
    @State private var renameInputConfirm: AnyInputConfirm?
    @State private var longPressConversation: Conversation?
    var selectedConversationId: String



    var onConversationItemPressed: ((Conversation) -> Void)?
    var onNewChatButtonPressed: (() -> Void)?
    var onDeleteConversation: ((Conversation) -> Void)?
    var onModelsButtonPressed: (() -> Void)?
    var onSettingButtonPressed: (() -> Void)?

    var body: some View {
        ZStack {
            GeometryReader { content in
                let size = content.size
                VStack(spacing: 0) {
                    headerSection
                        .padding(.bottom, 24)
                    menuSection
                        .padding(.bottom, 24)
                    Divider().frame(height: 1)
                        .background(Color.Stroke.secondary)
                        .padding(.bottom, 24)
                    ScrollViewReader { proxy in
                        List {
                            conversationSection
                        }
                        .padding(.bottom, 24)
                        .listStyle(.plain)
                        .listSectionSpacing(0)
                        .scrollContentBackground(.hidden)
                        .offset(y: -20)
                        .ignoresSafeArea()
                        .onAppear {
                            self.proxy = proxy
                        }
                    }

                    Spacer()
                    bottomActionView
                        .padding(.bottom, 31)
                }
                .padding(.horizontal, 12)
                .ignoresSafeArea()
                .frame(width: size.width * 0.72)
                .shadow400(16, backgroundColor: Color.Background.secondary)
            }
        }
        .onAppear {
            loadConversations()
        }
        .anyInputConfirm($renameInputConfirm)
    }

    private var bottomActionView: some View {
        HStack(spacing: 0) {
            icon(.discord)
                .anyButton {
                    UIApplication.shared.open(Constants.discordUrl)
                }
            icon(.mail)
                .anyButton {
                    UIApplication.shared.open(Constants.githubUrl)
                }

            icon(.slack)
                .anyButton {
                    UIApplication.shared.open(Constants.slackUrl)
                }
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func icon(_ resource: ImageResource) -> some View {
        Image(resource)
            .resizable()
            .secondaryStyle()
            .scaledToFill()
            .square(20)
            .padding(6)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    private var headerSection: some View {
        Divider().frame(height: 68).opacity(0)
        Text("New Chat")
            .textStyle(.body1(textColor: Color.Button.Secondary.Text.default))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.Button.Secondary.Bg.default)
                    .stroke(Color.Button.Secondary.Border.default, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .anyButton {
                onNewChatButtonPressed?()
            }
    }

    private var menuSection: some View {
        VStack(spacing: 8) {
            menuItem(title: "Models", resource: .layoutGrid, action: onModelsButtonPressed)
            menuItem(title: "Settings", resource: .settings, action: onSettingButtonPressed)
        }
    }

    private func menuItem(title: String, resource: ImageResource, action: (() -> Void)?) -> some View {
        HStack(spacing: 8) {
            Image(resource)
                .menuStyle()
                .square(24)
            Text(title)
                .textStyle(.body2(textColor: Color.Menu.Font.default))
                .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
        .contentShape(Rectangle())
        .anyButton {
            action?()
        }
    }

    @ViewBuilder
    private var conversationSection: some View {
        ForEach(Array(conversationsGroup.enumerated()), id: \.offset) { section in
            let title = section.element.key.displayName
            let value = section.element.conversations
            let index = section.offset
                Section {
                    ForEach(value) { conv in
                        buildConversationItem(index, conv)
                            .removeListRowFormatting()
                            .id(conv.id)
                    }
                } header: {
                    Text(title)
                        .textStyle(.body2(textColor: Color.Text.tertiary))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.leading, 12)
                        .removeListRowFormatting()
                        .listBackground(Color.Background.secondary)
                }
            }

    }

    @ViewBuilder
    private func buildConversationItem(_ section: Int, _ conv: Conversation) -> some View {
        let isSelected = conv.id == selectedConversationId
        let isLongPress = conv.id == longPressConversation?.id
        HStack(spacing: 12) {
            Text(conv.title)
                .textStyle(.body2(textColor: Color.Menu.Font.default))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, 12)
                .contentShape(Rectangle())
            if isLongPress {
                Spacer()
                HStack(spacing: 8) {
                    Image(.pen)
                        .resizable()
                        .menuStyle()
                        .square(24)
                        .contentShape(Rectangle())
                        .anyButton {
                            rename(conv)
                        }
                    Image(.trash2)
                        .resizable()
                        .menuStyle()
                        .square(24)
                        .contentShape(Rectangle())
                        .anyButton {
                            onDeleteButtonPressed(section, conv)
                        }
                        .padding(.trailing, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill((isSelected || isLongPress) ? Color.Menu.Bg.active : .clear)
        )
        .gesture(
           TapGesture().onEnded {
               onConversationItemPressed?(conv)
           }
           .exclusively(
            before: LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                UIDevice.impactOccurred()
                longPressConversation = conv
            })
        )
        .contentShape(Rectangle())
    }
    private var menus: [(title: String, icon: ImageResource)] {
        [
            ("Models", .layoutGrid),
            ("Settings", .settings),
            ("About", .info)
        ]
    }

    private func onDeleteButtonPressed(_ section: Int, _ conv: Conversation) {
        do {
            try conversationManager.deleteConversation(by: conv.id)
            withAnimation(.easeInOut) {
                if section < conversationsGroup.count {
                    var conversations = conversationsGroup[section].conversations
                    conversations.removeAll { $0 == conv }
                    conversationsGroup[section].conversations = conversations
                }
            }
            onDeleteConversation?(conv)
        } catch {
            Log.error(error)
        }
    }

    private func loadConversations() {
        do {
            conversationsGroup = try conversationManager.getConversationsAndGroupByWeekAndMonth()

            Task {
                try? await Task.sleep(for: .seconds(0.02))
                proxy?.scrollTo(selectedConversationId, anchor: .center)
            }

        } catch {
            Log.error(error)
        }
    }

    private func rename(_ conv: Conversation) {
        renameInputConfirm = .init(
            title: "Rename Chat",
            prompt: "input title...",
            value: conv.title,
            enableEmpty: false
        ) { value in
            do {
                try conversationManager.updateTitle(of: conv.id, title: value)
                loadConversations()
                longPressConversation = nil
            } catch {
                Log.error(error)
            }
        }
    }
}

#Preview {
    ZStack {
        MenuView(selectedConversationId: "")
    }
    .previewEnvironment()

}
