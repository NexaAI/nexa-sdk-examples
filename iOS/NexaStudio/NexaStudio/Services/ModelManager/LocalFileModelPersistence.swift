import Foundation

@Observable
@MainActor
class LocalFileModelPersistence: ModelPersistence {

    private(set) var models: [ModelInfo] = []
    private let fileURL: URL

    init() {
        self.fileURL = FileStoreManager.modelsFolder.appendingPathComponent("models.json")
        self.load()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            self.models = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            self.models = try JSONDecoder().decode([ModelInfo].self, from: data)
            sorted()
        } catch {
            self.models = []
        }
    }

    private func save() {
        do {
            sorted()
            let data = try JSONEncoder().encode(models)
            try data.write(to: fileURL)
        } catch {
            Log.error(error)
        }
    }

    func insert(_ model: ModelInfo) {
        if !models.contains(where: { $0.id == model.id }) {
            var m = model
            m.downloadTime = Date().timeIntervalSince1970
            models.append(m)
            save()
        }
    }

    func updateLastUseTime(of model: ModelInfo?) {
        guard let model else {
            return
        }
        let index = models.firstIndex { $0.id == model.id }
        if let index {
            models[index].lastUseTime = Date().timeIntervalSince1970
            save()
        }
    }

    func remove(_ model: ModelInfo) {
        models.removeAll { $0.id == model.id }
        save()
        try? FileManager.default.removeItem(at: model.localModelFolder)
    }

    func clear() {
        models.removeAll()
        save()
    }

    private func sorted() {
        self.models.sort { m1, m2 in
            if let m1UseTime = m1.lastUseTime, let m2UseTime = m2.lastUseTime {
                return m1UseTime > m2UseTime
            }
            if nil != m1.lastUseTime {
                return true
            }
            if nil != m2.lastUseTime {
                return false
            }

            if let m1DownloadTime = m1.downloadTime, let m2DownloadTime = m2.downloadTime {
                return m1DownloadTime > m2DownloadTime
            }

            if nil != m1.downloadTime {
                return true
            }

            if nil != m2.downloadTime {
                return false
            }
            return true
        }
    }
}
