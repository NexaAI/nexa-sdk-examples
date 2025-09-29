import SwiftData
import Foundation

@Model
class MessageEntity: Identifiable {

    private struct Path: Codable {
        let name: String
    }

    @Attribute(.unique)
    private(set) var id: String

    private(set) var role: Message.Role
    private(set) var content: String
    private(set) var createAt: Date

    private var imageIds: [Path]
    private var audioIds: [Path]
    private var videoIds: [Path]

    var conversation: ConversationEntity?

    @Relationship(deleteRule: .cascade, inverse: \ProfileEntity.message)
    private var profile: ProfileEntity?

    init(from message: Message) {
        self.id = message.id
        self.role = message.role
        self.content = message.content
        self.createAt = message.createAt
        self.imageIds = message.images.map { Path(name: $0.lastPathComponent) }
        self.audioIds = message.audios.map { Path(name: $0.lastPathComponent) }
        self.videoIds = message.videos.map { Path(name: $0.lastPathComponent) }
        self.profile = .init(from: message.profile)
    }

    var toMessage: Message {
        var message = Message(
            id: id,
            role: role,
            content: content,
            images: imageIds.map { FileStoreManager.imageURL(with: $0.name) },
            audios: audioIds.map { FileStoreManager.audioURL(with: $0.name) },
            videos: videoIds.map { FileStoreManager.videoURL(with: $0.name) },
            createAt: createAt
        )
        message.profile = self.profile?.toProfileModel
        return message
    }
}
