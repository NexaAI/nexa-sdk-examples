import SwiftUI

@Observable
@MainActor
class ModelDownloadManager {

    private var activeDownloads: [String: ModelDownloadItem] = [:]
    private var queuedDownloads: [ModelDownloadItem] = []

    let modelPersistence: ModelPersistence
    let maxConcurrentDownloads: Int
    init(modelPersistence: ModelPersistence, maxConcurrentDownloads: Int = 3) {
        self.modelPersistence = modelPersistence
        self.maxConcurrentDownloads = 3
    }

    var allDownloadItems: [ModelDownloadItem] {
        var items = activeDownloads.values.map { $0 }
        items.append(contentsOf: queuedDownloads)
        return items
    }

    func addDownload(_ item: ModelDownloadItem) {
        if activeDownloads[item.id] != nil {
            return
        }
        if queuedDownloads.contains(where: { item.id == $0.id}) {
            return
        }
        if activeDownloads.count < maxConcurrentDownloads {
            startItem(item)
        } else {
            queuedDownloads.append(item)
        }
    }

    func downloadItem(of model: ModelInfo) -> ModelDownloadItem? {
        if let item = activeDownloads[model.id] {
            return item
        }
        return queuedDownloads.first { $0.id == model.id }
    }

    private func startItem(_ item: ModelDownloadItem) {
        activeDownloads[item.id] = item
        item.start { [weak self] in
            guard let self = self else { return }
            if item.isCompleted {
                self.modelPersistence.insert(item.modelInfo)
            }
            self.activeDownloads.removeValue(forKey: item.id)
            self.checkQueue()
        }
    }

    private func checkQueue() {
        while activeDownloads.count < maxConcurrentDownloads, !queuedDownloads.isEmpty {
            let next = queuedDownloads.removeFirst()
            startItem(next)
        }
    }

    func cancel(_ item: ModelDownloadItem) {
        let model = item.modelInfo
        if let item = activeDownloads[model.id] {
            item.cancel()
            activeDownloads[model.id] = nil
        }
    }

    func remove(_ item: ModelDownloadItem) {
        let model = item.modelInfo
        if let item = activeDownloads[model.id] {
            item.cancel()
            activeDownloads[model.id] = nil
        }
        queuedDownloads.removeAll { $0.id == model.id }
        modelPersistence.remove(model)
        item.status = .notStarted
    }

    func clearAll() {
        for item in activeDownloads.values {
            item.cancel()
        }
        activeDownloads.removeAll()
        queuedDownloads.removeAll()
    }
}
