
import Foundation

class Downloader: NSObject, URLSessionDataDelegate {
    struct DownloadInfo {
        let progress: Double
        let remainingTime: Double
        let speed: Double
        let totalBytesWritten: Int64

        init(progress: Double = 0, remainingTime: Double = 0, speed: Double = 0, totalBytesWritten: Int64 = 0) {
            self.progress = progress
            self.remainingTime = remainingTime
            self.speed = speed
            self.totalBytesWritten = totalBytesWritten
        }

        var remainingTimeFormatStr: String {
            if remainingTime.isNaN || remainingTime.isInfinite {
                return "Caculating..."
            }
            let hour = Int(remainingTime) / 3600
            let mins = Int(remainingTime) / 60
            let secs = Int(remainingTime) % 60
            return String(format: "%02d:%02d:%02d", hour, mins, secs)
        }

        var speedFormatStr: String {
            let kSpeed = speed / 1024.0
            let mSpead = kSpeed / 1024.0
            if mSpead > 0 {
                return String(format: "%.02f MB/s", mSpead)
            } else {
                return String(format: "%.02f KB/s", kSpeed)
            }
        }

        var totalBytesWrittenFormatStr: String {
            let kSize = Double(totalBytesWritten) / 1024.0
            let mSize = kSize / 1024.0
            if mSize > 1 {
                return String(format: "%.02f MB", mSize)
            } else {
                return String(format: "%.02f KB", kSize)
            }
        }
    }

    private var session: URLSession!
    private var filePath: String = ""
    private var outputStream: OutputStream?

    private var totalBytesExpected: Int64 = 0
    private var totalBytesWritten: Int64 = 0

    private var downloadTask: URLSessionDataTask?

    private var startTime: Date?
    private var receivedBytesInInterval: Int = 0
    private var lastSpeed: Double = 0.0

    private var progressHandler: ((DownloadInfo) -> Void)?
    private var completionHandler: (() -> Void)?
    private var errorHandler: ((Error) -> Void)?

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }

    func startDownload(
        from url: URL,
        location localUrl: URL,
        token: String?,
        progress: @escaping (DownloadInfo) -> Void,
        completion: @escaping () -> Void,
        failure: @escaping (Error) -> Void
    ) {
        progressHandler = progress
        completionHandler = completion
        errorHandler = failure
        startTime = Date()
        lastSpeed = 0
        receivedBytesInInterval = 0

        filePath = localUrl.path()
        totalBytesWritten = fetchDownloadedFileSize(filePath)

        var request = URLRequest(url: url)
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if totalBytesWritten > 0 {
            request.setValue("bytes=\(totalBytesWritten)-", forHTTPHeaderField: "Range")
        } else {
            request.setValue("bytes=0-", forHTTPHeaderField: "Range")
        }
        downloadTask = session.dataTask(with: request)
        downloadTask?.resume()
    }

    func cancel() {
        downloadTask?.cancel()
        downloadTask = nil
        outputStream?.close()
        outputStream = nil
    }

    // MARK: -
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        totalBytesWritten = fetchDownloadedFileSize(filePath)
        startTime = Date()
        lastSpeed = 0
        receivedBytesInInterval = 0
        outputStream = OutputStream(toFileAtPath: filePath, append: true)
        outputStream?.open()

        totalBytesExpected = response.expectedContentLength + totalBytesWritten
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let now = Date()
        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            let pointer = buffer.bindMemory(to: UInt8.self).baseAddress!
            outputStream?.write(pointer, maxLength: data.count)
        }
        totalBytesWritten += Int64(data.count)
        receivedBytesInInterval += data.count
        let progress = Double(totalBytesWritten) / Double(totalBytesExpected)

        if let startTime {
            let dt = now.timeIntervalSince(startTime)
            if dt >= 1 {
                lastSpeed = Double(receivedBytesInInterval) / dt
                receivedBytesInInterval = 0
                self.startTime = now
            }
        }

        let remainingTime = (Double(totalBytesExpected) - Double(totalBytesWritten)) / (lastSpeed > 0 ? lastSpeed : 1)
        progressHandler?(.init(progress: progress, remainingTime: remainingTime, speed: lastSpeed, totalBytesWritten: totalBytesWritten))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        outputStream?.close()
        outputStream = nil

        if let error = error as? URLError, error.code == .cancelled {

        } else if let error = error {
            errorHandler?(error)
        } else {
            if totalBytesWritten >= totalBytesExpected {
                completionHandler?()
            } else {
                errorHandler?(NSError(domain: "nexaai.downloader", code: -999))
            }
        }
        
        totalBytesWritten = 0
        totalBytesExpected = 0
    }

    private func fetchDownloadedFileSize(_ filePath: String) -> Int64 {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
               let fileSize = attributes[.size] as? NSNumber {
                return fileSize.int64Value
            }
        } else {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        return 0
    }
}


extension Int {
    func sizeFormatStr(_ gapStr: String = " ") -> String {
        let kSize = Double(self) / 1024.0
        let mSize = kSize / 1024.0
        if mSize > 1 {
            return String(format: "%.02f\(gapStr)MB", mSize)
        } else {
            return String(format: "%.02f\(gapStr)KB", kSize)
        }
    }
}
