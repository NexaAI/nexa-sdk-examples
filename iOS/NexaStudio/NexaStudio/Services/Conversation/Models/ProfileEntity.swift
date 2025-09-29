import SwiftData
import Foundation

@Model
class ProfileEntity: Identifiable {
    @Attribute(.unique)
    private(set) var id = UUID().uuidString

    var ttft: Int64
    var acceleration: String
    var speed: Double
    var prefillSpeed: Double
    var peakMemory: Double

    var message: MessageEntity?
    
    init?(from model: ProfileModel?) {
        guard let model else {
            return nil
        }
        self.id = UUID().uuidString
        self.ttft = model.ttft
        self.acceleration = model.acceleration
        self.speed = model.speed
        self.prefillSpeed = model.prefillSpeed
        self.peakMemory = model.peakMemory
    }

    var toProfileModel: ProfileModel {
        .init(ttft: ttft, acceleration: acceleration, speed: speed, prefillSpeed: prefillSpeed, peakMemory: peakMemory)
    }
}
