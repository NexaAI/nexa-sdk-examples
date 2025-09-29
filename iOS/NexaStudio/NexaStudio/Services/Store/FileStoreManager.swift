import Foundation
import UIKit

class FileStoreManager {

    static func saveImage(_ image: UIImage, named name: String = UUID().uuidString) throws -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesFolder.path) {
            try fileManager.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        }

        let imageURL = imageURL(with: name)
        if fileManager.fileExists(atPath: imageURL.path) {
            return imageURL
        }

        try data.write(to: imageURL)
        return imageURL
    }

    static func copyModelFile(at sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: modelsFolder.path()) {
            try fileManager.createDirectory(at: modelsFolder, withIntermediateDirectories: true)
        }
        let destinationURL = modelsFolder.appendingPathComponent(sourceURL.lastPathComponent)
        if fileManager.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }


    static func copyAudio(from url: URL) throws -> URL {
        _ = url.startAccessingSecurityScopedResource()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: audiosFolder.path()) {
            try fileManager.createDirectory(at: audiosFolder, withIntermediateDirectories: true)
        }

        let destinationURL = audiosFolder.appendingPathComponent(url.lastPathComponent)
        if fileManager.fileExists(atPath: destinationURL.path) {
           try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: url, to: destinationURL)
        url.stopAccessingSecurityScopedResource()
        return destinationURL
    }

    static func copyDocument(from url: URL) throws -> URL {
        _ = url.startAccessingSecurityScopedResource()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: docsFolder.path()) {
            try fileManager.createDirectory(at: docsFolder, withIntermediateDirectories: true)
        }

        let destinationURL = docsFolder.appendingPathComponent(url.lastPathComponent)
        if fileManager.fileExists(atPath: destinationURL.path) {
           try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: url, to: destinationURL)
        url.stopAccessingSecurityScopedResource()
        return destinationURL
    }

    static func createFolderIfNeed(_ folder: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folder.path) {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
    }

    static func rename(at location: URL, to newFileName: String) throws {
        let fileManager = FileManager.default
        let destinationURL = location.deletingLastPathComponent().appendingPathComponent(newFileName)
        try? fileManager.removeItem(at: destinationURL)
        try fileManager.moveItem(at: location, to: destinationURL)
    }

    static func imageURL(with name: String) -> URL {
        imagesFolder.appendingPathComponent("\(name)")
    }

    static func audioURL(with name: String) -> URL {
        audiosFolder.appendingPathComponent("\(name)")
    }

    static func videoURL(with name: String) -> URL {
        videosFolder.appendingPathComponent("\(name)")
    }

    static var imagesFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("images")
    }

    static var audiosFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("audios")
    }

    static var docsFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("docs")
    }

    static var videosFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("videos")
    }

    static var modelsFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("models")
    }

}

extension FileStoreManager {

    static var systemFreeSize: Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory ?? NSHomeDirectory()),
              let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? Int64 else {
            return nil
        }
        return freeSize
    }

    static var systemSize: Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory ?? NSHomeDirectory()),
              let totalSize = systemAttributes[FileAttributeKey.systemSize] as? Int64 else {
            return nil
        }
        return totalSize
    }
    
}
