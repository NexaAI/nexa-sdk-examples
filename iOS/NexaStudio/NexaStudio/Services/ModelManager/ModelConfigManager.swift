import Foundation
import NexaAI

@Observable
@MainActor
class ModelConfigManager {

    static let defaultSystemPrompt: String = "You are a helpful, concise, and privacy-respecting AI assistant running fully on-device. Provide accurate, unbiased answers across a wide range of topics. When unsure, state so clearly. Avoid speculation. Always prioritize clarity, relevance, and user control."
    static let defaultContextLength: Int = 4096
    static let defaultMaxTokens: Int = 4096
    static let defaultAcc: String = "gpu"

    private enum StoreKey: String {
        case generationConfig = "ModelConfigManager.generationConfig"
        case llmModelConfig = "ModelConfigManager.llmModelConfig"
        case isThinkModeOn = "ModelConfigManager.isThinkModeOn"
        case isEmbedOn = "ModelConfigManager.isEmbedOn"
        case contextLength = "ModelConfigManager.contextLength"
        case systemPrompt = "ModelConfigManager.systemPrompt"
        case acc = "ModelConfigManager.acc"
        case lastModelInfo = "ModelConfigManager.lastModelInfo"
    }

    init() {
        let userDefault = UserDefaults.standard
        var config = GenerationConfig.default
        config.maxTokens = Int32(Self.defaultMaxTokens)
        if let data = userDefault.data(forKey: StoreKey.generationConfig.rawValue) {
            self.generationConfig = (try? JSONDecoder().decode(GenerationConfig.self, from: data)) ?? config
        } else {
            self.generationConfig = config
        }

        let modelConfig = ModelConfig.default
        if let data = userDefault.data(forKey: StoreKey.llmModelConfig.rawValue) {
            self.llmModelConfig = (try? JSONDecoder().decode(ModelConfig.self, from: data)) ?? modelConfig
        } else {
            self.llmModelConfig = modelConfig
        }

        if let isOn = userDefault.string(forKey: StoreKey.isThinkModeOn.rawValue) {
            self.isThinkModeOn = isOn == "1"
        } else {
            self.isThinkModeOn = true
        }

        if let isOn = userDefault.string(forKey: StoreKey.isEmbedOn.rawValue) {
            self.isEmbedOn = isOn == "1"
        } else {
            self.isEmbedOn = false
        }

        self.systemPrompt = userDefault.string(forKey: StoreKey.systemPrompt.rawValue) ?? Self.defaultSystemPrompt
        self.acc = userDefault.string(forKey: StoreKey.acc.rawValue) ?? Self.defaultAcc

        let nctx = userDefault.integer(forKey: StoreKey.contextLength.rawValue)
        self.contextLength = nctx == 0 ? Self.defaultContextLength : nctx
    }

    var llmModelConfig: ModelConfig {
        didSet {
            do {
                let data = try JSONEncoder().encode(llmModelConfig)
                UserDefaults.standard.set(data, forKey: StoreKey.llmModelConfig.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                Log.error(error)
            }
        }
    }

    var generationConfig: GenerationConfig {
        didSet {
            do {
                let data = try JSONEncoder().encode(generationConfig)
                UserDefaults.standard.set(data, forKey: StoreKey.generationConfig.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                Log.error(error)
            }
        }
    }

    var isEmbedOn: Bool {
        didSet {
            UserDefaults.standard.setValue(isEmbedOn ? "1" : "0", forKey: StoreKey.isEmbedOn.rawValue)
        }
    }

    var isThinkModeOn: Bool {
        didSet {
            UserDefaults.standard.setValue(isThinkModeOn ? "1" : "0", forKey: StoreKey.isThinkModeOn.rawValue)
        }
    }

    var systemPrompt: String {
        didSet {
            UserDefaults.standard.setValue(systemPrompt, forKey: StoreKey.systemPrompt.rawValue)
        }
    }

    var acc: String {
        didSet {
            UserDefaults.standard.setValue(acc, forKey: StoreKey.acc.rawValue)
        }
    }

    var contextLength: Int {
        didSet {
            UserDefaults.standard.setValue(contextLength, forKey: StoreKey.contextLength.rawValue)
            llmModelConfig.nCtx = Int32(contextLength)
        }
    }

    var maxTokens: Int32 { generationConfig.maxTokens  }
    var topK: Int32 { generationConfig.samplerConfig.topK }
    var topP: Float { generationConfig.samplerConfig.topP }
    var temprature: Float { generationConfig.samplerConfig.temperature }

    var minP: Float { generationConfig.samplerConfig.minP }
    var repetitionPenalty: Float { generationConfig.samplerConfig.repetitionPenalty }
    var presencePenalty: Float { generationConfig.samplerConfig.presencePenalty }
    var frequencyPenalty: Float { generationConfig.samplerConfig.frequencyPenalty }
    var seed: Int32 { generationConfig.samplerConfig.seed }

    func saveLastModelInfo(_ modelInfo: ModelInfo?) {
        guard let modelInfo else {
            UserDefaults.standard.set(nil, forKey: StoreKey.lastModelInfo.rawValue)
            UserDefaults.standard.synchronize()
            return
        }
        do {
            let data = try JSONEncoder().encode(modelInfo)
            UserDefaults.standard.set(data, forKey: StoreKey.lastModelInfo.rawValue)
            UserDefaults.standard.synchronize()
        } catch {
            Log.error(error)
        }
    }

    func loadLastModelInfo() -> ModelInfo? {
        do {
            guard let data = UserDefaults.standard.data(forKey: StoreKey.lastModelInfo.rawValue) else {
                return nil
            }
            let modelInfo = try JSONDecoder().decode(ModelInfo.self, from: data)
            if !modelInfo.isComplete {
                UserDefaults.standard.set(nil, forKey: StoreKey.lastModelInfo.rawValue)
                return nil
            }
            return modelInfo
        } catch {
            Log.error(error)
        }
        return nil
    }
}
