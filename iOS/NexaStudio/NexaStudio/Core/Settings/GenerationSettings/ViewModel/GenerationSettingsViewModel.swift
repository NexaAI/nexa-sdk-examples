import SwiftUI
import NexaAI

@Observable
@MainActor
class GenerationSettingsViewModel {

    enum Accelerator: String, CaseIterable, Identifiable {
        case npu
        case gpu
        case cpu

        var id: String {  rawValue  }
    }

    let modelConfigManager: ModelConfigManager

    var maxTokens: Int32
    var topK: Float
    var topP: Float
    var temprature: Float
    var systemPrompt: String
    var acc: Accelerator

    private(set) var isMultiModel: Bool

    init(modelConfigManager: ModelConfigManager, isMultiModel: Bool = false) {
        self.modelConfigManager = modelConfigManager
        self.maxTokens = modelConfigManager.maxTokens
        self.topK = Float(modelConfigManager.topK)
        self.topP = modelConfigManager.topP
        self.temprature = modelConfigManager.temprature
        self.systemPrompt = modelConfigManager.systemPrompt
        self.acc = .init(rawValue: modelConfigManager.acc) ?? .gpu
        self.isMultiModel = false
    }
    
    func reset() {
        let generationConfig = GenerationConfig.default
        maxTokens = Int32(ModelConfigManager.defaultMaxTokens)
        topK = Float(generationConfig.samplerConfig.topK)
        topP = generationConfig.samplerConfig.topP
        temprature = generationConfig.samplerConfig.temperature
        systemPrompt = ModelConfigManager.defaultSystemPrompt
        acc = .gpu
    }

    func save() {
        var generationConfig = modelConfigManager.generationConfig
        generationConfig.maxTokens = maxTokens
        generationConfig.samplerConfig.topK = Int32(topK)
        generationConfig.samplerConfig.topP = topP
        generationConfig.samplerConfig.temperature = temprature
        modelConfigManager.generationConfig = generationConfig
        modelConfigManager.systemPrompt = systemPrompt
        modelConfigManager.acc = acc.rawValue
    }
}


extension NumberFormatter {

    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = (-Double.greatestFiniteMagnitude) as NSNumber
        formatter.maximum = (Double.greatestFiniteMagnitude) as NSNumber
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }

    static var intFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }

    static var floatFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
