import Foundation

extension URL {
    var name: String {
        lastPathComponent
    }

    var size: Int? {
        let resourceValues = try? resourceValues(forKeys: [.fileSizeKey])
        return resourceValues?.fileSize
    }

    var type: String {
        if !pathExtension.isEmpty {
            return pathExtension.uppercased()
        }
        let resourceValues = try? resourceValues(forKeys: [.fileSizeKey])
        return (resourceValues?.contentType?.identifier ?? "unknow").uppercased()
    }

    var sizeStr: String {
        guard let size else {
            return "unknow"
        }
        return size.sizeFormatStr("")
    }
}
