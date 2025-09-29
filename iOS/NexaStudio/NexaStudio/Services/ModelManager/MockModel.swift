import Foundation
import NexaAI

class MockModel: Model {
    func generateStream(messages: [NexaAI.ChatMessage], options: NexaAI.GenerationOptions) throws -> NexaAI.GenerateResult {
        return GenerateResult(response: "text", profileData: .init())
    }
    func generate(prompt: String, config: GenerationConfig) throws -> GenerateResult {
        return GenerateResult(response: "text", profileData: .init())
    }
    func applyChatTemplate(messages: [NexaAI.ChatMessage], options: ChatTemplateOptions) throws -> String { "" }
    func load(_ options: NexaAI.ModelOptions) throws { }
    func reset() {
        mockTokens = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore".split(separator: " ").map { String($0) }
    }
    func generateAsyncStream(messages: [NexaAI.ChatMessage], options: NexaAI.GenerationOptions) throws -> AsyncThrowingStream<String, any Error> {
        return .init { continuation in
            Task {
                let thinking = Bool.random()
                if thinking {

                    let tokenCount = Int.random(in: 4...100)
                    var result = ""

                    let thinkStart = "<think>"
                    continuation.yield(thinkStart)
                    result += thinkStart

                    for _ in 0..<tokenCount {
                        let token = (mockTokens.randomElement() ?? "") + " "
                        continuation.yield(token)
                        result += token
                        try? await Task.sleep(for: .seconds(0.05))
                    }

                    let thinkEnd = "</think>"
                    continuation.yield(thinkEnd)
                    result += thinkEnd
                }

                let tokenCount = Int.random(in: 4...100)
                var result = ""
                for _ in 0..<tokenCount {
                    let token = (mockTokens.randomElement() ?? "") + " "
                    continuation.yield(token)
                    result += token
                    try? await Task.sleep(for: .seconds(0.05))
                }
                continuation.finish()
            }
        }
    }

    var lastProfileData: NexaAI.ProfileData? {
        .init()
    }

    func stopStream() { }

    var isLoaded: Bool { return true }
    private var mockTokens: [String]

    @MainActor var type: NexaAI.ModelType
    @MainActor init(modelType: NexaAI.ModelType = .llm) {
        mockTokens = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore".split(separator: " ").map { String($0) }
        type = modelType
    }

}
