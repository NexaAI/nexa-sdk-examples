import SwiftUI

@MainActor
@Observable
class ModelListViewModel {
    let downloadManager: ModelDownloadManager
    let modelManager: ModelManager

    var currentRunModel: ModelInfo?
    var models: [ModelInfo] = []
    var isLoading: Bool = false
    var status: StatusView.Status?

    private var downloadItems: [String: ModelDownloadItem] = .init()

    init(downloadManager: ModelDownloadManager, modelManager: ModelManager) {
        self.downloadManager = downloadManager
        self.modelManager = modelManager
    }

    func loadModel() async {
        status = nil
        isLoading = true
        let localModels = fetchDefaultModels() ?? []
        updateModels(localModels)
        isLoading = false
    }

    private(set) var expandSection: [ModelType] = ModelType.allCases

    private func updateModels(_ newModels: [ModelInfo]) {
        removeLocalOverdueModel(newModels)
        currentRunModel = modelManager.currentModelInfo
        models = newModels
    }

    private func removeLocalOverdueModel(_ newModels: [ModelInfo]) {
        let localModelCache = modelManager.modelPersistence.models
        if !newModels.isEmpty {
            localModelCache.filter { !newModels.contains($0) }
                .forEach { item in
                    if item == modelManager.currentModelInfo {
                        Task {
                            await modelManager.unload()
                            modelManager.currentModelInfo = nil
                            modelManager.modelPersistence.remove(item)
                        }
                    } else {
                        modelManager.modelPersistence.remove(item)
                    }
                }
        }
    }

    func appendDownloadItems() {
        for item in downloadManager.allDownloadItems {
            downloadItems[item.id] = item
        }
    }
    
    func downloadItem(of model: ModelInfo) -> ModelDownloadItem {
        if let item = downloadManager.downloadItem(of: model) {
            return item
        }
        if let item = downloadItems[model.id] {
            return item
        }
        let newItem = ModelDownloadItem(modelInfo: model)
        downloadItems[model.id] = newItem
        return newItem
    }

    func isSectionExpand(_ modelType: ModelType) -> Bool {
        expandSection.contains(modelType)
    }
    
    func toggleExpandSection(_ modelType: ModelType) {
        if expandSection.contains(modelType) {
            expandSection.removeAll { $0 == modelType }
        } else {
            expandSection.append(modelType)
        }
    }

    var anyModels: [ModelInfo] {
        models.filter { $0.type == ModelType.any.rawValue }
    }

    var multiModels: [ModelInfo] {
        models.filter { $0.type == ModelType.imageToText.rawValue }
    }

    var chatModels: [ModelInfo] {
        models.filter { $0.type == ModelType.chat.rawValue }
    }

    func onRunModelButtonPressed(_ model: ModelInfo, runModel: Binding<ModelInfo>) {
        runModel.wrappedValue = model
    }

    func fetchDefaultModels() -> [ModelInfo]? {
        guard let url = Bundle.main.url(forResource: "models", withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([ModelInfo].self, from: data)
        } catch {
            Log.error(error)
        }

        return nil
    }
}
