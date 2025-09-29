import SwiftUI
import Foundation

struct ChatView: View {

    @State private(set) var vm: ChatViewModel
    @State private var isFocused: Bool = false
    @State private var showModelList: Bool = false
    @State private var lastMessageOffsetY: CGFloat?
    @State private var inputViewOffsetY: CGFloat = 30
    @State private var isFirstLoadingModel: Bool = true
    @State private var navBarOpacity = 0.0
    @State private var generateViewHeight = 0.0
    @State private var lastUserMessageViewHeight = 0.0

    @State private var menuListModal: AnyModal?
    
    @AppStorage(AppStoreKey.offloadWhenEnterBackground)
    private var offloadWhenEnterBackground: Bool = true

    @Environment(\.scenePhase) private var scenePhase
    @State private var isEnterBackground: Bool = false


    var body: some View {
        NavigationStack(path: $vm.path) {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    if vm.isLoadModelError {
                        modelErrorLoadView
                    } else if vm.messages.isEmpty {
                        emptyMessageView
                    } else {
                        messagesSection
                    }
                    // navigation background
                    Rectangle()
                        .fill(Color.Background.secondary)
                        .ignoresSafeArea()
                        .frame(height: geo.safeAreaInsets.top)
                        .overlay(alignment: .bottom, content: {
                            Rectangle().fill(Color.Stroke.secondary).frame(height: 0.5)
                        })
                        .offset(y: -geo.safeAreaInsets.top)
                        .opacity(navBarOpacity)
                }
                .overlay(alignment: .top, content: {
                    if vm.isLoadingModel {
                        ProgressView(value: vm.modelLoadProgress)
                            .progressViewStyle(.linear)
                            .scaleEffect(y: 0.8)
                            .offset(y: -1)
                    }
                })
                .safeAreaInset(edge: .bottom, content: {
                    VStack(spacing: 16) {
                        if shouldShowArrowDownView {
                            arrowDownView
                        }

                        ChatInputView(vm: vm.chatInputViewModel) { isEdit in
                            onSendButtonPressed(isEdit)
                        } onTextFieldFocusedChange: { isFocused in
                            self.isFocused = isFocused
                        } onStopButtonPressed: { [weak vm] in
                            vm?.isGenerating = false
                        }
                        .offset(y: inputViewOffsetY)
                        .opacity(inputViewOffsetY == 0 ? 1 : 0)
                    }
                })
                .background(Color.Background.secondary)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
                .toolbar { toolBar }
                .navigationDestinationForCoreModule(path: $vm.path)
                .onFirstAppear {
                    Task {
                        try? await Task.sleep(for: .seconds(0.1))
                        withAnimation(.easeInOut(duration: 0.6)) {
                            navBarOpacity = 1.0
                            inputViewOffsetY = 0
                        }
                    }
                    Task {
                        await vm.loadModel()
                        vm.loadMessages()
                        isFirstLoadingModel = false
                    }
                }
                .onChange(of: vm.modelManager.forceRefesh) { _, _ in
                    vm.reload()
                }
                .onChange(of: vm.chatInputViewModel.isEditing) { _ , newValue in
                    if newValue == false {
                        vm.currentEditingMessage = nil
                    }
                }
                .onChange(of: scenePhase) { oldValue, newValue in
                    if offloadWhenEnterBackground {
                        if newValue == .background {
                            Task {
                                vm.modelLoadProgress = 0
                                await vm.modelManager.unload()
                            }
                            isEnterBackground = true
                        } else if newValue == .active, isEnterBackground {
                            Task {
                                await vm.loadModel()
                                isEnterBackground = false
                            }
                        }
                    }
                }
            }
        }
        .anyModal($menuListModal)
    }

    //MARK: - subviews
    private var messagesSection: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView {
                    Text("").frame(height: 16)
                    VStack(spacing: 16) {
                        var messages = vm.isEdit ? vm.messagesBeforeEditing : vm.messages
                        let totalCount = messages.count
                        let lastMessage = totalCount > 0 ? messages.removeLast() : nil
                        ForEach(Array(messages.enumerated()), id: \.offset) { (idx, message) in
                            ChatBubbleView(
                                message: message,
                                isExpand: vm.shouldExpandMessage(message, at: idx),
                                showAction: vm.shouldShowActonOfMessage(message, at: idx),
                                onRegenerateButtonPress: { _ in vm.regerationStream(from: idx) },
                                onEditMenuPressed: {
                                    vm.editUserMessage(message, at: idx)
                                }
                            )
                            .id(message.id)
                        }

                        if let lastMessage {
                            ChatBubbleView(
                                message: lastMessage,
                                isExpand: vm.shouldExpandMessage(lastMessage, at: totalCount - 1),
                                showAction: vm.shouldShowActonOfMessage(lastMessage, at: totalCount - 1),
                                onRegenerateButtonPress: { _ in vm.regerationStream(from: totalCount - 1) },
                                onEditMenuPressed: {
                                    vm.editUserMessage(lastMessage, at: totalCount - 1)
                                }
                            )
                            .onFrameChange { _, newValue in
                                lastUserMessageViewHeight = newValue.height
                            }
                            .id(lastMessage.id)
                        }
                    }
                    Text("")
                        .frame(width: 1, height: 1)
                        .onFrameChange { oldValue , newValue in
                            lastMessageOffsetY = newValue.minY
                        }

                    if let currentGenerateMessge = vm.currentGenerateMessge {
                        ChatAssistantGenerationView(message: currentGenerateMessge) { isExpand in
                            vm.isAssistantGenerationViewExpand = isExpand
                        }
                        .id(currentGenerateMessge.id)
                        .onFrameChange { _, newValue in
                            generateViewHeight = newValue.height
                        }
                    }

                    if let _ = vm.generationError {
                        GenerationFailView() {
                            vm.regerationStream(from: vm.messages.count - 1)
                        }
                        .padding(.horizontal, 16)
                    }

                    Color.clear
                        .frame(height: bottomSpaceOfScrollView(geo))
                }
                .safeAreaPadding(.bottom, 20)
                .scrollDismissesKeyboard(.immediately)
                .defaultScrollAnchor(.top)
                .onChange(of: vm.chatInputViewModel.isFocused) { _ , newValue in
                    if newValue {
                        scrollToBottom(proxy)
                    }
                }
                .onChange(of: vm.scrollPosition) { _, newValue in
                    scrollToTop(proxy, newValue)
                }
                .onChange(of: vm.scrollToBottom) { _, _ in
                    scrollToBottom(proxy)
                }
            }
        }
    }

    private func bottomSpaceOfScrollView(_ geo: GeometryProxy) -> CGFloat {
        vm.isGenerating ? max(geo.size.height - generateViewHeight - lastUserMessageViewHeight - 16 - 8, 0) : max(geo.size.height - lastUserMessageViewHeight - 46 - 32 - 16 - 16,0)
    }

    private func scrollToTop(_ proxy: ScrollViewProxy, _ position: String?) {
        if position == nil {
            return
        }
        Task {
            try? await Task.sleep(for: .seconds(0.168))
            withAnimation {
                proxy.scrollTo(position, anchor: .top)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        Task {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation {
                proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
            }
        }
    }

    private var modelErrorLoadView: some View {
        GeometryReader { geo in
            ScrollView {
                let modelStatus = StatusView.Status.modelLoad {
                    vm.reload()
                }
                StatusView(status: modelStatus)
                .frame(height: geo.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }

    private var emptyMessageView: some View {
        GeometryReader { geo in
            ScrollView {
                ChatModelSelectView(
                    showModelSelectedView: !isEnterBackground && !isFirstLoadingModel && !vm.modelManager.isLoadingModel && !vm.modelManager.isLoaded,
                    insets: geo.safeAreaInsets
                ) {
                    vm.path.append(.modelListView)
                }
                .frame(height: geo.size.height)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }

    private var arrowDownView: some View {
        VStack {
            Image(.arrowDown)
                .buttonSecondaryStyle()
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.Button.Tertiary.Bg.default)
                        .stroke(Color.Button.Tertiary.Border.default, lineWidth: 1)
                )
                .shadow300(16)
        }
        .contentShape(Rectangle())
        .anyButton {
            vm.scrollToBottom.toggle()
        }
    }

    private var shouldShowArrowDownView: Bool {
        if vm.messages.isEmpty {
            return false
        }
        if let lastMessageOffsetY {
            return lastMessageOffsetY > 1.1 * UIScreen.main.bounds.height
        } else {
            return false
        }
    }

    @ToolbarContentBuilder
    private var toolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Image(.menu)
                .primaryStyle()
                .anyButton {
                    onMenuButtonPressed()
                }
                .opacity(navBarOpacity)
        }
        ToolbarItem(placement: .principal) {
            modelSelectedButton
                .opacity(navBarOpacity)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Image(.messageCirclePlus)
                .primaryStyle()
                .opacity(navBarOpacity)
                .anyButton {
                    onPlusButtonPressed()
                }
        }
    }

    private var modelSelectedButton: some View {
        HStack(alignment: .center, spacing: 4) {
            let title = vm.selectedModel != nil ? vm.selectedModel!.name : "Selected Model"
            Text(title)
                .textStyle(.subtitle2())
                .lineLimit(1)
            Image(.chevronDown)
                .resizable()
                .primaryStyle()
                .aspectRatio(contentMode: .fill)
                .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.Component.Fills.primary)
                .opacity(showModelList ? 1 : 0)
        )
        .anyButton {
            if vm.models.isEmpty {
                vm.path.append(.modelListView)
            } else {
                showModelList.toggle()
            }
        }
        .anyPopover(
            isPresented: $showModelList,
            position: .bottom,
            contentSize: chatModelListViewSize
        ) {
            ChatModelListView(
                models: Array(vm.models.prefix(5)),
                selectedModel: vm.selectedModel,
                onSelectedModel: { selectedModel in
                    showModelList.toggle()
                    vm.updateCurrentModelInfo(selectedModel)
                },
                onMoreButtonPress: {
                    showModelList.toggle()
                    vm.path.append(.modelListView)
                })
            .frame(width: chatModelListViewSize.width, height: chatModelListViewSize.height)
            .offset(y: 18)
        }
    }

    private var chatModelListViewSize: CGSize {
        .init(width: 260, height: min(vm.models.count, 5) * Int(ChatModelListView.itemHeight) + Int(ChatModelListView.moreButtonHeight))
    }

    // MARK: - Actions
    private func onMenuButtonPressed() {
        vm.chatInputViewModel.isFocused = false
        DispatchQueue.main.async {
            self.menuListModal = .init(contentView: {
                AnyView (
                    MenuView(selectedConversationId: vm.conversationId) { conv in
                        menuListModal = nil
                        lastMessageOffsetY = nil
                        vm.reloadConversation(conv)
                    } onNewChatButtonPressed: {
                        menuListModal = nil
                        Task {
                            await vm.createNewConversation()
                        }
                    } onDeleteConversation: { conv in
                        if conv.id != vm.conversationId {
                            return
                        }
                        Task {
                            await vm.createNewConversation()
                        }
                    } onModelsButtonPressed: {
                        menuListModal = nil
                        Task {
                            try? await Task.sleep(for: .seconds(0.2))
                            self.vm.path.append(.modelListView)
                        }
                    } onSettingButtonPressed: {
                        menuListModal = nil
                        Task {
                            try? await Task.sleep(for: .seconds(0.2))
                            self.vm.path.append(.appSettingView)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.move(edge: .leading))
                )
            })
        }
    }


    private func onPlusButtonPressed() {
        Task {
            await vm.createNewConversation()
        }
    }

    private func onSendButtonPressed(_ isEdit: Bool) {
        if isEdit {
            vm.regerationStreamAfterEditMessage()
        } else {
            vm.generationStream()
        }
    }
}

#Preview {
    ChatView(vm: .init(conversationManager: DevPreview.share.conversationManager, modelManager: DevPreview.share.modelManager, conversationId: ""))
        .previewEnvironment()
}
