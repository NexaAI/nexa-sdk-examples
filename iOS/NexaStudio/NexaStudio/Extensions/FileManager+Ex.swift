import Foundation

extension FileManager {
    static func copyToDocuments(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(sourceURL.lastPathComponent)

        if fileManager.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}
