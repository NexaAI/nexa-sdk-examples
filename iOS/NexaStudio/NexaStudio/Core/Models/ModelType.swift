import SwiftUI

enum ModelType: String, CaseIterable {
    case imageToText = "multimodal"
    case chat = "chat"
    case any = "any"
}

extension ModelType {
    
    var imageResource: ImageResource {
        switch self {
        case .imageToText:
            return .image
        case .chat:
            return .typeOutline
        case .any:
            return .layers
        }
    }

    var title: String {
        switch self {
        case .imageToText:
            return "Image to Text"
        case .chat:
            return "Text to Text"
        case .any:
            return "Any to Any"
        }
    }
}
