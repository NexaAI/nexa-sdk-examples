import Foundation

@MainActor
protocol ModelPersistence {
    var models: [ModelInfo] { get }
    func insert(_ model: ModelInfo)
    func remove(_ model: ModelInfo)
    func updateLastUseTime(of model: ModelInfo?)
    func clear()
}
