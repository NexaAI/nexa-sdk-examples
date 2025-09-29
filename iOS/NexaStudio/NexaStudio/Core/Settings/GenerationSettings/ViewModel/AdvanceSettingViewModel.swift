import SwiftUI
import NexaAI

@Observable
@MainActor
class AdvanceSettingViewModel {

    let modelConfigManager: ModelConfigManager

    enum Mirostat: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case off
        case v1
        case v2
    }

    var minProbability: Float
    var penaltyPresent: Float
    var seed: Int32
    var tcThreshold: Float = 0
    var xtcProbability: Float = 0
    var typicalP: Float = 0
    var penaltyLastN: Float = 0
    var mirostat: Mirostat = .off
    var isJinja: Bool = true

    init(modelConfigManager: ModelConfigManager) {
        self.modelConfigManager = modelConfigManager
        self.minProbability = modelConfigManager.minP
        self.penaltyPresent = modelConfigManager.presencePenalty
        self.seed = modelConfigManager.seed
    }

    func save() {
        var sampleConfig = modelConfigManager.generationConfig.samplerConfig
        sampleConfig.minP = minProbability
        sampleConfig.presencePenalty = penaltyPresent
        sampleConfig.seed = seed
        modelConfigManager.generationConfig.samplerConfig = sampleConfig
    }

    func reset() {
        let sampleConfig = SamplerConfig.default
        minProbability = sampleConfig.minP
        penaltyPresent = sampleConfig.presencePenalty
        seed = sampleConfig.seed
    }
}
