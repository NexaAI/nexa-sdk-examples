import SwiftUI
import SwiftData

@Observable
class ModelDownloadItem: Identifiable {
    enum Status {
        case notStarted
        case downloading
        case completed
        case failed
        case cancelled
    }

    var id: String {
        modelInfo.id
    }

    private var downloader = Downloader()
    private(set) var retryCount = 0
    private var isDownloadMMproj = false

    var modelDownloadInfo: Downloader.DownloadInfo = .init()
    var mmprojDownloadInfo: Downloader.DownloadInfo = .init()

    var status: ModelDownloadItem.Status = .notStarted
    var errorDesc: String?

    var remainingTimeFormatStr: String {
        if status == .completed {
            return "00:00:00"
        }

        if speed.isNaN || speed.isInfinite || speed == 0 || status == .failed  {
            return "--:--:--"
        }
        let time = (modelInfo.sizeGb * 1024 * 1024 * 1024 - Double(totalBytesWriten)) / speed
        let hour = Int(time) / 3600
        let mins = Int(time - Double(hour) * 3600.0) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hour, mins, secs)
    }

    var speedFormatStr: String {
        if status == .failed || status == .completed {
            return "0.00 KB/s"
        }
        let kSpeed = speed / 1024.0
        let mSpead = kSpeed / 1024.0
        if mSpead > 1 {
            return String(format: "%.02f MB/s", mSpead)
        } else {
            return String(format: "%.02f KB/s", kSpeed)
        }
    }

    var speed: Double {
        isDownloadMMproj ? (mmprojDownloadInfo.speed == 0 ? modelDownloadInfo.speed : mmprojDownloadInfo.speed) : modelDownloadInfo.speed
    }

    var downloadProgress: Int {
        let progress = Double(totalBytesWriten) / (modelInfo.sizeGb * 1024 * 1024 * 1024)
        return min(Int(progress * 100), 100)
    }

    var totalBytesWriten: Int64 {
        modelDownloadInfo.totalBytesWritten + mmprojDownloadInfo.totalBytesWritten
    }

    var totalBytesWrittenFormatStr: String {
        let kSize = Double(totalBytesWriten) / 1024.0
        let mSize = kSize / 1024.0
        let gSize = mSize / 1024.0
        if gSize > 1 {
            return String(format: "%.02f GB", gSize)
        }
        if mSize > 1 {
            return String(format: "%.02f MB", mSize)
        }
        return String(format: "%.02f KB", kSize)
    }

    let modelInfo: ModelInfo
    init(modelInfo: ModelInfo) {
        self.modelInfo = modelInfo
    }

    func start(onComplete: @escaping () -> Void) {
        guard let modelUrl = URL(string: modelInfo.modelUrl) else {
            self.errorDesc = "Invalid URL format"
            self.status = .failed
            onComplete()
            return
        }
        errorDesc = nil
        status = .downloading
        downloadModelFile(with: modelUrl, onComplete: onComplete)
    }

    func cancel() {
        downloader.cancel()
        status = .cancelled
    }

    var isCancelled: Bool { status == .cancelled }
    var isCompleted: Bool { status == .completed }

    private func downloadModelFile(with modelUrl: URL, onComplete: @escaping () -> Void) {
        let modelLocalFloder = modelInfo.localModelFolder
        let modelName = modelInfo.name
        let location = modelLocalFloder.appendingPathComponent(modelName + ".tmp")
        isDownloadMMproj = false
        do {
            try FileStoreManager.createFolderIfNeed(modelLocalFloder)
        } catch {
            Log.error(error)
            self.updateErrorStr(with: error)
            status = .failed
            onComplete()
            return
        }
        downloader.startDownload(
            from: modelUrl,
            location: location,
            token: modelInfo.token,
            progress: { [weak self] info in
                self?.modelDownloadInfo = info
            },
            completion: { [weak self] in
                do {
                    try FileStoreManager.rename(at: location, to: modelName)
                } catch {
                    Log.error(error)
                    self?.updateErrorStr(with: error)
                    self?.status = .failed
                    onComplete()
                    return
                }

                if let mmprojOrTokenUrl = self?.modelInfo.mmprojOrTokenUrl,
                   !mmprojOrTokenUrl.isEmpty,
                   let mmprojUrl = URL(string: mmprojOrTokenUrl) {
                    self?.isDownloadMMproj = true
                    self?.downloadMmprojFile(with: mmprojUrl, onComplete: onComplete)
                } else {
                    self?.status = .completed
                    onComplete()
                }
            },
            failure: { [weak self] error in
                Log.error(error)
                guard let self = self else { return }
                if self.retryCount < 3 {
                    self.retryCount += 1
                    self.start(onComplete: onComplete) // retry
                } else if UIApplication.shared.applicationState == .background {
                    self.start(onComplete: onComplete)
                } else {
                    self.updateErrorStr(with: error)
                    self.status = .failed
                    onComplete()
                }
            }
        )
    }

    private func updateErrorStr(with error: Error) {
        if let err = error as? URLError {
            if err.code == .networkConnectionLost ||
                err.code == .cannotLoadFromNetwork ||
                err.code == .notConnectedToInternet {
                self.errorDesc = "No connection right now, please reconnect."
            } else if err.code == .unknown {
                self.errorDesc = "Something went wrong, please try again."
            } else {
                self.errorDesc = error.localizedDescription
            }
        } else {
            self.errorDesc = error.localizedDescription
        }
    }

    private func downloadMmprojFile(with url: URL, onComplete: @escaping () -> Void) {
        let modelFolder = modelInfo.localModelFolder
        let modelProjectName = modelInfo.mmprojOrTokenName
        let location = modelFolder.appendingPathComponent(modelProjectName + ".tmp")
        do {
            try FileStoreManager.createFolderIfNeed(modelFolder)
        } catch {
            Log.error(error)
            self.updateErrorStr(with: error)
            status = .failed
            onComplete()
            return
        }
        downloader.startDownload(
            from: url,
            location: location,
            token: modelInfo.token,
            progress: { [weak self] info in
                self?.mmprojDownloadInfo = info
            },
            completion: { [weak self] in
                do {
                    try FileStoreManager.rename(at: location, to: modelProjectName)
                } catch {
                    Log.error(error)
                    self?.updateErrorStr(with: error)
                    self?.status = .failed
                    onComplete()
                    return
                }
                self?.status = .completed
                onComplete()
            },
            failure: { [weak self] error in
                Log.error(error)
                guard let self = self else { return }
                if self.retryCount < 3 {
                    self.retryCount += 1
                    self.downloadMmprojFile(with: url, onComplete: onComplete) // retry
                } else if UIApplication.shared.applicationState == .background {
                    self.downloadMmprojFile(with: url, onComplete: onComplete)
                } else {
                    self.updateErrorStr(with: error)
                    self.status = .failed
                    onComplete()
                }
            }
        )
    }
}
