import SwiftUI
import Observation
import Foundation
import NexaAI

@Observable
@MainActor
class ChatViewModel {
    let modelManager: ModelManager
    var path: [NavigationPathOption] = []
    private let conversationManager: ConversationManager

    private(set) var conversationId: String
    private var startIndex: Int = 0
    private let maxMessageCount: Int = 20
    private(set) var messages: [Message] = []
    private(set) var currentGenerateMessge: Message?

    var models: [ModelInfo] { get { modelManager.modelPersistence.models } }
    var selectedModel: ModelInfo? { modelManager.currentModelInfo }

    var chatInputViewModel: ChatInputViewModel = .init()
    var prompt: String {
        get { chatInputViewModel.text }
        set { chatInputViewModel.text = newValue }
    }

    var scrollPosition: String?
    var isAssistantGenerationViewExpand: Bool = false

    var isGenerating: Bool = false {
        didSet {
            chatInputViewModel.isGenerating = isGenerating
            if !isGenerating {
                modelManager.stopGeneration()
            }
        }
    }
    var isLoadingModel: Bool {
        get { modelManager.isLoadingModel }
    }
    var modelLoadProgress: Float = 0
    var generationError: Error?
    var isLoadModelError: Bool = false

    var currentEditingMessage: Message?
    var isEdit: Bool  { chatInputViewModel.isEditing }
    var scrollToBottom: Bool = false

    init(
        conversationManager: ConversationManager,
        modelManager: ModelManager,
        conversationId: String = ""
    ) {
        self.conversationManager = conversationManager
        self.modelManager = modelManager
        self.conversationId = conversationId
    }

    // MARK: - load history messages
    func loadMessages() {
        do {
            if isNewChat {

            } else {
                messages = try conversationManager.fetchMessages(by: conversationId)
            }
            startIndex = 0
        } catch {
            Log.error(error)
        }
    }

    func reloadConversation(_ conv: Conversation) {
        if conv.id == conversationId {
            return
        }
        isGenerating = false
        Task {
            await modelManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.generationError = nil
                self.isGenerating = false
                self.isAssistantGenerationViewExpand = false
                self.currentEditingMessage = nil
                self.chatInputViewModel.isEditing = false
                self.chatInputViewModel.clear()
                self.conversationId = conv.id
                self.loadMessages()
                self.startIndex = max(0, self.messages.count - 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.scrollToBottom.toggle()
                }
            }
        }
    }

    func createNewConversation() async {
        isGenerating = false
        await modelManager.reset()
        conversationId = ""
        messages = []
        currentGenerateMessge = nil
        generationError = nil
        isAssistantGenerationViewExpand = false
        currentEditingMessage = nil
        chatInputViewModel.isEditing = false
        chatInputViewModel.clear()
        startIndex = 0
    }

    func reload() {
        Task {
            isLoadModelError = false
            await loadModel()
            await createNewConversation()
        }
    }

    func loadModel() async {
        guard let selectedModel, selectedModel.isComplete else {
            Task {
                await modelManager.unload()
            }
            return
        }
        chatInputViewModel.modelType = selectedModel.modelType
        do {
            willLoadModel()
            switch selectedModel.modelType {
            case .imageToText,
                 .any:
                let options = ModelOptions(
                    modelPath: selectedModel.localModelPath.path(),
                    mmprojPath: selectedModel.localProjectPath.path(),
                    config: .init(nCtx: Int32(modelManager.configManager.contextLength)),
                    deviceId: nil,
                    gpuLayers: 999
                )
                try await modelManager.load(modelType: .vlm, options: options)
            case .chat:
                let config = modelManager.configManager.llmModelConfig
                let options = ModelOptions(
                    modelPath: selectedModel.localModelPath.path(),
                    config: config,
                    deviceId: nil, //modelManager.configManager.acc
                    gpuLayers: 999
                )
                try await modelManager.load(modelType: .llm, options: options)
            }
            didLoadModel()
        } catch {
            Log.error(error)
            isLoadModelError = true
        }
    }

    func reset() {
        Task {
            await modelManager.reset()
        }
        startIndex = messages.count
    }

    func willLoadModel() {
        Task {
            modelLoadProgress = 0.0
            while modelLoadProgress < 0.95 {
                let increment = Float.random(in: 0.1...0.3)
                withAnimation(.smooth) {
                    modelLoadProgress = min(modelLoadProgress + increment, 0.95)
                }
                try? await Task.sleep(for: .seconds(0.1))
            }
        }
    }

    func didLoadModel() {
        withAnimation(.smooth) {
            modelLoadProgress = 1.0
        }
        Task {
            try? await Task.sleep(for: .seconds(0.02))
            modelLoadProgress = 0.0
        }
    }

    func regerationStreamAfterEditMessage() {
        if !modelManager.isLoaded {
            isLoadModelError = true
            return
        }

        Task {
            if let currentEditingMessage {
                let index = messages.firstIndex { $0.id == currentEditingMessage.id }
                if let index {
                    messages = Array(messages[0..<index])
                }
                do {
                    try conversationManager.removeMessages(of: conversationId, after: currentEditingMessage)
                    await modelManager.reset()
                    startIndex = max(messages.count - 1,0)
                    generationStream()
                    chatInputViewModel.isEditing = false
                } catch {
                    endGenerating(with: error)
                }
            }
        }
    }

    func regerationStream(from index: Int) {
        if isGenerating {
            return
        }

        if index >= messages.count {
            return
        }

        if !modelManager.isLoaded {
            isLoadModelError = true
            return
        }

        Task {
            let isUser = messages[index].isUser
            let userMessageIndex = isUser ? index : index - 1
            let userMessage = messages[userMessageIndex]
            let responseMessage = isUser ? nil : messages[index]
            do {
                let type = modelManager.model?.type
                if type == .llm {
                    if userMessage.isUser, userMessage.content.isEmpty {
                        throw ChatError.emptyMessage
                    }
                }
                messages = Array(messages[0...userMessageIndex])
                if let responseMessage {
                    try conversationManager.removeMessages(of: conversationId, after: responseMessage)
                }
                await modelManager.reset()
                scrollPosition = userMessage.id
                startIndex = max(messages.count - 1, 0)
                let genMsgs: [Message]
                if startIndex >= messages.count {
                    genMsgs = messages.suffix(maxMessageCount)
                } else {
                    genMsgs = Array(messages[startIndex...])
                }
                var images = [String]()
                var audios = [String]()
                genMsgs.forEach {
                    images.append(contentsOf: $0.images.map { $0.path() })
                    audios.append(contentsOf: $0.audios.map { $0.path() })
                }
                try await generation(genMsgs: genMsgs, images: images, audios: audios)
            } catch {
                endGenerating(with: error)
            }
        }
    }

    func generationStream() {
        if !modelManager.isLoaded {
            isLoadModelError = true
            return
        }

        let content = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageUrls = chatInputViewModel.saveAndGetImageUrls()
        let audiosUrls = chatInputViewModel.selectedAudios.map { $0.audioURL }
        let documentUrls = chatInputViewModel.selectedDocuments.map { $0.url }
        chatInputViewModel.clear()
        Task {
            do {
                let message = Message.user(content, images: imageUrls, audios: audiosUrls)
                if isNewChat {
                    let newConversation = try conversationManager.addConversation(message)
                    conversationId = newConversation.id
                } else {
                    try conversationManager.addMessage(conversationId: conversationId, message: message)
                }
                messages.append(message)
                scrollPosition = message.id

                let genMsgs: [Message]
                if startIndex >= messages.count {
                    genMsgs = messages.suffix(maxMessageCount)
                } else {
                    genMsgs = Array(messages[startIndex...])
                }

                try await generation(genMsgs: genMsgs, images: imageUrls.map { $0.path() }, audios: audiosUrls.map { $0.path() }, documents: documentUrls)
            } catch {
                endGenerating(with: error)
            }
        }
    }

    func updateCurrentModelInfo(_ modelInfo: ModelInfo) {
        if isLoadingModel {
            return
        }
        if modelManager.currentModelInfo == modelInfo {
            return
        }
        modelManager.currentModelInfo = modelInfo
    }

    private var enableChatMultiRound: Bool = false
    private func generation(genMsgs: [Message], images: [String] = .init(), audios: [String] = .init(), documents: [URL]? = nil) async throws {
        beginGenerating()
        let currentConversationId = conversationId
        let monitor = MemoryMonitorScope()

        var options = generationOptions()
        if modelManager.model?.type == .vlm {
            options.config.imagePaths = images
            options.config.audioPaths = audios
        }

        var assistant = Message.assistant("")
        currentGenerateMessge = assistant

        let msgs: [Message]
        if enableChatMultiRound {
            if let last = genMsgs.last {
                msgs = [last]
            } else {
                msgs = []
            }
            await modelManager.reset()
        } else if let document = documents?.first {
            if var last = genMsgs.last {
                last.content = await buildPrompt(from: document, query: last.content)
                msgs = [last]
            } else {
                msgs = []
            }
            await modelManager.reset()
        } else {
            msgs = genMsgs
        }

        let stream = try await modelManager.generateAsyncStream(
            from: msgs,
            options: options
        )

        var tokens = 0
        for try await value in stream {
            assistant.content += value
            tokens += 1
            if isGenerating, tokens == 3 {
                currentGenerateMessge = assistant
                tokens = 0
            }
        }
        if isGenerating {
            currentGenerateMessge = assistant
        }

        let profileData = await modelManager.getProfileData()

        assistant.profile = .init(from: profileData, peakMemory: monitor.peakMemory, acceleration: modelManager.configManager.acc.uppercased())

        try conversationManager.addMessage(conversationId: currentConversationId, message: assistant)
        if currentConversationId == conversationId {
            messages.append(assistant)
        }

        endGenerating()
    }

    private func buildPrompt(from document: URL, query: String) async -> String {
        guard let path = Bundle.main.path(forResource: "jina-embeddings-v2-small-en-Q4_K_M", ofType: "gguf") else {
            return query
        }

        do {
            let embedder = try Embedder(modelPath: path)
            let context: String
            if document.pathExtension == "pdf" {
                let rag = RAGPdfService(embedder: embedder)
                context = try await rag.retrieve(from: document, query: query, topK: 5).joined(separator: "\n\n")
            } else {
                let rag = RAGPlainTextService(embedder: embedder, chunker: SentenceChunker())
                context = try await rag.retrieve(from: document, query: query, topK: 8).joined(separator: "\n\n")
            }

            return """
            You are a helpful assistant.

            I will provide you with some context. 
            If the context is useful and relevant, please use it to answer the question.  
            If the context is irrelevant, incomplete, or unhelpful, **ignore it** and answer the question directly based on your own knowledge.

            Context:
            \(context)

            Question: \(query)

            Answer in a clear and concise way:
            """
        } catch {
            Log.error(error)
        }
        return query
    }

    private func systemPrompt() -> String? {
        return nil
    }

    private func generationOptions() -> GenerationOptions {
        let config = modelManager.configManager.generationConfig
        let options = GenerationOptions(
            config: config,
            templateOptions: .init(enableThinking: modelManager.configManager.isThinkModeOn)
        )
        return options
    }

    private func beginGenerating() {
        isAssistantGenerationViewExpand = false
        isGenerating = true
        generationError = nil
    }

    private func endGenerating() {
        currentGenerateMessge = nil
        isGenerating = false
        scrollPosition = nil
    }

    private func endGenerating(with error: Error) {
        currentGenerateMessge = nil
        isGenerating = false
        isAssistantGenerationViewExpand = false
        generationError = error
    }

    func shouldExpandMessage(_ message: Message, at index: Int) -> Bool {
        if index == messages.count - 1 , message.isAssistant {
            return isAssistantGenerationViewExpand
        }
        return false
    }

    func shouldShowActonOfMessage(_ message: Message, at index: Int) -> Bool {
        return index == messages.count - 1 && message.isAssistant
    }

    func editUserMessage(_ message: Message, at index: Int) {
        if !modelManager.isLoaded {
            isLoadModelError = true
            return
        }
        
        currentEditingMessage = message
        chatInputViewModel.isEditing = true
        chatInputViewModel.text = message.content
        chatInputViewModel.selectedImages = message.images.map { .init(url:  $0) }
        chatInputViewModel.selectedAudios = message.audios.map { .init(audioURL: $0) }
        chatInputViewModel.isFocused = true
    }

    var messagesBeforeEditing: [Message] {
        if let currentEditingMessage, isEdit {
            let index = messages.firstIndex { $0.id == currentEditingMessage.id }
            if let index {
                return Array(messages[0..<index])
            } else {
                return messages
            }

        } else {
            return messages
        }
    }

    var isNewChat: Bool {
        conversationId.isEmpty
    }
}

extension ChatViewModel {
    public enum ChatError: LocalizedError {
        case emptyMessage

        var errorDescription: String? {
            switch self {
            case .emptyMessage:
                return "prompt not allow empty"
            }
        }

        var localizedDescription: String? { errorDescription }
    }
}
