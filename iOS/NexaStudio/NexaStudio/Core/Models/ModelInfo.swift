import Foundation

struct ModelInfo: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let mmprojOrTokenName: String
    let sizeGb: Double
    let params: String
    let features: [String]?
    let type: String
    let modelUrl: String
    let mmprojOrTokenUrl: String?

    var downloadTime: TimeInterval?
    var lastUseTime: TimeInterval?

    var token: String?
    
    var modelType: ModelType {
        .init(rawValue: type) ?? .chat
    }

    var sizeFormatStr: String {
        if sizeGb < 1 {
            return String(format: "%.02f MB", sizeGb * 1024)
        }
        return String(format: "%.02f GB", sizeGb)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension ModelInfo {

    var localModelFolder: URL {
        FileStoreManager.modelsFolder.appending(path: "\(id)")
    }

    var localModelPath: URL {
        return localModelFolder.appending(path: "\(name)")
    }

    var localProjectPath: URL {
        localModelFolder.appending(path: "\(mmprojOrTokenName)")
    }

    var isComplete: Bool {
        let modelExists = FileManager.default.fileExists(atPath: localModelPath.path())
        if let mmprojOrTokenUrl, !mmprojOrTokenName.isEmpty, !mmprojOrTokenUrl.isEmpty {
            let projectExists = FileManager.default.fileExists(atPath: localProjectPath.path())
            return modelExists && projectExists
        }
        return modelExists
    }
}

extension ModelInfo {
    static let mock = ModelInfo(id: UUID().uuidString, name: "Qwen3-1.7B", mmprojOrTokenName: "", sizeGb: 1.83, params: "1.72 B", features: ["Chat"], type: "chat", modelUrl: "https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q8_0.gguf?download=true", mmprojOrTokenUrl: "")
    static let mockVLM = ModelInfo(id: UUID().uuidString, name: "Qwen3-1.7B", mmprojOrTokenName: "", sizeGb: 1.83, params: "1.72 B", features: ["Chat"], type: "multimodal", modelUrl: "https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q8_0.gguf?download=true", mmprojOrTokenUrl: "")
}
